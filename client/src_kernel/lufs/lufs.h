/*
 * lufs.h
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

#ifndef _LUFS_H_
#define _LUFS_H_

#include <linux/list.h>
#include <linux/un.h>
#include <linux/spinlock.h>

#include "proto.h"

#undef TRACE
#undef WARN
#undef VERBOSE
#undef ERROR

#ifdef LUFS_DEBUG
#define TRACE(x...) 	do { printk(KERN_INFO "(%s) - ", __func__); printk(x); } while(0)
#define WARN(x...) 	do { printk(KERN_ERR "(%s) - ", __func__); printk(x); } while(0)
#else
#define TRACE(x...) 	do {} while(0)
#define WARN(x...)	do {} while(0)
#endif

#ifdef LUFS_VERBOSE
#define VERBOSE(x...) 	do { printk(KERN_INFO "(%s) - ", __func__); printk(x); } while(0)
#else
#define VERBOSE(x...)	do {} while(0)
#endif

#define ERROR(x...) 	do { printk(KERN_ERR "(%s) - ", __func__); printk(x); } while(0)

#define GET_INFO(sb)	((struct lufs_sb_info*)sb->s_fs_info)

#define LU_MAXPATHLEN	1024
#define LU_MAXTRIES	10
#define LU_MAXIOVEC	5
#define LU_NRSLOTS	3
#define LU_MAGIC	0xfade
#define LU_MAXAGE	HZ*5

#define LU_DEF_UID	2
#define LU_DEF_GID	2

#define LU_BLOCKSIZE	512
#define LU_BLOCKSIZEBITS	9

struct lufs_config{
    __kernel_uid_t 	uid;
    __kernel_gid_t	gid;
    __kernel_mode_t	fmode;
    __kernel_mode_t	dmode;
    unsigned 		channels;
    int			own_fs;
};

struct lufs_sb_info{
    struct list_head	slots;
    struct lufs_config	config;
    rwlock_t		lock;
    char 		server_socket[UNIX_PATH_MAX];
    pid_t		server_pid;
    char		root[UNIX_PATH_MAX];
    unsigned 		rootlen;
};

#endif
