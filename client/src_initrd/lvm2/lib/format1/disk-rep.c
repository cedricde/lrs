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
#include "disk-rep.h"
#include "pool.h"
#include "xlate.h"
#include "filter.h"
#include "lvmcache.h"

#include <fcntl.h>

#define fail do {stack; return 0;} while(0)
#define xx16(v) disk->v = xlate16(disk->v)
#define xx32(v) disk->v = xlate32(disk->v)
#define xx64(v) disk->v = xlate64(disk->v)

/*
 * Functions to perform the endian conversion
 * between disk and core.  The same code works
 * both ways of course.
 */
static void _xlate_pvd(struct pv_disk *disk)
{
	xx16(version);

	xx32(pv_on_disk.base);
	xx32(pv_on_disk.size);
	xx32(vg_on_disk.base);
	xx32(vg_on_disk.size);
	xx32(pv_uuidlist_on_disk.base);
	xx32(pv_uuidlist_on_disk.size);
	xx32(lv_on_disk.base);
	xx32(lv_on_disk.size);
	xx32(pe_on_disk.base);
	xx32(pe_on_disk.size);

	xx32(pv_major);
	xx32(pv_number);
	xx32(pv_status);
	xx32(pv_allocatable);
	xx32(pv_size);
	xx32(lv_cur);
	xx32(pe_size);
	xx32(pe_total);
	xx32(pe_allocated);
	xx32(pe_start);
}

static void _xlate_lvd(struct lv_disk *disk)
{
	xx32(lv_access);
	xx32(lv_status);
	xx32(lv_open);
	xx32(lv_dev);
	xx32(lv_number);
	xx32(lv_mirror_copies);
	xx32(lv_recovery);
	xx32(lv_schedule);
	xx32(lv_size);
	xx32(lv_snapshot_minor);
	xx16(lv_chunk_size);
	xx16(dummy);
	xx32(lv_allocated_le);
	xx32(lv_stripes);
	xx32(lv_stripesize);
	xx32(lv_badblock);
	xx32(lv_allocation);
	xx32(lv_io_timeout);
	xx32(lv_read_ahead);
}

static void _xlate_vgd(struct vg_disk *disk)
{
	xx32(vg_number);
	xx32(vg_access);
	xx32(vg_status);
	xx32(lv_max);
	xx32(lv_cur);
	xx32(lv_open);
	xx32(pv_max);
	xx32(pv_cur);
	xx32(pv_act);
	xx32(dummy);
	xx32(vgda);
	xx32(pe_size);
	xx32(pe_total);
	xx32(pe_allocated);
	xx32(pvg_total);
}

static void _xlate_extents(struct pe_disk *extents, uint32_t count)
{
	int i;

	for (i = 0; i < count; i++) {
		extents[i].lv_num = xlate16(extents[i].lv_num);
		extents[i].le_num = xlate16(extents[i].le_num);
	}
}

/*
 * Handle both minor metadata formats.
 */
static int _munge_formats(struct pv_disk *pvd)
{
	uint32_t pe_start;
	int b, e;

	switch (pvd->version) {
	case 1:
		pvd->pe_start = ((pvd->pe_on_disk.base +
				  pvd->pe_on_disk.size) >> SECTOR_SHIFT);
		break;

	case 2:
		pvd->version = 1;
		pe_start = pvd->pe_start << SECTOR_SHIFT;
		pvd->pe_on_disk.size = pe_start - pvd->pe_on_disk.base;
		break;

	default:
		return 0;
	}

        /* UUID too long? */
        if (pvd->pv_uuid[ID_LEN]) {
		/* Retain ID_LEN chars from end */
                for (e = ID_LEN; e < sizeof(pvd->pv_uuid); e++) {
                        if (!pvd->pv_uuid[e]) {
                                e--;
                                break;
                        }
                }
		for (b = 0; b < ID_LEN; b++) {
			pvd->pv_uuid[b] = pvd->pv_uuid[++e - ID_LEN];
			/* FIXME Remove all invalid chars */
			if (pvd->pv_uuid[b] == '/')
				pvd->pv_uuid[b] = '#';
		}
		memset(&pvd->pv_uuid[ID_LEN], 0, sizeof(pvd->pv_uuid) - ID_LEN);
        }

	/* If UUID is missing, create one */
	if (pvd->pv_uuid[0] == '\0')
		uuid_from_num(pvd->pv_uuid, pvd->pv_number);

	return 1;
}

