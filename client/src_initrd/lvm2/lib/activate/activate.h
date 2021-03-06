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

#ifndef LVM_ACTIVATE_H
#define LVM_ACTIVATE_H

#include "metadata.h"

#ifdef DEVMAPPER_SUPPORT
#  include <libdevmapper.h>
#endif

struct lvinfo {
	int exists;
	int suspended;
	unsigned int open_count;
	int major;
	int minor;
	int read_only;
};

void set_activation(int activation);
int activation(void);

int driver_version(char *version, size_t size);
int library_version(char *version, size_t size);
int lvm1_present(struct cmd_context *cmd);

int target_present(const char *target_name);

void activation_exit(void);

int lv_suspend(struct cmd_context *cmd, const char *lvid_s);
int lv_suspend_if_active(struct cmd_context *cmd, const char *lvid_s);
int lv_resume(struct cmd_context *cmd, const char *lvid_s);
int lv_resume_if_active(struct cmd_context *cmd, const char *lvid_s);
int lv_activate(struct cmd_context *cmd, const char *lvid_s);
int lv_activate_with_filter(struct cmd_context *cmd, const char *lvid_s);
int lv_deactivate(struct cmd_context *cmd, const char *lvid_s);

int lv_mknodes(struct cmd_context *cmd, const struct logical_volume *lv);

/*
 * Returns 1 if info structure has been populated, else 0.
 */
int lv_info(const struct logical_volume *lv, struct lvinfo *info,
	    int with_open_count);
int lv_info_by_lvid(struct cmd_context *cmd, const char *lvid_s,
		    struct lvinfo *info, int with_open_count);

/*
 * Returns 1 if activate_lv has been set: 1 = activate; 0 = don't.
 */
int lv_activation_filter(struct cmd_context *cmd, const char *lvid_s,
			 int *activate_lv);

/*
 * Returns 1 if percent has been set, else 0.
 */
int lv_snapshot_percent(struct logical_volume *lv, float *percent);
int lv_mirror_percent(struct logical_volume *lv, int wait, float *percent,
		      uint32_t *event_nr);

/*
 * Return number of LVs in the VG that are active.
 */
int lvs_in_vg_activated(struct volume_group *vg);
int lvs_in_vg_opened(struct volume_group *vg);

int lv_setup_cow_store(struct logical_volume *lv);

#endif
