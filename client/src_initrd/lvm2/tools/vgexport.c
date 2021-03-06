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

#include "tools.h"

static int vgexport_single(struct cmd_context *cmd, const char *vg_name,
			   struct volume_group *vg, int consistent,
			   void *handle)
{
	if (!vg) {
		log_error("Unable to find volume group \"%s\"", vg_name);
		goto error;
	}

	if (!consistent) {
		log_error("Volume group %s inconsistent", vg_name);
		goto error;
	}

	if (vg->status & EXPORTED_VG) {
		log_error("Volume group \"%s\" is already exported", vg_name);
		goto error;
	}

	if (!(vg->status & LVM_WRITE)) {
		log_error("Volume group \"%s\" is read-only", vg_name);
		goto error;
	}

	if (lvs_in_vg_activated(vg)) {
		log_error("Volume group \"%s\" has active logical volumes",
			  vg_name);
		goto error;
	}

	if (!archive(vg))
		goto error;

	vg->status |= EXPORTED_VG;

	if (!vg_write(vg) || !vg_commit(vg))
		goto error;

	backup(vg);

	log_print("Volume group \"%s\" successfully exported", vg->name);

	return ECMD_PROCESSED;

      error:
	return ECMD_FAILED;
}

int vgexport(struct cmd_context *cmd, int argc, char **argv)
{
	if (!argc && !arg_count(cmd, all_ARG)) {
		log_error("Please supply volume groups or use -a for all.");
		return ECMD_FAILED;
	}

	if (argc && arg_count(cmd, all_ARG)) {
		log_error("No arguments permitted when using -a for all.");
		return ECMD_FAILED;
	}

	return process_each_vg(cmd, argc, argv, LCK_VG_WRITE, 1, NULL,
			       &vgexport_single);
}