/* 
 * If exported, remove "PV_EXP" from end of VG name 
 */
static void _munge_exported_vg(struct pv_disk *pvd)
{
	int l;
	size_t s;

	/* Return if PV not in a VG */
	if ((!*pvd->vg_name))
		return;
	/* FIXME also check vgd->status & VG_EXPORTED? */

	l = strlen(pvd->vg_name);
	s = sizeof(EXPORTED_TAG);
	if (!strncmp(pvd->vg_name + l - s + 1, EXPORTED_TAG, s)) {
		pvd->vg_name[l - s + 1] = '\0';
                pvd->pv_status |= VG_EXPORTED;
        }
}

int munge_pvd(struct device *dev, struct pv_disk *pvd)
{
	_xlate_pvd(pvd);

	if (pvd->id[0] != 'H' || pvd->id[1] != 'M') {
		log_very_verbose("%s does not have a valid LVM1 PV identifier",
				 dev_name(dev));
		return 0;
	}

	if (!_munge_formats(pvd)) {
		log_very_verbose("format1: Unknown metadata version %d "
				 "found on %s", pvd->version, dev_name(dev));
		return 0;
	}

	/* If VG is exported, set VG name back to the real name */
	_munge_exported_vg(pvd);

	return 1;
}

static int _read_pvd(struct device *dev, struct pv_disk *pvd)
{
	if (!dev_read(dev, UINT64_C(0), sizeof(*pvd), pvd)) {
		log_very_verbose("Failed to read PV data from %s",
				 dev_name(dev));
		return 0;
	}

	return munge_pvd(dev, pvd);
}

static int _read_lvd(struct device *dev, uint64_t pos, struct lv_disk *disk)
{
	if (!dev_read(dev, pos, sizeof(*disk), disk))
		fail;

	_xlate_lvd(disk);

	return 1;
}

static int _read_vgd(struct disk_list *data)
{
	struct vg_disk *vgd = &data->vgd;
	uint64_t pos = data->pvd.vg_on_disk.base;
	if (!dev_read(data->dev, pos, sizeof(*vgd), vgd))
		fail;

	_xlate_vgd(vgd);

	if ((vgd->lv_max > MAX_LV) || (vgd->pv_max > MAX_PV))
		fail;
		
	/* If UUID is missing, create one */
	if (vgd->vg_uuid[0] == '\0')
		uuid_from_num(vgd->vg_uuid, vgd->vg_number);

	return 1;
}

static int _read_uuids(struct disk_list *data)
{
	int num_read = 0;
	struct uuid_list *ul;
	char buffer[NAME_LEN];
	uint64_t pos = data->pvd.pv_uuidlist_on_disk.base;
	uint64_t end = pos + data->pvd.pv_uuidlist_on_disk.size;

	while (pos < end && num_read < data->vgd.pv_cur) {
		if (!dev_read(data->dev, pos, sizeof(buffer), buffer))
			fail;

		if (!(ul = pool_alloc(data->mem, sizeof(*ul))))
			fail;

		memcpy(ul->uuid, buffer, NAME_LEN);
		ul->uuid[NAME_LEN - 1] = '\0';

		list_add(&data->uuids, &ul->list);

		pos += NAME_LEN;
		num_read++;
	}

	return 1;
}

static inline int _check_lvd(struct lv_disk *lvd)
{
	return !(lvd->lv_name[0] == '\0');
}

