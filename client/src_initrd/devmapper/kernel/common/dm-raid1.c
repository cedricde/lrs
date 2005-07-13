/*
 * Copyright (C) 2003 Sistina Software Limited.
 *
 * This file is released under the GPL.
 */

#include "dm.h"
#include "dm-daemon.h"
#include "dm-io.h"
#include "dm-log.h"
#include "kcopyd.h"

#include <linux/ctype.h>
#include <linux/init.h>
#include <linux/mempool.h>
#include <linux/module.h>
#include <linux/pagemap.h>
#include <linux/slab.h>
#include <linux/time.h>
#include <linux/vmalloc.h>

static struct dm_daemon _kmirrord;

/*-----------------------------------------------------------------
 * buffer lists:
 *
 * We play with singly linked lists of buffers, but we want to be
 * careful to add new buffers to the back of the list, to avoid
 * buffers being starved of attention.
 *---------------------------------------------------------------*/
struct buffer_list {
	struct buffer_head *head;
	struct buffer_head *tail;
};

static inline void buffer_list_init(struct buffer_list *bl)
{
	bl->head = bl->tail = NULL;
}

static inline void buffer_list_add(struct buffer_list *bl,
				   struct buffer_head *bh)
{
	bh->b_reqnext = NULL;

	if (bl->tail) {
		bl->tail->b_reqnext = bh;
		bl->tail = bh;
	} else
		bl->head = bl->tail = bh;
}

static struct buffer_head *buffer_list_pop(struct buffer_list *bl)
{
	struct buffer_head *bh = bl->head;

	if (bh) {
		bl->head = bl->head->b_reqnext;
		if (!bl->head)
			bl->tail = NULL;

		bh->b_reqnext = NULL;
	}

	return bh;
}

/*-----------------------------------------------------------------
 * Region hash
 *
 * The mirror splits itself up into discrete regions.  Each
 * region can be in one of three states: clean, dirty,
 * nosync.  There is no need to put clean regions in the hash.
 *
 * In addition to being present in the hash table a region _may_
 * be present on one of three lists.
 *
 *   clean_regions: Regions on this list have no io pending to
 *   them, they are in sync, we are no longer interested in them,
 *   they are dull.  rh_update_states() will remove them from the
 *   hash table.
 *
 *   quiesced_regions: These regions have been spun down, ready
 *   for recovery.  rh_recovery_start() will remove regions from
 *   this list and hand them to kmirrord, which will schedule the
 *   recovery io with kcopyd.
 *
 *   recovered_regions: Regions that kcopyd has successfully
 *   recovered.  rh_update_states() will now schedule any delayed
 *   io, up the recovery_count, and remove the region from the
 *   hash.
 *
 * There are 2 locks:
 *   A rw spin lock 'hash_lock' protects just the hash table,
 *   this is never held in write mode from interrupt context,
 *   which I believe means that we only have to disable irqs when
 *   doing a write lock.
 *
 *   An ordinary spin lock 'region_lock' that protects the three
 *   lists in the region_hash, with the 'state', 'list' and
 *   'bhs_delayed' fields of the regions.  This is used from irq
 *   context, so all other uses will have to suspend local irqs.
 *---------------------------------------------------------------*/
struct mirror_set;
struct region_hash {
	struct mirror_set *ms;
	sector_t region_size;

	/* holds persistent region state */
	struct dirty_log *log;

	/* hash table */
	rwlock_t hash_lock;
	mempool_t *region_pool;
	unsigned int mask;
	unsigned int nr_buckets;
	struct list_head *buckets;

	spinlock_t region_lock;
	struct semaphore recovery_count;
	struct list_head clean_regions;
	struct list_head quiesced_regions;
	struct list_head recovered_regions;
};

enum {
	RH_CLEAN,
	RH_DIRTY,
	RH_NOSYNC,
	RH_RECOVERING
};

struct region {
	struct region_hash *rh;	/* FIXME: can we get rid of this ? */
	region_t key;
	int state;

	struct list_head hash_list;
	struct list_head list;

	atomic_t pending;
	struct buffer_head *delayed_bhs;
};

/*
 * Conversion fns
 */
static inline region_t bh_to_region(struct region_hash *rh,
				    struct buffer_head *bh)
{
	return bh->b_rsector / rh->region_size;
}

static inline sector_t region_to_sector(struct region_hash *rh, region_t region)
{
	return region * rh->region_size;
}

/* FIXME move this */
static void queue_bh(struct mirror_set *ms, struct buffer_head *bh, int rw);

static void *region_alloc(int gfp_mask, void *pool_data)
{
	return kmalloc(sizeof(struct region), gfp_mask);
}

