/*
 * symlink.c
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

#include <linux/version.h>
#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/slab.h>
#include <linux/socket.h>
#include <linux/smp_lock.h>
#include <linux/fs.h>

#include <asm/uaccess.h>
#include <asm/system.h>


#include "lufs.h"
#include "proc.h"

static char failed_link[] = "invalid";

static int lu_readlink(struct dentry *dentry, char *buffer, int bufflen)
{
    struct server_slot *slot;
    struct iovec siov, riov;
    int res;
    char *cc = failed_link;

    TRACE("in\n");

    if((slot = lu_getslot(GET_INFO(dentry->d_sb))) == NULL)
	return vfs_readlink(dentry, buffer, bufflen, cc);

    if((res = lu_getname(dentry, slot->s_buf, LU_MAXDATA)) < 0){
	WARN("lu_getname failed!\n");
	goto out;
    }

    siov.iov_base = slot->s_buf;
    siov.iov_len = strlen(slot->s_buf) + 1;
    riov.iov_base = &slot->s_buf[LU_MAXPATHLEN];
    riov.iov_len = LU_MAXPATHLEN;

    if((res = lu_execute(GET_INFO(dentry->d_sb), slot, PTYPE_READLINK, &siov, 1, &riov, 1)) < 0)
	goto out;

    if(PIS_ERROR(res)){
	TRACE("read_link failed.\n");
	res = PERROR(res);
	goto out;
    }

    cc = &slot->s_buf[LU_MAXPATHLEN];
    
    TRACE("response: %s\n", cc);
    
    if(*cc == '/'){
	if(GET_INFO(dentry->d_sb)->rootlen){
	    if(strncmp(GET_INFO(dentry->d_sb)->root, cc, GET_INFO(dentry->d_sb)->rootlen)){
		WARN("symlink outside mounted root!");
		cc = failed_link;
		goto out;
	    }
	    cc += GET_INFO(dentry->d_sb)->rootlen;
	}

	lu_xlate_symlink(slot->s_buf, slot->s_buf + LU_MAXPATHLEN, slot->s_buf);

	cc = slot->s_buf;

    }



  out:
    res = vfs_readlink(dentry, buffer, bufflen, cc);

    lu_putslot(slot);

    TRACE("out\n");
    return res;
}

static int lu_followlink(struct dentry *dentry, struct nameidata *nd)
{
    struct server_slot *slot;
    struct iovec siov, riov;
    int res;
    char *cc = failed_link;
    char *tmp;
    
    TRACE("in\n");

    if((slot = lu_getslot(GET_INFO(dentry->d_sb))) == NULL)
	return vfs_follow_link(nd, cc);


    if((res = lu_getname(dentry, slot->s_buf, LU_MAXDATA)) < 0){
	WARN("lu_getname failed!\n");
	goto out;
    }

    siov.iov_base = slot->s_buf;
    siov.iov_len = strlen(slot->s_buf) + 1;
    riov.iov_base = &slot->s_buf[LU_MAXPATHLEN];
    riov.iov_len = LU_MAXPATHLEN;

    if((res = lu_execute(GET_INFO(dentry->d_sb), slot, PTYPE_READLINK, &siov, 1, &riov, 1)) < 0)
	goto out;

    if(PIS_ERROR(res)){
	TRACE("read_link failed.\n");
	res = PERROR(res);
	goto out;
    }

    cc = &slot->s_buf[LU_MAXPATHLEN];

    if(*cc == '/'){
	if(GET_INFO(dentry->d_sb)->rootlen){
	    if(strncmp(GET_INFO(dentry->d_sb)->root, cc, GET_INFO(dentry->d_sb)->rootlen)){
		WARN("symlink outside mounted root!");
		cc = failed_link;
		goto out;
	    }
	    cc += GET_INFO(dentry->d_sb)->rootlen;
	}

	lu_xlate_symlink(slot->s_buf, slot->s_buf + LU_MAXPATHLEN, slot->s_buf);

	cc = slot->s_buf;

    }

  out:

    /* vfs_follow_link somehow manages to call lookup_validate, so we need to 
       release the slot, in case it's the only one, otherwise lu_lookup will 
       fail (avoid a deadlock). bad, bad vfs_follow_link! you break the overall
       beauty of no kmallocs... */

    if((tmp = kmalloc(strlen(cc) + 1, GFP_KERNEL)) == NULL){
	WARN("out of mem!\n");
	tmp = failed_link;
    }else    
	strcpy(tmp, cc);

    lu_putslot(slot);
    res = vfs_follow_link(nd, tmp);

    if(tmp != failed_link)
	kfree(tmp);
    
    TRACE("out\n");
    return res;
}

struct inode_operations lu_symlink_inode_operations = {
    .readlink		= lu_readlink,
    .follow_link	= lu_followlink,
};