static int _read_lvs(struct disk_list *data)
{
	unsigned int i, read = 0;
	uint64_t pos;
	struct lvd_list *ll;
	struct vg_disk *vgd = &data->vgd;

	for (i = 0; (i < vgd->lv_max) && (read < vgd->lv_cur); i++) {
		pos = data->pvd.lv_on_disk.base + (i * sizeof(struct lv_disk));
		ll = pool_alloc(data->mem, sizeof(*ll));

		if (!ll)
			fail;

		if (!_read_lvd(data->dev, pos, &ll->lvd))
			fail;

		if (!_check_lvd(&ll->lvd))
			continue;

		read++;
		list_add(&data->lvds, &ll->list);
	}

	return 1;
}

static int _read_extents(struct disk_list *data)
{
	size_t len = sizeof(struct pe_disk) * data->pvd.pe_total;
	struct pe_disk *extents = pool_alloc(data->mem, len);
	uint64_t pos = data->pvd.pe_on_disk.base;

	if (!extents)
		fail;

	if (!dev_read(data->dev, pos, len, extents))
		fail;

	_xlate_extents(extents, data->pvd.pe_total);
	data->extents = extents;

	return 1;
}

static struct disk_list *__read_disk(const struct format_type *fmt,
				     struct device *dev, struct pool *mem,
				     const char *vg_name)
{
	struct disk_list *dl = pool_alloc(mem, sizeof(*dl));
	const char *name = dev_name(dev);
	struct lvmcache_info *info;

	if (!dl) {
		stack;
		return NULL;
	}

	dl->dev = dev;
	dl->mem = mem;
	list_init(&dl->uuids);
	list_init(&dl->lvds);

	if (!_read_pvd(dev, &dl->pvd)) {
		stack;
		goto bad;
	}

	if (!(info = lvmcache_add(fmt->labeller, dl->pvd.pv_uuid, dev,
				  dl->pvd.vg_name, NULL)))
		stack;
	else {
		info->device_size = xlate32(dl->pvd.pv_size) << SECTOR_SHIFT;
		list_init(&info->mdas);
		info->status &= ~CACHE_INVALID;
	}

	/*
	 * is it an orphan ?
	 */
	if (!*dl->pvd.vg_name) {
		log_very_verbose("%s is not a member of any format1 VG", name);

		/* Update VG cache */
		/* vgcache_add(dl->pvd.vg_name, NULL, dev, fmt); */

		return (vg_name) ? NULL : dl;
	}

	if (!_read_vgd(dl)) {
		log_error("Failed to read VG data from PV (%s)", name);
		goto bad;
	}

	/* Update VG cache with what we found */
	/* vgcache_add(dl->pvd.vg_name, dl->vgd.vg_uuid, dev, fmt); */

	if (vg_name && strcmp(vg_name, dl->pvd.vg_name)) {
		log_very_verbose("%s is not a member of the VG %s",
				 name, vg_name);
		goto bad;
	}

	if (!_read_uuids(dl)) {
		log_error("Failed to read PV uuid list from %s", name);
		goto bad;
	}

	if (!_read_lvs(dl)) {
		log_error("Failed to read LV's from %s", name);
		goto bad;
	}

	if (!_read_extents(dl)) {
		log_error("Failed to read extents from %s", name);
		goto bad;
	}

	log_very_verbose("Found %s in %sVG %s", name,
			 (dl->vgd.vg_status & VG_EXPORTED) ? "exported " : "",
			 dl->pvd.vg_name);

	return dl;

      bad:
	pool_free(dl->mem, dl);
	return NULL;
}

struct disk_list *read_disk(const struct format_type *fmt, struct device *dev,
			    struct pool *mem, const char *vg_name)
{
	struct disk_list *r;

	if (!dev_open(dev)) {
		stack;
		return NULL;
	}

	r = __read_disk(fmt, dev, mem, vg_name);

	if (!dev_close(dev))
		stack;

	return r;
}