static void region_free(void *element, void *pool_data)
{
	kfree(element);
}

#define MIN_REGIONS 64
#define MAX_RECOVERY 1
static int rh_init(struct region_hash *rh, struct mirror_set *ms,
		   struct dirty_log *log, sector_t region_size,
		   region_t nr_regions)
{
	unsigned int nr_buckets, max_buckets;
	size_t i;

	/*
	 * Calculate a suitable number of buckets for our hash
	 * table.
	 */
	max_buckets = nr_regions >> 6;
	for (nr_buckets = 128u; nr_buckets < max_buckets; nr_buckets <<= 1)
		;
	nr_buckets >>= 1;

	rh->ms = ms;
	rh->log = log;
	rh->region_size = region_size;
	rwlock_init(&rh->hash_lock);
	rh->mask = nr_buckets - 1;
	rh->nr_buckets = nr_buckets;

	rh->buckets = vmalloc(nr_buckets * sizeof(*rh->buckets));
	if (!rh->buckets) {
		DMERR("unable to allocate region hash memory");
		return -ENOMEM;
	}

	for (i = 0; i < nr_buckets; i++)
		INIT_LIST_HEAD(rh->buckets + i);

	spin_lock_init(&rh->region_lock);
	sema_init(&rh->recovery_count, 0);
	INIT_LIST_HEAD(&rh->clean_regions);
	INIT_LIST_HEAD(&rh->quiesced_regions);
	INIT_LIST_HEAD(&rh->recovered_regions);

	rh->region_pool = mempool_create(MIN_REGIONS, region_alloc,
					 region_free, NULL);
	if (!rh->region_pool) {
		vfree(rh->buckets);
		rh->buckets = NULL;
		return -ENOMEM;
	}

	return 0;
}

static void rh_exit(struct region_hash *rh)
{
	unsigned int h;
	struct region *reg;
	struct list_head *tmp, *tmp2;

	BUG_ON(!list_empty(&rh->quiesced_regions));
	for (h = 0; h < rh->nr_buckets; h++) {
		list_for_each_safe (tmp, tmp2, rh->buckets + h) {
			reg = list_entry(tmp, struct region, hash_list);
			BUG_ON(atomic_read(&reg->pending));
			mempool_free(reg, rh->region_pool);
		}
	}

	if (rh->log)
		dm_destroy_dirty_log(rh->log);
	if (rh->region_pool)
		mempool_destroy(rh->region_pool);
	vfree(rh->buckets);
}

#define RH_HASH_MULT 2654435387U

static inline unsigned int rh_hash(struct region_hash *rh, region_t region)
{
	return (unsigned int) ((region * RH_HASH_MULT) >> 12) & rh->mask;
}

static struct region *__rh_lookup(struct region_hash *rh, region_t region)
{
	struct region *reg;

	list_for_each_entry (reg, rh->buckets + rh_hash(rh, region), hash_list)
		if (reg->key == region)
			return reg;

	return NULL;
}

static void __rh_insert(struct region_hash *rh, struct region *reg)
{
	unsigned int h = rh_hash(rh, reg->key);
	list_add(&reg->hash_list, rh->buckets + h);
}

static struct region *__rh_alloc(struct region_hash *rh, region_t region)
{
	struct region *reg, *nreg;

	read_unlock(&rh->hash_lock);
	nreg = mempool_alloc(rh->region_pool, GFP_NOIO);
	nreg->state = rh->log->type->in_sync(rh->log, region, 1) ?
		RH_CLEAN : RH_NOSYNC;
	nreg->rh = rh;
	nreg->key = region;

	INIT_LIST_HEAD(&nreg->list);

	atomic_set(&nreg->pending, 0);
	nreg->delayed_bhs = NULL;
	write_lock_irq(&rh->hash_lock);

	reg = __rh_lookup(rh, region);
	if (reg)
		/* we lost the race */
		mempool_free(nreg, rh->region_pool);

	else {
		__rh_insert(rh, nreg);
		if (nreg->state == RH_CLEAN) {
			spin_lock_irq(&rh->region_lock);
			list_add(&nreg->list, &rh->clean_regions);
			spin_unlock_irq(&rh->region_lock);
		}
		reg = nreg;
	}
	write_unlock_irq(&rh->hash_lock);
	read_lock(&rh->hash_lock);

	return reg;
}

static inline struct region *__rh_find(struct region_hash *rh, region_t region)
{
	struct region *reg;

	reg = __rh_lookup(rh, region);
	if (!reg)
		reg = __rh_alloc(rh, region);

	return reg;
}

