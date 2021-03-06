/*
 * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
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

#include <pthread.h>
#include <sys/types.h>
#include <sys/utsname.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <fcntl.h>
#include <string.h>
#include <stddef.h>
#include <stdint.h>
#include <unistd.h>
#include <errno.h>
#include <syslog.h>
#include <assert.h>

#include "libdlm.h"
#include "clvm.h"
#include "clvmd-comms.h"
#include "clvmd.h"
#include "lvm-functions.h"

/* LVM2 headers */
#include "toolcontext.h"
#include "log.h"
#include "activate.h"
#include "hash.h"
#include "locking.h"

static struct cmd_context *cmd = NULL;
static struct hash_table *lv_hash = NULL;
static pthread_mutex_t lv_hash_lock;

struct lv_info {
	int lock_id;
	int lock_mode;
};

/* Return the mode a lock is currently held at (or -1 if not held) */
static int get_current_lock(char *resource)
{
	struct lv_info *lvi;

	pthread_mutex_lock(&lv_hash_lock);
	lvi = hash_lookup(lv_hash, resource);
	pthread_mutex_unlock(&lv_hash_lock);
	if (lvi) {
		return lvi->lock_mode;
	} else {
		return -1;
	}
}

/* Called at shutdown to tidy the lockspace */
void unlock_all()
{
	struct hash_node *v;

	pthread_mutex_lock(&lv_hash_lock);
	hash_iterate(v, lv_hash) {
		struct lv_info *lvi = hash_get_data(lv_hash, v);

		sync_unlock(hash_get_key(lv_hash, v), lvi->lock_id);
	}
	pthread_mutex_unlock(&lv_hash_lock);
}

/* Gets a real lock and keeps the info in the hash table */
int hold_lock(char *resource, int mode, int flags)
{
	int status;
	int saved_errno;
	struct lv_info *lvi;

	flags &= LKF_NOQUEUE;	/* Only LKF_NOQUEUE is valid here */

	pthread_mutex_lock(&lv_hash_lock);
	lvi = hash_lookup(lv_hash, resource);
	pthread_mutex_unlock(&lv_hash_lock);
	if (lvi) {
		/* Already exists - convert it */
		status =
		    sync_lock(resource, mode, LKF_CONVERT | flags,
			      &lvi->lock_id);
		saved_errno = errno;
		if (!status)
			lvi->lock_mode = mode;

		if (status) {
			DEBUGLOG("hold_lock. convert to %d failed: %s\n", mode,
				 strerror(errno));
		}
		errno = saved_errno;
	} else {
		lvi = malloc(sizeof(struct lv_info));
		if (!lvi)
			return -1;

		lvi->lock_mode = mode;
		status = sync_lock(resource, mode, flags, &lvi->lock_id);
		saved_errno = errno;
		if (status) {
			free(lvi);
			DEBUGLOG("hold_lock. lock at %d failed: %s\n", mode,
				 strerror(errno));
		} else {
		        pthread_mutex_lock(&lv_hash_lock);
			hash_insert(lv_hash, resource, lvi);
			pthread_mutex_unlock(&lv_hash_lock);
		}
		errno = saved_errno;
	}
	return status;
}

/* Unlock and remove it from the hash table */
int hold_unlock(char *resource)
{
	struct lv_info *lvi;
	int status;
	int saved_errno;

	pthread_mutex_lock(&lv_hash_lock);
	lvi = hash_lookup(lv_hash, resource);
	pthread_mutex_unlock(&lv_hash_lock);
	if (!lvi) {
		DEBUGLOG("hold_unlock, lock not already held\n");
		return 0;
	}

	status = sync_unlock(resource, lvi->lock_id);
	saved_errno = errno;
	if (!status) {
	    	pthread_mutex_lock(&lv_hash_lock);
		hash_remove(lv_hash, resource);
		pthread_mutex_unlock(&lv_hash_lock);
		free(lvi);
	} else {
		DEBUGLOG("hold_unlock. unlock failed(%d): %s\n", status,
			 strerror(errno));
	}

	errno = saved_errno;
	return status;
}

/* Watch the return codes here.
   liblvm API functions return 1(true) for success, 0(false) for failure and don't set errno.
   libdlm API functions return 0 for success, -1 for failure and do set errno.
   These functions here return 0 for success or >0 for failure (where the retcode is errno)
*/