static void _add_pv_to_list(struct list *head, struct disk_list *data)
{
	struct list *pvdh;
	struct pv_disk *pvd;

	list_iterate(pvdh, head) {
		pvd = &list_item(pvdh, struct disk_list)->pvd;
		if (!strncmp(data->pvd.pv_uuid, pvd->pv_uuid,
			     sizeof(pvd->pv_uuid))) {
			if (MAJOR(data->dev->dev) != md_major()) {
				log_very_verbose("Ignoring duplicate PV %s on "
						 "%s", pvd->pv_uuid,
						 dev_name(data->dev));
				return;
			}
			log_very_verbose("Duplicate PV %s - using md %s",
					 pvd->pv_uuid, dev_name(data->dev));
			list_del(pvdh);
			break;
		}
	}
	list_add(head, &data->list);
}

/*
 * Build a list of pv_d's structures, allocated from mem.
 * We keep track of the first object allocated form the pool
 * so we can free off all the memory if something goes wrong.
 */
int read_pvs_in_vg(const struct format_type *fmt, const char *vg_name,
		   struct dev_filter *filter, struct pool *mem,
		   struct list *head)
{
	struct dev_iter *iter;
	struct device *dev;
	struct disk_list *data = NULL;
	struct list *vgih;
	struct lvmcache_vginfo *vginfo;

	/* Fast path if we already saw this VG and cached the list of PVs */
	if (vg_name && (vginfo = vginfo_from_vgname(vg_name)) &&
	    vginfo->infos.n) {
		list_iterate(vgih, &vginfo->infos) {
			dev = list_item(vgih, struct lvmcache_info)->dev;
			if (dev && !(data = read_disk(fmt, dev, mem, vg_name)))
				break;
			_add_pv_to_list(head, data);
		}

		/* Did we find the whole VG? */
		if (!vg_name || !*vg_name ||
		    (data && *data->pvd.vg_name &&
		     list_size(head) == data->vgd.pv_cur))
			return 1;

		/* Failed */
		list_init(head);
		/* vgcache_del(vg_name); */
	}

	if (!(iter = dev_iter_create(filter))) {
		log_error("read_pvs_in_vg: dev_iter_create failed");
		return 0;
	}

	/* Otherwise do a complete scan */
	for (dev = dev_iter_get(iter); dev; dev = dev_iter_get(iter)) {
		if ((data = read_disk(fmt, dev, mem, vg_name))) {
			_add_pv_to_list(head, data);
		}
	}
	dev_iter_destroy(iter);

	if (list_empty(head))
		return 0;

	return 1;
}

static int _write_vgd(struct disk_list *data)
{
	struct vg_disk *vgd = &data->vgd;
	uint64_t pos = data->pvd.vg_on_disk.base;

	_xlate_vgd(vgd);
	if (!dev_write(data->dev, pos, sizeof(*vgd), vgd))
		fail;

	_xlate_vgd(vgd);

	return 1;
}

static int _write_uuids(struct disk_list *data)
{
	struct uuid_list *ul;
	struct list *uh;
	uint64_t pos = data->pvd.pv_uuidlist_on_disk.base;
	uint64_t end = pos + data->pvd.pv_uuidlist_on_disk.size;

	list_iterate(uh, &data->uuids) {
		if (pos >= end) {
			log_error("Too many uuids to fit on %s",
				  dev_name(data->dev));
			return 0;
		}

		ul = list_item(uh, struct uuid_list);
		if (!dev_write(data->dev, pos, NAME_LEN, ul->uuid))
			fail;

		pos += NAME_LEN;
	}

	return 1;
}

static int _write_lvd(struct device *dev, uint64_t pos, struct lv_disk *disk)
{
	_xlate_lvd(disk);
	if (!dev_write(dev, pos, sizeof(*disk), disk))
		fail;

	_xlate_lvd(disk);

	return 1;
}

static int _write_lvs(struct disk_list *data)
{
	struct list *lvh;
	uint64_t pos, offset;

	pos = data->pvd.lv_on_disk.base;

	if (!dev_zero(data->dev, pos, data->pvd.lv_on_disk.size)) {
		log_error("Couldn't zero lv area on device '%s'",
			  dev_name(data->dev));
		return 0;
	}

	list_iterate(lvh, &data->lvds) {
		struct lvd_list *ll = list_item(lvh, struct lvd_list);

		offset = sizeof(struct lv_disk) * ll->lvd.lv_number;
		if (offset + sizeof(struct lv_disk) > data->pvd.lv_on_disk.size) {
			log_error("lv_number %d too large", ll->lvd.lv_number);
			return 0;
		}

		if (!_write_lvd(data->dev, pos + offset, &ll->lvd))
			fail;
	}

	return 1;
}