static int rh_state(struct region_hash *rh, region_t region, int may_block)
{
	int r;
	struct region *reg;

	read_lock(&rh->hash_lock);
	reg = __rh_lookup(rh, region);
	read_unlock(&rh->hash_lock);

	if (reg)
		return reg->state;

	/*
	 * The region wasn't in the hash, so we fall back to the
	 * dirty log.
	 */
	r = rh->log->type->in_sync(rh->log, region, may_block);

	/*
	 * Any error from the dirty log (eg. -EWOULDBLOCK) gets
	 * taken as a RH_NOSYNC
	 */
	return r == 1 ? RH_CLEAN : RH_NOSYNC;
}

static inline int rh_in_sync(struct region_hash *rh,
			     region_t region, int may_block)
{
	int state = rh_state(rh, region, may_block);
	return state == RH_CLEAN || state == RH_DIRTY;
}

static void dispatch_buffers(struct mirror_set *ms, struct buffer_head *bh)
{
	struct buffer_head *nbh;

	while (bh) {
		nbh = bh->b_reqnext;
		queue_bh(ms, bh, WRITE);
		bh = nbh;
	}
}

static void rh_update_states(struct region_hash *rh)
{
	struct list_head *tmp, *tmp2;
	struct region *reg;

	LIST_HEAD(clean);
	LIST_HEAD(recovered);

	/*
	 * Quickly grab the lists.
	 */
	write_lock_irq(&rh->hash_lock);
	spin_lock(&rh->region_lock);
	if (!list_empty(&rh->clean_regions)) {
		list_splice(&rh->clean_regions, &clean);
		INIT_LIST_HEAD(&rh->clean_regions);

		list_for_each_entry (reg, &clean, list) {
			rh->log->type->clear_region(rh->log, reg->key);
			list_del(&reg->hash_list);
		}
	}

	if (!list_empty(&rh->recovered_regions)) {
		list_splice(&rh->recovered_regions, &recovered);
		INIT_LIST_HEAD(&rh->recovered_regions);

		list_for_each_entry (reg, &recovered, list)
			list_del(&reg->hash_list);
	}
	spin_unlock(&rh->region_lock);
	write_unlock_irq(&rh->hash_lock);

	/*
	 * All the regions on the recovered and clean lists have
	 * now been pulled out of the system, so no need to do
	 * any more locking.
	 */
	list_for_each_safe (tmp, tmp2, &recovered) {
		reg = list_entry(tmp, struct region, list);

		rh->log->type->complete_resync_work(rh->log, reg->key, 1);
		dispatch_buffers(rh->ms, reg->delayed_bhs);
		up(&rh->recovery_count);
		mempool_free(reg, rh->region_pool);
	}

	list_for_each_safe (tmp, tmp2, &clean) {
		reg = list_entry(tmp, struct region, list);
		mempool_free(reg, rh->region_pool);
	}
}

static void rh_inc(struct region_hash *rh, region_t region)
{
	struct region *reg;

	read_lock(&rh->hash_lock);
	reg = __rh_find(rh, region);
	if (reg->state == RH_CLEAN) {
		rh->log->type->mark_region(rh->log, reg->key);

		spin_lock_irq(&rh->region_lock);
		reg->state = RH_DIRTY;
		list_del_init(&reg->list);	/* take off the clean list */
		spin_unlock_irq(&rh->region_lock);
	}

	atomic_inc(&reg->pending);
	read_unlock(&rh->hash_lock);
}

static void rh_inc_pending(struct region_hash *rh, struct buffer_list *buffers)
{
	struct buffer_head *bh;

	for (bh = buffers->head; bh; bh = bh->b_reqnext)
		rh_inc(rh, bh_to_region(rh, bh));
}

static void rh_dec(struct region_hash *rh, region_t region)
{
	unsigned long flags;
	struct region *reg;
	int wake = 0;

	read_lock(&rh->hash_lock);
	reg = __rh_lookup(rh, region);
	read_unlock(&rh->hash_lock);

	if (atomic_dec_and_test(&reg->pending)) {
		spin_lock_irqsave(&rh->region_lock, flags);
		if (reg->state == RH_RECOVERING) {
			list_add_tail(&reg->list, &rh->quiesced_regions);
		} else {
			reg->state = RH_CLEAN;
			list_add(&reg->list, &rh->clean_regions);
		}
		spin_unlock_irqrestore(&rh->region_lock, flags);
		wake = 1;
	}

	if (wake)
		dm_daemon_wake(&_kmirrord);
}

/*
 * Starts quiescing a region in preparation for recovery.
 */
