/*
 * Copyright (C) 1997-2004 Sistina Software, Inc. All rights reserved.  
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
#include "label.h"
#include "metadata.h"
#include "hash.h"
#include "limits.h"
#include "list.h"
#include "display.h"
#include "toolcontext.h"
#include "lvmcache.h"
#include "disk_rep.h"
#include "format_pool.h"
#include "pool_label.h"

#define FMT_POOL_NAME "pool"

/* Must be called after pvs are imported */
static struct user_subpool *_build_usp(struct list *pls, struct pool *mem,
				       int *sps)
{

	struct list *plhs;
	struct pool_list *pl;
	struct user_subpool *usp = NULL, *cur_sp = NULL;
	struct user_device *cur_dev = NULL;

	/*
	 * FIXME: Need to do some checks here - I'm tempted to add a
	 * user_pool structure and build the entire thing to check against.
	 */
	list_iterate(plhs, pls) {
		pl = list_item(plhs, struct pool_list);

		*sps = pl->pd.pl_subpools;
		if (!usp && (!(usp = pool_zalloc(mem, sizeof(*usp) * (*sps))))) {
			log_error("Unable to allocate %d subpool structures",
				  *sps);
			return 0;
		}

		if (cur_sp != &usp[pl->pd.pl_sp_id]) {
			cur_sp = &usp[pl->pd.pl_sp_id];

			cur_sp->id = pl->pd.pl_sp_id;
			cur_sp->striping = pl->pd.pl_striping;
			cur_sp->num_devs = pl->pd.pl_sp_devs;
			cur_sp->type = pl->pd.pl_sp_type;
			cur_sp->initialized = 1;
		}

		if (!cur_sp->devs &&
		    (!(cur_sp->devs =
		       pool_zalloc(mem,
				   sizeof(*usp->devs) * pl->pd.pl_sp_devs)))) {

			log_error("Unable to allocate %d pool_device "
				  "structures", pl->pd.pl_sp_devs);
			return 0;
		}
		cur_dev = &cur_sp->devs[pl->pd.pl_sp_devid];
		cur_dev->sp_id = cur_sp->id;
		cur_dev->devid = pl->pd.pl_sp_id;
		cur_dev->blocks = pl->pd.pl_blocks;
		cur_dev->pv = pl->pv;
		cur_dev->initialized = 1;

	}

	return usp;
}

static int _check_usp(char *vgname, struct user_subpool *usp, int sp_count)
{
	int i, j;

	for (i = 0; i < sp_count; i++) {
		if (!usp[i].initialized) {
			log_error("Missing subpool %d in pool %s", i, vgname);
			return 0;
		}
		for (j = 0; j < usp[i].num_devs; j++) {
			if (!usp[i].devs[j].initialized) {
				log_error("Missing device %d for subpool %d"
					  " in pool %s", j, i, vgname);
				return 0;
			}

		}
	}

	return 1;
}

static struct volume_group *_build_vg_from_pds(struct format_instance
					       *fid, struct pool *mem,
					       struct list *pds)
{
	struct pool *smem = fid->fmt->cmd->mem;
	struct volume_group *vg = NULL;
	struct user_subpool *usp = NULL;
	int sp_count;

	if (!(vg = pool_zalloc(smem, sizeof(*vg)))) {
		log_error("Unable to allocate volume group structure");
		return NULL;
	}

	vg->cmd = fid->fmt->cmd;
	vg->fid = fid;
	vg->name = NULL;
	vg->status = 0;
	vg->extent_count = 0;
	vg->pv_count = 0;
	vg->lv_count = 0;
	vg->snapshot_count = 0;
	vg->seqno = 1;
	vg->system_id = NULL;
	list_init(&vg->pvs);
	list_init(&vg->lvs);
	list_init(&vg->snapshots);
	list_init(&vg->tags);

	if (!import_pool_vg(vg, smem, pds)) {
		stack;
		return NULL;
	}

	if (!import_pool_pvs(fid->fmt, vg, &vg->pvs, smem, pds)) {
		stack;
		return NULL;
	}

	if (!import_pool_lvs(vg, smem, pds)) {
		stack;
		return NULL;
	}

	/*
	 * I need an intermediate subpool structure that contains all the
	 * relevant info for this.  Then i can iterate through the subpool
	 * structures for checking, and create the segments
	 */
	if (!(usp = _build_usp(pds, mem, &sp_count))) {
		stack;
		return NULL;
	}

	/*
	 * check the subpool structures - we can't handle partial VGs in
	 * the pool format, so this will error out if we're missing PVs
	 */
	if (!_check_usp(vg->name, usp, sp_count)) {
		stack;
		return NULL;
	}

	if (!import_pool_segments(&vg->lvs, smem, usp, sp_count)) {
		stack;
		return NULL;
	}

	return vg;
}

