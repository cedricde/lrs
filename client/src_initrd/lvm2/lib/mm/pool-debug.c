/*
 * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
 * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
 *
 * This file is part of LVM2.
 *
 * This copyrighted material is made available to anyone wishing to use,
 * modify, copy, or redistribute it subject to the terms and conditions
 * of the GNU General Public License v.2.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#include "lib.h"
#include "pool.h"

struct block {
	struct block *next;
	size_t size;
	void *data;
};

typedef struct {
	unsigned block_serialno;	/* Non-decreasing serialno of block */
	unsigned blocks_allocated;	/* Current number of blocks allocated */
	unsigned blocks_max;	/* Max no of concurrently-allocated blocks */
	unsigned int bytes, maxbytes;
} pool_stats;

struct pool {
	const char *name;

	int begun;
	struct block *object;

	struct block *blocks;
	struct block *tail;

	pool_stats stats;
};

/* by default things come out aligned for doubles */
#define DEFAULT_ALIGNMENT __alignof__ (double)

struct pool *pool_create(const char *name, size_t chunk_hint)
{
	struct pool *mem = dbg_malloc(sizeof(*mem));

	if (!mem) {
		log_error("Couldn't create memory pool %s (size %"
			  PRIsize_t ")", name, sizeof(*mem));
		return NULL;
	}

	mem->name = name;
	mem->begun = 0;
	mem->object = 0;
	mem->blocks = mem->tail = NULL;

	mem->stats.block_serialno = 0;
	mem->stats.blocks_allocated = 0;
	mem->stats.blocks_max = 0;
	mem->stats.bytes = 0;
	mem->stats.maxbytes = 0;

#ifdef DEBUG_POOL
	log_debug("Created mempool %s", name);
#endif

	return mem;
}

static void _free_blocks(struct pool *p, struct block *b)
{
	struct block *n;

	while (b) {
		p->stats.bytes -= b->size;
		p->stats.blocks_allocated--;

		n = b->next;
		dbg_free(b->data);
		dbg_free(b);
		b = n;
	}
}

static void _pool_stats(struct pool *p, const char *action)
{
#ifdef DEBUG_POOL
	log_debug("%s mempool %s: %u/%u bytes, %u/%u blocks, "
		  "%u allocations)", action, p->name, p->stats.bytes,
		  p->stats.maxbytes, p->stats.blocks_allocated,
		  p->stats.blocks_max, p->stats.block_serialno);
#else
	;
#endif
}

void pool_destroy(struct pool *p)
{
	_pool_stats(p, "Destroying");
	_free_blocks(p, p->blocks);
	dbg_free(p);
}

void *pool_alloc(struct pool *p, size_t s)
{
	return pool_alloc_aligned(p, s, DEFAULT_ALIGNMENT);
}

static void _append_block(struct pool *p, struct block *b)
{
	if (p->tail) {
		p->tail->next = b;
		p->tail = b;
	} else
		p->blocks = p->tail = b;

	p->stats.block_serialno++;
	p->stats.blocks_allocated++;
	if (p->stats.blocks_allocated > p->stats.blocks_max)
		p->stats.blocks_max = p->stats.blocks_allocated;

	p->stats.bytes += b->size;
	if (p->stats.bytes > p->stats.maxbytes)
		p->stats.maxbytes = p->stats.bytes;
}

static struct block *_new_block(size_t s, unsigned alignment)
{
	static const char *_oom = "Out of memory";

	/* FIXME: I'm currently ignoring the alignment arg. */
	size_t len = sizeof(struct block) + s;
	struct block *b = dbg_malloc(len);

	/*
	 * Too lazy to implement alignment for debug version, and
	 * I don't think LVM will use anything but default
	 * align.
	 */
	assert(alignment == DEFAULT_ALIGNMENT);

	if (!b) {
		log_err(_oom);
		return NULL;
	}

	if (!(b->data = dbg_malloc(s))) {
		log_err(_oom);
		dbg_free(b);
		return NULL;
	}

	b->next = NULL;
	b->size = s;

	return b;
}

void *pool_alloc_aligned(struct pool *p, size_t s, unsigned alignment)
{
	struct block *b = _new_block(s, alignment);

	if (!b)
		return NULL;

	_append_block(p, b);

	return b->data;
}

void pool_empty(struct pool *p)
{
	_pool_stats(p, "Emptying");
	_free_blocks(p, p->blocks);
	p->blocks = p->tail = NULL;
}

void pool_free(struct pool *p, void *ptr)
{
	struct block *b, *prev = NULL;

	_pool_stats(p, "Freeing (before)");

	for (b = p->blocks; b; b = b->next) {
		if (b->data == ptr)
			break;
		prev = b;
	}

	/*
	 * If this fires then you tried to free a
	 * pointer that either wasn't from this
	 * pool, or isn't the start of a block.
	 */
	assert(b);

	_free_blocks(p, b);

	if (prev) {
		p->tail = prev;
		prev->next = NULL;
	} else
		p->blocks = p->tail = NULL;

	_pool_stats(p, "Freeing (after)");
}

int pool_begin_object(struct pool *p, size_t init_size)
{
	assert(!p->begun);
	p->begun = 1;
	return 1;
}

int pool_grow_object(struct pool *p, const void *buffer, size_t delta)
{
	struct block *new;
	size_t size = delta;

	assert(p->begun);

	if (p->object)
		size += p->object->size;

	if (!(new = _new_block(size, DEFAULT_ALIGNMENT))) {
		log_err("Couldn't extend object.");
		return 0;
	}

	if (p->object) {
		memcpy(new->data, p->object->data, p->object->size);
		dbg_free(p->object->data);
		dbg_free(p->object);
	}
	p->object = new;

	memcpy(new->data + size - delta, buffer, delta);

	return 1;
}

void *pool_end_object(struct pool *p)
{
	assert(p->begun);
	_append_block(p, p->object);

	p->begun = 0;
	p->object = NULL;
	return p->tail->data;
}

void pool_abandon_object(struct pool *p)
{
	assert(p->begun);
	dbg_free(p->object);
	p->begun = 0;
	p->object = NULL;
}