static int __rh_recovery_prepare(struct region_hash *rh)
{
	int r;
	struct region *reg;
	region_t region;

	/*
	 * Ask the dirty log what's next.
	 */
	r = rh->log->type->get_resync_work(rh->log, &region);
	if (r <= 0)
		return r;

	/*
	 * Get this region, and start it quiescing by setting the
	 * recovering flag.
	 */
	read_lock(&rh->hash_lock);
	reg = __rh_find(rh, region);
	read_unlock(&rh->hash_lock);

	spin_lock_irq(&rh->region_lock);
	reg->state = RH_RECOVERING;

	/* Already quiesced ? */
	if (atomic_read(&reg->pending))
		list_del_init(&reg->list);

	else {
		list_del_init(&reg->list);
		list_add(&reg->list, &rh->quiesced_regions);
	}
	spin_unlock_irq(&rh->region_lock);

	return 1;
}

static void rh_recovery_prepare(struct region_hash *rh)
{
	while (!down_trylock(&rh->recovery_count))
		if (__rh_recovery_prepare(rh) <= 0) {
			up(&rh->recovery_count);
			break;
		}
}

/*
 * Returns any quiesced regions.
 */
static struct region *rh_recovery_start(struct region_hash *rh)
{
	struct region *reg = NULL;

	spin_lock_irq(&rh->region_lock);
	if (!list_empty(&rh->quiesced_regions)) {
		reg = list_entry(rh->quiesced_regions.next,
				 struct region, list);
		list_del_init(&reg->list);	/* remove from the quiesced list */
	}
	spin_unlock_irq(&rh->region_lock);

	return reg;
}

/* FIXME: success ignored for now */
static void rh_recovery_end(struct region *reg, int success)
{
	struct region_hash *rh = reg->rh;

	spin_lock_irq(&rh->region_lock);
	list_add(&reg->list, &reg->rh->recovered_regions);
	spin_unlock_irq(&rh->region_lock);

	dm_daemon_wake(&_kmirrord);
}

static void rh_flush(struct region_hash *rh)
{
	rh->log->type->flush(rh->log);
}

static void rh_delay(struct region_hash *rh, struct buffer_head *bh)
{
	struct region *reg;

	read_lock(&rh->hash_lock);
	reg = __rh_find(rh, bh_to_region(rh, bh));
	bh->b_reqnext = reg->delayed_bhs;
	reg->delayed_bhs = bh;
	read_unlock(&rh->hash_lock);
}

static void rh_stop_recovery(struct region_hash *rh)
{
	int i;

	/* wait for any recovering regions */
	for (i = 0; i < MAX_RECOVERY; i++)
		down(&rh->recovery_count);
}

static void rh_start_recovery(struct region_hash *rh)
{
	int i;

	for (i = 0; i < MAX_RECOVERY; i++)
		up(&rh->recovery_count);

	dm_daemon_wake(&_kmirrord);
}

/*-----------------------------------------------------------------
 * Mirror set structures.
 *---------------------------------------------------------------*/
struct mirror {
	atomic_t error_count;
	struct dm_dev *dev;
	sector_t offset;
};

struct mirror_set {
	struct dm_target *ti;
	struct list_head list;
	struct region_hash rh;
	struct kcopyd_client *kcopyd_client;

	spinlock_t lock;	/* protects the next two lists */
	struct buffer_list reads;
	struct buffer_list writes;

	/* recovery */
	region_t nr_regions;
	region_t sync_count;

	unsigned int nr_mirrors;
	struct mirror mirror[0];
};

/*
 * Every mirror should look like this one.
 */
#define DEFAULT_MIRROR 0

/*
 * This is yucky.  We squirrel the mirror_set struct away inside
 * b_reqnext for write buffers.  This is safe since the bh
 * doesn't get submitted to the lower levels of block layer.
 */
static struct mirror_set *bh_get_ms(struct buffer_head *bh)
{
	return (struct mirror_set *) bh->b_reqnext;
}

static void bh_set_ms(struct buffer_head *bh, struct mirror_set *ms)
{
	bh->b_reqnext = (struct buffer_head *) ms;
}

/*-----------------------------------------------------------------
 * Recovery.
 *
 * When a mirror is first activated we may find that some regions
 * are in the no-sync state.  We have to recover these by
 * recopying from the default mirror to all the others.
 *---------------------------------------------------------------*/
static void recovery_complete(int read_err, unsigned int write_err,
			      void *context)
{
	struct region *reg = (struct region *) context;
	struct mirror_set *ms = reg->rh->ms;

	/* FIXME: better error handling */
	rh_recovery_end(reg, read_err || write_err);
	if (++ms->sync_count == ms->nr_regions)
		/* the sync is complete */
		dm_table_event(ms->ti->table);
}