static int _write_extents(struct disk_list *data)
{
	size_t len = sizeof(struct pe_disk) * data->pvd.pe_total;
	struct pe_disk *extents = data->extents;
	uint64_t pos = data->pvd.pe_on_disk.base;

	_xlate_extents(extents, data->pvd.pe_total);
	if (!dev_write(data->dev, pos, len, extents))
		fail;

	_xlate_extents(extents, data->pvd.pe_total);

	return 1;
}

static int _write_pvd(struct disk_list *data)
{
	char *buf;
	uint64_t pos = data->pvd.pv_on_disk.base;
	size_t size = data->pvd.pv_on_disk.size;

	if (size < sizeof(struct pv_disk)) {
		log_error("Invalid PV structure size.");
		return 0;
	}

	/* Make sure that the gap between the PV structure and
	   the next one is zeroed in order to make non LVM tools
	   happy (idea from AED) */
	buf = dbg_malloc(size);
	if (!buf) {
		log_err("Couldn't allocate temporary PV buffer.");
		return 0;
	}

	memset(buf, 0, size);
	memcpy(buf, &data->pvd, sizeof(struct pv_disk));

	_xlate_pvd((struct pv_disk *) buf);
	if (!dev_write(data->dev, pos, size, buf)) {
		dbg_free(buf);
		fail;
	}

	dbg_free(buf);
	return 1;
}

/*
 * assumes the device has been opened.
 */
static int __write_all_pvd(const struct format_type *fmt,
			   struct disk_list *data)
{
	const char *pv_name = dev_name(data->dev);

	if (!_write_pvd(data)) {
		log_error("Failed to write PV structure onto %s", pv_name);
		return 0;
	}

	/* vgcache_add(data->pvd.vg_name, data->vgd.vg_uuid, data->dev, fmt); */
	/*
	 * Stop here for orphan pv's.
	 */
	if (data->pvd.vg_name[0] == '\0') {
		/* if (!test_mode())
		   vgcache_add(data->pvd.vg_name, NULL, data->dev, fmt); */
		return 1;
	}

	/* if (!test_mode())
	   vgcache_add(data->pvd.vg_name, data->vgd.vg_uuid, data->dev,
	   fmt); */

	if (!_write_vgd(data)) {
		log_error("Failed to write VG data to %s", pv_name);
		return 0;
	}

	if (!_write_uuids(data)) {
		log_error("Failed to write PV uuid list to %s", pv_name);
		return 0;
	}

	if (!_write_lvs(data)) {
		log_error("Failed to write LV's to %s", pv_name);
		return 0;
	}

	if (!_write_extents(data)) {
		log_error("Failed to write extents to %s", pv_name);
		return 0;
	}

	return 1;
}

/*
 * opens the device and hands to the above fn.
 */
static int _write_all_pvd(const struct format_type *fmt, struct disk_list *data)
{
	int r;

	if (!dev_open(data->dev)) {
		stack;
		return 0;
	}

	r = __write_all_pvd(fmt, data);

	if (!dev_close(data->dev))
		stack;

	return r;
}

/*
 * Writes all the given pv's to disk.  Does very
 * little sanity checking, so make sure correct
 * data is passed to here.
 */
int write_disks(const struct format_type *fmt, struct list *pvs)
{
	struct list *pvh;
	struct disk_list *dl;

	list_iterate(pvh, pvs) {
		dl = list_item(pvh, struct disk_list);
		if (!(_write_all_pvd(fmt, dl)))
			fail;

		log_very_verbose("Successfully wrote data to %s",
				 dev_name(dl->dev));
	}

	return 1;
}