/* Activate LV exclusive or non-exclusive */
static int do_activate_lv(char *resource, int mode)
{
	int oldmode;
	int status;
	int activate_lv;
	struct lvinfo lvi;

	/* Is it already open ? */
	oldmode = get_current_lock(resource);
	if (oldmode == mode) {
		return 0;	/* Nothing to do */
	}

	/* Does the config file want us to activate this LV ? */
	if (!lv_activation_filter(cmd, resource, &activate_lv))
		return EIO;

	if (!activate_lv)
		return 0;	/* Success, we did nothing! */

	/* Do we need to activate exclusively? */
	if (activate_lv == 2)
		mode = LKM_EXMODE;

	/* OK, try to get the lock */
	status = hold_lock(resource, mode, LKF_NOQUEUE);
	if (status)
		return errno;

	/* If it's suspended then resume it */
	if (!lv_info_by_lvid(cmd, resource, &lvi, 0))
		return EIO;

	if (lvi.suspended)
		if (!lv_resume(cmd, resource))
			return EIO;

	/* Now activate it */
	if (!lv_activate(cmd, resource))
		return EIO;

	return 0;
}

/* Resume the LV if it was active */
static int do_resume_lv(char *resource)
{
	int oldmode;

	/* Is it open ? */
	oldmode = get_current_lock(resource);
	if (oldmode == -1) {
		DEBUGLOG("do_deactivate_lock, lock not already held\n");
		return 0;	/* We don't need to do anything */
	}

	if (!lv_resume_if_active(cmd, resource))
		return EIO;

	return 0;
}

/* Suspend the device if active */
static int do_suspend_lv(char *resource)
{
	int oldmode;
	struct lvinfo lvi;

	/* Is it open ? */
	oldmode = get_current_lock(resource);
	if (oldmode == -1) {
		DEBUGLOG("do_suspend_lv, lock held at %d\n", oldmode);
		return 0; /* Not active, so it's OK */
	}

	/* Only suspend it if it exists */
	if (!lv_info_by_lvid(cmd, resource, &lvi, 0))
		return EIO;

	if (lvi.exists) {
		if (!lv_suspend_if_active(cmd, resource)) {
			return EIO;
		}
	}
	return 0;
}

static int do_deactivate_lv(char *resource)
{
	int oldmode;
	int status;

	/* Is it open ? */
	oldmode = get_current_lock(resource);
	if (oldmode == -1) {
		DEBUGLOG("do_deactivate_lock, lock not already held\n");
		return 0;	/* We don't need to do anything */
	}

	if (!lv_deactivate(cmd, resource))
		return EIO;

	status = hold_unlock(resource);
	if (status)
		return errno;

	return 0;
}

/* This is the LOCK_LV part that happens on all nodes in the cluster -
   it is responsible for the interaction with device-mapper and LVM */
int do_lock_lv(unsigned char command, unsigned char lock_flags, char *resource)
{
	int status = 0;

	DEBUGLOG("do_lock_lv: resource '%s', cmd = 0x%x, flags = %d\n",
		 resource, command, lock_flags);

	if (!cmd->config_valid || config_files_changed(cmd)) {
		/* Reinitialise various settings inc. logging, filters */
		if (!refresh_toolcontext(cmd)) {
			log_error("Updated config file invalid. Aborting.");
			return EINVAL;
		}
	}

	switch (command) {
	case LCK_LV_EXCLUSIVE:
		status = do_activate_lv(resource, LKM_EXMODE);
		break;

	case LCK_LV_SUSPEND:
		status = do_suspend_lv(resource);
		break;

	case LCK_UNLOCK:
	case LCK_LV_RESUME:	/* if active */
		status = do_resume_lv(resource);
		break;

	case LCK_LV_ACTIVATE:
		status = do_activate_lv(resource, LKM_CRMODE);
		break;

	case LCK_LV_DEACTIVATE:
		status = do_deactivate_lv(resource);
		break;

	default:
		DEBUGLOG("Invalid LV command 0x%x\n", command);
		status = EINVAL;
		break;
	}

	/* clean the pool for another command */
	pool_empty(cmd->mem);

	DEBUGLOG("Command return is %d\n", status);
	return status;
}

/* Functions to do on the local node only BEFORE the cluster-wide stuff above happens */
int pre_lock_lv(unsigned char command, unsigned char lock_flags, char *resource)
{
	/* Nearly all the stuff happens cluster-wide. Apart from SUSPEND. Here we get the
	   lock out on this node (because we are the node modifying the metadata)
	   before suspending cluster-wide.
	 */
	if (command == LCK_LV_SUSPEND) {
		DEBUGLOG("pre_lock_lv: resource '%s', cmd = 0x%x, flags = %d\n",
			 resource, command, lock_flags);

		if (hold_lock(resource, LKM_PWMODE, LKF_NOQUEUE))
			return errno;
	}
	return 0;
}