static int recover(struct mirror_set *ms, struct region *reg)
{
	int r;
	unsigned int i;
	struct io_region from, to[ms->nr_mirrors - 1], *dest;
	struct mirror *m;
	unsigned int flags = 0;

	/* fill in the source */
	m = ms->mirror + DEFAULT_MIRROR;
	from.dev = m->dev->dev;
	from.sector = m->offset + region_to_sector(reg->rh, reg->key);
	if (reg->key == (ms->nr_regions - 1)) {
		/*
		 * The final region may be smaller than
		 * region_size.
		 */
		from.count = ms->ti->len & (reg->rh->region_size - 1);
		if (!from.count)
			from.count = reg->rh->region_size;
	} else
		from.count = reg->rh->region_size;

	/* fill in the destinations */
	for (i = 1; i < ms->nr_mirrors; i++) {
		m = ms->mirror + i;
		dest = to + (i - 1);

		dest->dev = m->dev->dev;
		dest->sector = m->offset + region_to_sector(reg->rh, reg->key);
		dest->count = from.count;
	}

	/* hand to kcopyd */
	set_bit(KCOPYD_IGNORE_ERROR, &flags);
	r = kcopyd_copy(ms->kcopyd_client, &from, ms->nr_mirrors - 1, to, flags,
			recovery_complete, reg);

	return r;
}

static void do_recovery(struct mirror_set *ms)
{
	int r;
	struct region *reg;

	/*
	 * Start quiescing some regions.
	 */
	rh_recovery_prepare(&ms->rh);

	/*
	 * Copy any already quiesced regions.
	 */
	while ((reg = rh_recovery_start(&ms->rh))) {
		r = recover(ms, reg);
		if (r)
			rh_recovery_end(reg, 0);
	}
}

/*-----------------------------------------------------------------
 * Reads
 *---------------------------------------------------------------*/
static struct mirror *choose_mirror(struct mirror_set *ms, sector_t sector)
{
	/* FIXME: add read balancing */
	return ms->mirror + DEFAULT_MIRROR;
}

/*
 * remap a buffer to a particular mirror.
 */
static void map_buffer(struct mirror_set *ms,
		       struct mirror *m, struct buffer_head *bh)
{
	bh->b_rdev = m->dev->dev;
	bh->b_rsector = m->offset + (bh->b_rsector - ms->ti->begin);
}

static void do_reads(struct mirror_set *ms, struct buffer_list *reads)
{
	region_t region;
	struct buffer_head *bh;
	struct mirror *m;

	while ((bh = buffer_list_pop(reads))) {
		region = bh_to_region(&ms->rh, bh);

		/*
		 * We can only read balance if the region is in sync.
		 */
		if (rh_in_sync(&ms->rh, region, 0))
			m = choose_mirror(ms, bh->b_rsector);
		else
			m = ms->mirror + DEFAULT_MIRROR;

		map_buffer(ms, m, bh);
		generic_make_request(READ, bh);
	}
}

/*-----------------------------------------------------------------
 * Writes.
 *
 * We do different things with the write io depending on the
 * state of the region that it's in:
 *
 * SYNC: 	increment pending, use kcopyd to write to *all* mirrors
 * RECOVERING:	delay the io until recovery completes
 * NOSYNC:	increment pending, just write to the default mirror
 *---------------------------------------------------------------*/
static void write_callback(unsigned int error, void *context)
{
	unsigned int i;
	int uptodate = 1;
	struct buffer_head *bh = (struct buffer_head *) context;
	struct mirror_set *ms;

	ms = bh_get_ms(bh);
	bh_set_ms(bh, NULL);

	/*
	 * NOTE: We don't decrement the pending count here,
	 * instead it is done by the targets endio function.
	 * This way we handle both writes to SYNC and NOSYNC
	 * regions with the same code.
	 */

	if (error) {
		/*
		 * only error the io if all mirrors failed.
		 * FIXME: bogus
		 */
		uptodate = 0;
		for (i = 0; i < ms->nr_mirrors; i++)
			if (!test_bit(i, &error)) {
				uptodate = 1;
				break;
			}
	}
	bh->b_end_io(bh, uptodate);
}

static void do_write(struct mirror_set *ms, struct buffer_head *bh)
{
	unsigned int i;
	struct io_region io[ms->nr_mirrors];
	struct mirror *m;

	for (i = 0; i < ms->nr_mirrors; i++) {
		m = ms->mirror + i;

		io[i].dev = m->dev->dev;
		io[i].sector = m->offset + (bh->b_rsector - ms->ti->begin);
		io[i].count = bh->b_size >> 9;
	}

	bh_set_ms(bh, ms);
	dm_io_async(ms->nr_mirrors, io, WRITE, bh->b_page,
		    (unsigned int) bh->b_data & ~PAGE_MASK, write_callback, bh);
}