static struct volume_group *_vg_read(struct format_instance *fid,
				     const char *vg_name,
				     struct metadata_area *mda)
{
	struct pool *mem = pool_create("pool vg_read", 1024);
	struct list pds;
	struct volume_group *vg = NULL;

	list_init(&pds);

	/* We can safely ignore the mda passed in */

	if (!mem) {
		stack;
		return NULL;
	}

	/* Strip dev_dir if present */
	vg_name = strip_dir(vg_name, fid->fmt->cmd->dev_dir);

	/* Read all the pvs in the vg */
	if (!read_pool_pds(fid->fmt, vg_name, mem, &pds)) {
		stack;
		goto out;
	}

	/* Do the rest of the vg stuff */
	if (!(vg = _build_vg_from_pds(fid, mem, &pds))) {
		stack;
		goto out;
	}

      out:
	pool_destroy(mem);
	return vg;
}

static int _pv_setup(const struct format_type *fmt,
		     uint64_t pe_start, uint32_t extent_count,
		     uint32_t extent_size,
		     int pvmetadatacopies,
		     uint64_t pvmetadatasize, struct list *mdas,
		     struct physical_volume *pv, struct volume_group *vg)
{
	return 1;
}

static int _pv_read(const struct format_type *fmt, const char *pv_name,
		    struct physical_volume *pv, struct list *mdas)
{
	struct pool *mem = pool_create("pool pv_read", 1024);
	struct pool_list *pl;
	struct device *dev;
	int r = 0;

	log_very_verbose("Reading physical volume data %s from disk", pv_name);

	if (!mem) {
		stack;
		return 0;
	}

	if (!(dev = dev_cache_get(pv_name, fmt->cmd->filter))) {
		stack;
		goto out;
	}

	/*
	 * I need to read the disk and populate a pv structure here
	 * I'll probably need to abstract some of this later for the
	 * vg_read code
	 */
	if (!(pl = read_pool_disk(fmt, dev, mem, NULL))) {
		stack;
		goto out;
	}

	if (!import_pool_pv(fmt, fmt->cmd->mem, NULL, pv, pl)) {
		stack;
		goto out;
	}

	pv->fmt = fmt;

	r = 1;

      out:
	pool_destroy(mem);
	return r;
}

/* *INDENT-OFF* */
static struct metadata_area_ops _metadata_format_pool_ops = {
	vg_read:_vg_read,
};
/* *INDENT-ON* */

static struct format_instance *_create_instance(const struct format_type *fmt,
						const char *vgname,
						void *private)
{
	struct format_instance *fid;
	struct metadata_area *mda;

	if (!(fid = pool_zalloc(fmt->cmd->mem, sizeof(*fid)))) {
		log_error("Unable to allocate format instance structure for "
			  "pool format");
		return NULL;
	}

	fid->fmt = fmt;
	list_init(&fid->metadata_areas);

	/* Define a NULL metadata area */
	if (!(mda = pool_zalloc(fmt->cmd->mem, sizeof(*mda)))) {
		log_error("Unable to allocate metadata area structure "
			  "for pool format");
		pool_free(fmt->cmd->mem, fid);
		return NULL;
	}

	mda->ops = &_metadata_format_pool_ops;
	mda->metadata_locn = NULL;
	list_add(&fid->metadata_areas, &mda->list);

	return fid;
}

static void _destroy_instance(struct format_instance *fid)
{
	return;
}

static void _destroy(const struct format_type *fmt)
{
	dbg_free((void *) fmt);
}

/* *INDENT-OFF* */
static struct format_handler _format_pool_ops = {
	pv_read:_pv_read,
	pv_setup:_pv_setup,
	create_instance:_create_instance,
	destroy_instance:_destroy_instance,
	destroy:_destroy,
};
/* *INDENT-ON */

#ifdef POOL_INTERNAL
struct format_type *init_pool_format(struct cmd_context *cmd)
#else				/* Shared */
struct format_type *init_format(struct cmd_context *cmd);
struct format_type *init_format(struct cmd_context *cmd)
#endif
{
	struct format_type *fmt = dbg_malloc(sizeof(*fmt));

	if (!fmt) {
		log_error("Unable to allocate format type structure for pool "
			  "format");
		return NULL;
	}

	fmt->cmd = cmd;
	fmt->ops = &_format_pool_ops;
	fmt->name = FMT_POOL_NAME;
	fmt->alias = NULL;
	fmt->features = 0;
	fmt->private = NULL;

	if (!(fmt->labeller = pool_labeller_create(fmt))) {
		log_error("Couldn't create pool label handler.");
		return NULL;
	}

	if (!(label_register_handler(FMT_POOL_NAME, fmt->labeller))) {
		log_error("Couldn't register pool label handler.");
		return NULL;
	}

	log_very_verbose("Initialised format: %s", fmt->name);

	return fmt;
}