/* Functions to do on the local node only AFTER the cluster-wide stuff above happens */
int post_lock_lv(unsigned char command, unsigned char lock_flags,
		 char *resource)
{
	/* Opposite of above, done on resume after a metadata update */
	if (command == LCK_LV_RESUME) {
		int oldmode;

		DEBUGLOG
		    ("post_lock_lv: resource '%s', cmd = 0x%x, flags = %d\n",
		     resource, command, lock_flags);

		/* If the lock state is PW then restore it to what it was */
		oldmode = get_current_lock(resource);
		if (oldmode == LKM_PWMODE) {
			struct lvinfo lvi;

			if (!lv_info_by_lvid(cmd, resource, &lvi, 0))
				return EIO;

			if (lvi.exists) {
				if (hold_lock(resource, LKM_CRMODE, 0))
					return errno;
			} else {
				if (hold_unlock(resource))
					return errno;
			}
		}
	}
	return 0;
}

/* Check if a VG is un use by LVM1 so we don't stomp on it */
int do_check_lvm1(char *vgname)
{
	int status;

	status = check_lvm1_vg_inactive(cmd, vgname);

	return status == 1 ? 0 : EBUSY;
}

/*
 * Ideally, clvmd should be started before any LVs are active
 * but this may not be the case...
 * I suppose this also comes in handy if clvmd crashes, not that it would!
 */
static void *get_initial_state()
{
	char lv[64], vg[64], flags[25];
	char uuid[65];
	char line[255];
	FILE *lvs =
	    popen
	    ("lvm lvs --nolocking --noheadings -o vg_uuid,lv_uuid,lv_attr",
	     "r");

	if (!lvs)
		return NULL;

	while (fgets(line, sizeof(line), lvs)) {
	        if (sscanf(line, "%s %s %s\n", vg, lv, flags) == 3) {

			/* States: s:suspended a:active S:dropped snapshot I:invalid snapshot */
		        if (strlen(vg) == 38 &&                         /* is is a valid UUID ? */
			    (flags[4] == 'a' || flags[4] == 's')) {	/* is it active or suspended? */
				/* Convert hyphen-separated UUIDs into one */
				memcpy(&uuid[0], &vg[0], 6);
				memcpy(&uuid[6], &vg[7], 4);
				memcpy(&uuid[10], &vg[12], 4);
				memcpy(&uuid[14], &vg[17], 4);
				memcpy(&uuid[18], &vg[22], 4);
				memcpy(&uuid[22], &vg[27], 4);
				memcpy(&uuid[26], &vg[32], 6);
				memcpy(&uuid[32], &lv[0], 6);
				memcpy(&uuid[38], &lv[7], 4);
				memcpy(&uuid[42], &lv[12], 4);
				memcpy(&uuid[46], &lv[17], 4);
				memcpy(&uuid[50], &lv[22], 4);
				memcpy(&uuid[54], &lv[27], 4);
				memcpy(&uuid[58], &lv[32], 6);
				uuid[64] = '\0';

				DEBUGLOG("getting initial lock for %s\n", uuid);
				hold_lock(uuid, LKM_CRMODE, LKF_NOQUEUE);
			}
		}
	}
	fclose(lvs);
	return NULL;
}

/* This checks some basic cluster-LVM configuration stuff */
static void check_config()
{
	int locking_type;

	locking_type = find_config_int(cmd->cft->root, "global/locking_type", 1);

	if (locking_type == 3) /* compiled-in cluster support */
		return;

	if (locking_type == 2) { /* External library, check name */
		char *libname;

		libname = find_config_str(cmd->cft->root, "global/locking_library",
					  "");
		if (!strcmp(libname, "liblvm2clusterlock.so"))
			return;

		log_error("Incorrect LVM locking library specified in lvm.conf, cluster operations may not work.");
		return;
	}
	log_error("locking_type not set correctly in lvm.conf, cluster operations will not work.");
}

void init_lvhash()
{
	/* Create hash table for keeping LV locks & status */
	lv_hash = hash_create(100);
	pthread_mutex_init(&lv_hash_lock, NULL);
}

/* Called to initialise the LVM context of the daemon */
int init_lvm(void)
{
	if (!(cmd = create_toolcontext(NULL))) {
		log_error("Failed to allocate command context");
		return 0;
	}

	/* Use LOG_DAEMON for syslog messages instead of LOG_USER */
	init_syslog(LOG_DAEMON);
	init_debug(_LOG_ERR);

	/* Check lvm.conf is setup for cluster-LVM */
	check_config();

	get_initial_state();

	return 1;
}