static void do_writes(struct mirror_set *ms, struct buffer_list *writes)
{
	int state;
	struct buffer_head *bh;
	struct buffer_list sync, nosync, recover, *this_list = NULL;

	if (!writes->head)
		return;

	/*
	 * Classify each write.
	 */
	buffer_list_init(&sync);
	buffer_list_init(&nosync);
	buffer_list_init(&recover);

	while ((bh = buffer_list_pop(writes))) {
		state = rh_state(&ms->rh, bh_to_region(&ms->rh, bh), 1);
		switch (state) {
		case RH_CLEAN:
		case RH_DIRTY:
			this_list = &sync;
			break;

		case RH_NOSYNC:
			this_list = &nosync;
			break;

		case RH_RECOVERING:
			this_list = &recover;
			break;
		}

		buffer_list_add(this_list, bh);
	}

	/*
	 * Increment the pending counts for any regions that will
	 * be written to (writes to recover regions are going to
	 * be delayed).
	 */
	rh_inc_pending(&ms->rh, &sync);
	rh_inc_pending(&ms->rh, &nosync);
	rh_flush(&ms->rh);

	/*
	 * Dispatch io.
	 */
	while ((bh = buffer_list_pop(&sync)))
		do_write(ms, bh);

	while ((bh = buffer_list_pop(&recover)))
		rh_delay(&ms->rh, bh);

	while ((bh = buffer_list_pop(&nosync))) {
		map_buffer(ms, ms->mirror + DEFAULT_MIRROR, bh);
		generic_make_request(WRITE, bh);
	}
}

/*-----------------------------------------------------------------
 * kmirrord
 *---------------------------------------------------------------*/
static LIST_HEAD(_mirror_sets);
static DECLARE_RWSEM(_mirror_sets_lock);

static void do_mirror(struct mirror_set *ms)
{
	struct buffer_list reads, writes;

	spin_lock(&ms->lock);
	memcpy(&reads, &ms->reads, sizeof(reads));
	buffer_list_init(&ms->reads);
	memcpy(&writes, &ms->writes, sizeof(writes));
	buffer_list_init(&ms->writes);
	spin_unlock(&ms->lock);

	rh_update_states(&ms->rh);
	do_recovery(ms);
	do_reads(ms, &reads);
	do_writes(ms, &writes);
	run_task_queue(&tq_disk);
}

static void do_work(void)
{
	struct mirror_set *ms;

	down_read(&_mirror_sets_lock);
	list_for_each_entry (ms, &_mirror_sets, list)
		do_mirror(ms);
	up_read(&_mirror_sets_lock);
}

/*-----------------------------------------------------------------
 * Target functions
 *---------------------------------------------------------------*/
static struct mirror_set *alloc_context(unsigned int nr_mirrors,
					sector_t region_size,
					struct dm_target *ti,
					struct dirty_log *dl)
{
	size_t len;
	struct mirror_set *ms = NULL;

	if (array_too_big(sizeof(*ms), sizeof(ms->mirror[0]), nr_mirrors))
		return NULL;

	len = sizeof(*ms) + (sizeof(ms->mirror[0]) * nr_mirrors);

	ms = kmalloc(len, GFP_KERNEL);
	if (!ms) {
		ti->error = "dm-mirror: Cannot allocate mirror context";
		return NULL;
	}

	memset(ms, 0, len);
	spin_lock_init(&ms->lock);

	ms->ti = ti;
	ms->nr_mirrors = nr_mirrors;
	ms->nr_regions = dm_div_up(ti->len, region_size);

	if (rh_init(&ms->rh, ms, dl, region_size, ms->nr_regions)) {
		ti->error = "dm-mirror: Error creating dirty region hash";
		kfree(ms);
		return NULL;
	}

	return ms;
}

static void free_context(struct mirror_set *ms, struct dm_target *ti,
			 unsigned int m)
{
	while (m--)
		dm_put_device(ti, ms->mirror[m].dev);

	rh_exit(&ms->rh);
	kfree(ms);
}

static inline int _check_region_size(struct dm_target *ti, sector_t size)
{
	return !(size % (PAGE_SIZE >> 9) || (size & (size - 1)) ||
		 size > ti->len);
}

static int get_mirror(struct mirror_set *ms, struct dm_target *ti,
		      unsigned int mirror, char **argv)
{
	sector_t offset;

	if (sscanf(argv[1], SECTOR_FORMAT, &offset) != 1) {
		ti->error = "dm-mirror: Invalid offset";
		return -EINVAL;
	}

	if (dm_get_device(ti, argv[0], offset, ti->len,
			  dm_table_get_mode(ti->table),
			  &ms->mirror[mirror].dev)) {
		ti->error = "dm-mirror: Device lookup failure";
		return -ENXIO;
	}

	ms->mirror[mirror].offset = offset;

	return 0;
}

