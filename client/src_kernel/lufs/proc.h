/*
 * proc.h
 * Copyright (C) 2002 Florin Malita <mali@go.ro>
 *
 * This file is part of LUFS, a free userspace filesystem implementation.
 * See http://lufs.sourceforge.net/ for updates.
 *
 * LUFS is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * LUFS is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#ifndef _LU_PROC_H_
#define _LU_PROC_H_

#include <linux/types.h>
#include <linux/list.h>
#include <linux/socket.h>

struct server_slot{
    struct socket	*s_sock;
    struct semaphore 	s_lock;
    struct list_head 	s_list;
    pid_t 		s_lastpid;
    char		*s_buf;
};

struct lufs_fattr;

int lu_execute(struct lufs_sb_info*, struct server_slot*, unsigned short, struct iovec*, unsigned short, struct iovec*, unsigned short);
void lu_empty_slots(struct lufs_sb_info*);
int lu_getname(struct dentry*, char*, int);
int lu_getname_dumb(struct dentry*, char*, int);
struct server_slot* lu_getslot(struct lufs_sb_info*);
void lu_putslot(struct server_slot*);
int lu_revalidate_inode(struct dentry*);
void lu_lookup_root(struct lufs_sb_info*, struct lufs_fattr*);
void lu_fixattrs(struct lufs_sb_info*, struct lufs_fattr*);
void lu_xlate_symlink(char*, char*, char*);

#endif