static int add_mirror_set(struct mirror_set *ms)
{
	down_write(&_mirror_sets_lock);
	list_add_tail(&ms->list, &_mirror_sets);
	up_write(&_mirror_sets_lock);
	dm_daemon_wake(&_kmirrord);

	return 0;
}

static void del_mirror_set(struct mirror_set *ms)
{
	down_write(&_mirror_sets_lock);
	list_del(&ms->list);
	up_write(&_mirror_sets_lock);
}

/*
 * Create dirty log: log_type #log_params <log_params>
 */
static struct dirty_log *create_dirty_log(struct dm_target *ti,
					  unsigned int argc, char **argv,
					  unsigned int *args_used)
{
	unsigned int param_count;
	struct dirty_log *dl;

	if (argc < 2) {
		ti->error = "dm-mirror: Insufficient mirror log arguments";
		return NULL;
	}

	if (sscanf(argv[1], "%u", &param_count) != 1 || param_count != 1) {
		ti->error = "dm-mirror: Invalid mirror log argument count";
		return NULL;
	}

	*args_used = 2 + param_count;

	if (argc < *args_used) {
		ti->error = "dm-mirror: Insufficient mirror log arguments";
		return NULL;
	}

	dl = dm_create_dirty_log(argv[0], ti->len, param_count, argv + 2);
	if (!dl) {
		ti->error = "dm-mirror: Error creating mirror dirty log";
		return NULL;
	}

	if (!_check_region_size(ti, dl->type->get_region_size(dl))) {
		ti->error = "dm-mirror: Invalid region size";
		dm_destroy_dirty_log(dl);
		return NULL;
	}

	return dl;
}

/*
 * Construct a mirror mapping:
 *
 * log_type #log_params <log_params>
 * #mirrors [mirror_path offset]{2,}
 *
 * For now, #log_params = 1, log_type = "core"
 *
 */
#define DM_IO_PAGES 64
static int mirror_ctr(struct dm_target *ti, unsigned int argc, char **argv)
{
	int r;
	unsigned int nr_mirrors, m, args_used;
	struct mirror_set *ms;
	struct dirty_log *dl;

	dl = create_dirty_log(ti, argc, argv, &args_used);
	if (!dl)
		return -EINVAL;

	argv += args_used;
	argc -= args_used;

	if (!argc || sscanf(argv[0], "%u", &nr_mirrors) != 1 ||
	    nr_mirrors < 2) {
		ti->error = "dm-mirror: Invalid number of mirrors";
		dm_destroy_dirty_log(dl);
		return -EINVAL;
	}

	argv++, argc--;

	if (argc != nr_mirrors * 2) {
		ti->error = "dm-mirror: Wrong number of mirror arguments";
		dm_destroy_dirty_log(dl);
		return -EINVAL;
	}

	ms = alloc_context(nr_mirrors, dl->type->get_region_size(dl), ti, dl);
	if (!ms) {
		dm_destroy_dirty_log(dl);
		return -ENOMEM;
	}

	/* Get the mirror parameter sets */
	for (m = 0; m < nr_mirrors; m++) {
		r = get_mirror(ms, ti, m, argv);
		if (r) {
			free_context(ms, ti, m);
			return r;
		}
		argv += 2;
		argc -= 2;
	}

	ti->private = ms;

	r = kcopyd_client_create(DM_IO_PAGES, &ms->kcopyd_client);
	if (r) {
		free_context(ms, ti, ms->nr_mirrors);
		return r;
	}

	add_mirror_set(ms);
	return 0;
}

static void mirror_dtr(struct dm_target *ti)
{
	struct mirror_set *ms = (struct mirror_set *) ti->private;

	del_mirror_set(ms);
	kcopyd_client_destroy(ms->kcopyd_client);
	free_context(ms, ti, ms->nr_mirrors);
}

static void queue_bh(struct mirror_set *ms, struct buffer_head *bh, int rw)
{
	int wake = 0;
	struct buffer_list *bl;

	bl = (rw == WRITE) ? &ms->writes : &ms->reads;
	spin_lock(&ms->lock);
	wake = !(bl->head);
	buffer_list_add(bl, bh);
	spin_unlock(&ms->lock);

	if (wake)
		dm_daemon_wake(&_kmirrord);
}

/*
 * Mirror mapping function
 */
static int mirror_map(struct dm_target *ti, struct buffer_head *bh,
		      int rw, union map_info *map_context)
{
	int r;
	struct mirror *m;
	struct mirror_set *ms = ti->private;

	/* FIXME: nasty hack, 32 bit sector_t only */
	map_context->ll = bh->b_rsector / ms->rh.region_size;

	if (rw == WRITE) {
		queue_bh(ms, bh, rw);
		return 0;
	}

	r = ms->rh.log->type->in_sync(ms->rh.log, bh_to_region(&ms->rh, bh), 0);
	if (r < 0 && r != -EWOULDBLOCK)
		return r;

	if (r == -EWOULDBLOCK)	/* FIXME: ugly */
		r = 0;

	/*
	 * We don't want to fast track a recovery just for a read
	 * ahead.  So we just let it silently fail.
	 * FIXME: get rid of this.
	 */
	if (!r && rw == READA)
		return -EIO;

	if (!r) {
		/* Pass this io over to the daemon */
		queue_bh(ms, bh, rw);
		return 0;
	}

	m = choose_mirror(ms, bh->b_rsector);
	if (!m)
		return -EIO;

	map_buffer(ms, m, bh);
	return 1;
}

static int mirror_end_io(struct dm_target *ti, struct buffer_head *bh,
			 int rw, int error, union map_info *map_context)
{
	struct mirror_set *ms = (struct mirror_set *) ti->private;
	region_t region = map_context->ll;

	/*
	 * We need to dec pending if this was a write.
	 */
	if (rw == WRITE)
		rh_dec(&ms->rh, region);

	return 0;
}

static void mirror_suspend(struct dm_target *ti)
{
	struct mirror_set *ms = (struct mirror_set *) ti->private;
	rh_stop_recovery(&ms->rh);
}

static void mirror_resume(struct dm_target *ti)
{
	struct mirror_set *ms = (struct mirror_set *) ti->private;
	rh_start_recovery(&ms->rh);
}

static int mirror_status(struct dm_target *ti, status_type_t type,
			 char *result, unsigned int maxlen)
{
	unsigned int m, sz = 0;
	struct mirror_set *ms = (struct mirror_set *) ti->private;

	switch (type) {
	case STATUSTYPE_INFO:
		sz += snprintf(result + sz, maxlen - sz, "%d ", ms->nr_mirrors);

		for (m = 0; m < ms->nr_mirrors; m++)
			sz += snprintf(result + sz, maxlen - sz, "%s ",
				       dm_kdevname(ms->mirror[m].dev->dev));

		sz += snprintf(result + sz, maxlen - sz, "%lu/%lu",
			       ms->sync_count, ms->nr_regions);
		break;

	case STATUSTYPE_TABLE:
		sz += snprintf(result + sz, maxlen - sz,
			       "%s 1 " SECTOR_FORMAT " %d ",
			       ms->rh.log->type->name, ms->rh.region_size,
			       ms->nr_mirrors);

		for (m = 0; m < ms->nr_mirrors; m++)
			sz += snprintf(result + sz, maxlen - sz, "%s %ld ",
				       dm_kdevname(ms->mirror[m].dev->dev),
				       ms->mirror[m].offset);
	}

	return 0;
}

static struct target_type mirror_target = {
	.name	 = "mirror",
	.version = {1, 0, 1},
	.module	 = THIS_MODULE,
	.ctr	 = mirror_ctr,
	.dtr	 = mirror_dtr,
	.map	 = mirror_map,
	.end_io	 = mirror_end_io,
	.suspend = mirror_suspend,
	.resume	 = mirror_resume,
	.status	 = mirror_status,
};

static int __init dm_mirror_init(void)
{
	int r;

	r = dm_dirty_log_init();
	if (r)
		return r;

	r = dm_daemon_start(&_kmirrord, "kmirrord", do_work);
	if (r) {
		DMERR("couldn't start kmirrord");
		dm_dirty_log_exit();
		return r;
	}

	r = dm_register_target(&mirror_target);
	if (r < 0) {
		DMERR("%s: Failed to register mirror target",
		      mirror_target.name);
		dm_dirty_log_exit();
		dm_daemon_stop(&_kmirrord);
	}

	return r;
}

static void __exit dm_mirror_exit(void)
{
	int r;

	r = dm_unregister_target(&mirror_target);
	if (r < 0)
		DMERR("%s: unregister failed %d", mirror_target.name, r);

	dm_daemon_stop(&_kmirrord);
	dm_dirty_log_exit();
}

/* Module hooks */
module_init(dm_mirror_init);
module_exit(dm_mirror_exit);

MODULE_DESCRIPTION(DM_NAME " mirror target");
MODULE_AUTHOR("Heinz Mauelshagen <mge@sistina.com>");
MODULE_LICENSE("GPL");
