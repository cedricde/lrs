/*
 * dir.c
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
#include <linux/fs.h>
#include <linux/slab.h>
#include <linux/ctype.h>
#include <linux/socket.h>

#include <asm/uaccess.h>
#include <asm/system.h>

#include <linux/smp_lock.h>

#include "lufs.h"
#include "proc.h"


extern struct inode* lu_iget(struct super_block*, struct lufs_fattr*);
extern int lufs_notify_change(struct dentry*, struct iattr*);

static int lu_readdir(struct file*, void*, filldir_t);

static struct dentry *lu_lookup(struct inode*, struct dentry*, struct nameidata *);
static int lu_mkdir(struct inode*, struct dentry*, int);
static int lu_create(struct inode*, struct dentry*, int, struct nameidata *);
static int lu_rmdir(struct inode*, struct dentry*);
static int lu_rename(struct inode*, struct dentry*, struct inode*, struct dentry*);
static int lu_unlink(struct inode*, struct dentry*);
static int lu_link(struct dentry*, struct inode*, struct dentry*);
static int lu_symlink(struct inode*, struct dentry*, const char*);

struct file_operations lu_dir_operations = {
    .read	= generic_read_dir,
    .readdir	= lu_readdir,
};

struct inode_operations lu_dir_inode_operations = {
    .create	= lu_create,
    .lookup	= lu_lookup,
    .link	= lu_link,
    .unlink	= lu_unlink,
    .symlink	= lu_symlink,
    .mkdir	= lu_mkdir,
    .rmdir	= lu_rmdir,
    .rename	= lu_rename,
    .setattr	= lufs_notify_change,
};

static int lu_lookup_validate(struct dentry *dentry, struct nameidata *nd)
{
    struct inode *inode = dentry->d_inode;
    unsigned long age = jiffies - dentry->d_time;
    int res;
    
    TRACE("in\n");
    
    res = (age <= LU_MAXAGE);
    TRACE("age: %lu, valid: %d\n", age, res);

    if(!res)
	res = (lu_revalidate_inode(dentry) == 0);

    
    if(inode){
	lock_kernel();

	if(is_bad_inode(inode))
	    res = 0;
	unlock_kernel();
    }else
	TRACE("no inode?!\n");

    TRACE("out(res=%d)\n", res);

    return res;
}

static int lu_delete_dentry(struct dentry *dentry)
{
    
    TRACE("in\n");
    if(dentry->d_inode && is_bad_inode(dentry->d_inode)){
	WARN("bad inode, unhashing \n");
    	return 1;
    }

    TRACE("out\n");
    return 0;
}

struct dentry_operations lufs_dentry_operations = {
    .d_revalidate	= lu_lookup_validate,
    .d_delete		= lu_delete_dentry,
};

static int lu_readdir(struct file *f, void *dirent, filldir_t filldir)
{
    int res = -1;
    char *c;
    struct qstr qname;
    unsigned long ino;
    struct iovec siov[2], riov;
    struct server_slot *slot;
    unsigned short offset;
    
    TRACE("in\n");
    
    if((slot = lu_getslot(GET_INFO(f->f_dentry->d_sb))) == NULL)
	return -ERESTARTSYS;

    if(lu_getname(f->f_dentry, slot->s_buf, LU_MAXDATA) < 0){
	WARN("lu_getname failed!\n");
	goto out;
    }

    TRACE("reading %s, offset %u...\n", slot->s_buf, (unsigned)f->f_pos);
    res = 0;
    
    switch((unsigned int)f->f_pos){

    case 0:
	if(filldir(dirent, ".", 1, 0, f->f_dentry->d_inode->i_ino, DT_DIR) < 0)
	    goto out;
	f->f_pos++;

    case 1:
	if(filldir(dirent, "..", 2, 1, f->f_dentry->d_parent->d_inode->i_ino, DT_DIR) < 0)
	    goto out;
	f->f_pos++;

    default:
	offset = f->f_pos;
	siov[0].iov_base = &offset;
	siov[0].iov_len = sizeof(unsigned short);
	siov[1].iov_base = slot->s_buf;
	siov[1].iov_len = strlen(slot->s_buf) + 1;
	riov.iov_base = slot->s_buf;
	riov.iov_len = LU_MAXDATA;

	if((res = lu_execute(GET_INFO(f->f_dentry->d_inode->i_sb), slot, PTYPE_READDIR, siov, 2, &riov, 1)) < 0){
	    WARN("could not read directory content!\n");
	    if(res == -ERESTARTSYS)
		res = -EINTR;
	    goto out;
	}
	if(PIS_ERROR(res)){
	    WARN("server failure!\n");
	    res = PERROR(res);
	    goto out;
	}
	for(qname.name = slot->s_buf, c = strchr(slot->s_buf, '\n'); c != NULL; qname.name = c+1, c = strchr(c+1, '\n')){
	    *c = 0;
	    TRACE("direntry: %s.\n", qname.name);
	    qname.len = strlen(qname.name);
	    if((ino = find_inode_number(f->f_dentry, &qname)) == 0)
		ino = iunique(f->f_dentry->d_sb, 2);
	    if(filldir(dirent, qname.name, qname.len, f->f_pos, ino, DT_UNKNOWN) < 0)
		break;
	    f->f_pos++;	    
	}
    }

    TRACE("out\n");
 out:
    lu_putslot(slot);
    return res;
}

static struct dentry* lu_lookup(struct inode *dir, struct dentry *dentry, struct nameidata *nd)
{
    int res;
    struct lufs_fattr fattr;
    struct iovec siov, riov;
    struct inode *inode;
    struct server_slot *slot;

    TRACE("in\n");

    if((slot = lu_getslot(GET_INFO(dir->i_sb))) == NULL)
	return ERR_PTR(-ERESTARTSYS);
    
    if((res = lu_getname(dentry, slot->s_buf, LU_MAXDATA)) < 0){
	WARN("lu_getname failed!\n");
	goto out;
    }

    TRACE("looking up %s\n", slot->s_buf);
    
    siov.iov_base = slot->s_buf;
    siov.iov_len = strlen(slot->s_buf) + 1;
    riov.iov_base = &fattr;
    riov.iov_len = sizeof(struct lufs_fattr);

    if((res = lu_execute(GET_INFO(dir->i_sb), slot, PTYPE_STAT, &siov, 1, &riov, 1)) < 0)
	goto out;

    if(PIS_ERROR(res)){
	TRACE("File not found...\n");
	dentry->d_op = &lufs_dentry_operations;
	dentry->d_time = jiffies;
	d_add(dentry, NULL);
	lu_putslot(slot);
	return NULL;
    }

    lu_fixattrs(GET_INFO(dir->i_sb), &fattr);

    if(dentry == dentry->d_parent)
	fattr.f_ino = 2;
    else 
	fattr.f_ino = iunique(dentry->d_sb, 2);

    if((inode = lu_iget(dir->i_sb, &fattr))){
	dentry->d_op = &lufs_dentry_operations;
	dentry->d_time = jiffies;
	d_add(dentry, inode);
    }
    res = 0;

 out:
    lu_putslot(slot);

    TRACE("out\n");
    return ERR_PTR(res);
}

static int lu_instantiate(struct dentry *dentry, char *name, struct server_slot *slot)
{
    int res;
    struct lufs_fattr fattr;
    struct iovec siov, riov;
    struct inode *inode;

    TRACE("in\n");

    TRACE("instantiating %s\n", name);
    
    siov.iov_base = name;
    siov.iov_len = strlen(name) + 1;
    riov.iov_base = &fattr;
    riov.iov_len = sizeof(struct lufs_fattr);

    if((res = lu_execute(GET_INFO(dentry->d_sb), slot, PTYPE_STAT, &siov, 1, &riov, 1)) < 0)
	goto out;

    if(PIS_ERROR(res)){
	TRACE("File not found...\n");
	res = PERROR(res);
	goto out;
    }

    lu_fixattrs(GET_INFO(dentry->d_sb), &fattr);

    fattr.f_ino = iunique(dentry->d_sb, 2);
    inode = lu_iget(dentry->d_sb, &fattr);

    if(!inode){
	res = -EACCES;
	goto out;
    }

    d_instantiate(dentry, inode);
    res = 0;

  out:
    TRACE("out\n");
    return res;
}

static int lu_mkdir(struct inode *dir, struct dentry *dentry, int mode)
{
    int res;
    struct server_slot *slot;
    struct iovec iov[2];

    TRACE("in\n");

    if((slot = lu_getslot(GET_INFO(dentry->d_sb))) == NULL)
	return -ERESTARTSYS;

    if((res = lu_getname(dentry, slot->s_buf, LU_MAXDATA)) < 0){
	WARN("lu_getname failed!\n");
	goto out;
    }
    
    iov[0].iov_base = &mode;
    iov[0].iov_len = sizeof(mode);
    iov[1].iov_base = slot->s_buf;
    iov[1].iov_len = strlen(slot->s_buf) + 1;

    if((res = lu_execute(GET_INFO(dentry->d_sb), slot, PTYPE_MKDIR, iov, 2, NULL, 0)) < 0)
	goto out;

    if(PIS_ERROR(res)){
	TRACE("Could not create directory.\n");
	res = PERROR(res);
	goto out;
    }

    res = lu_instantiate(dentry, slot->s_buf, slot);

  out:
    lu_putslot(slot);
    
    TRACE("out\n");
    return res;
}

static int lu_create(struct inode *dir, struct dentry *dentry, int mode, struct nameidata *nd)
{
    int res;
    struct server_slot *slot;
    struct iovec iov[2];

    TRACE("in\n");

    if((slot = lu_getslot(GET_INFO(dentry->d_sb))) == NULL)
	return -ERESTARTSYS;

    if((res = lu_getname(dentry, slot->s_buf, LU_MAXDATA)) < 0){
	WARN("lu_getname failed!\n");
	goto out;
    }
    
    iov[0].iov_base = &mode;
    iov[0].iov_len = sizeof(mode);
    iov[1].iov_base = slot->s_buf;
    iov[1].iov_len = strlen(slot->s_buf) + 1;

    if((res = lu_execute(GET_INFO(dentry->d_sb), slot, PTYPE_CREATE, iov, 2, NULL, 0)) < 0)
	goto out;

    if(PIS_ERROR(res)){
	TRACE("Could not create file.\n");
	res = PERROR(res);
	goto out;
    }

    res = lu_instantiate(dentry, slot->s_buf, slot);
    
  out:
    lu_putslot(slot);

    TRACE("out\n");
    return res;
}

static int lu_rmdir(struct inode *dir, struct dentry *dentry)
{
    int res;
    struct server_slot *slot;
    struct iovec iov;

    if(!d_unhashed(dentry))
	return -EBUSY;    

    TRACE("in\n");
    
    if((slot = lu_getslot(GET_INFO(dentry->d_sb))) == NULL)
	return -ERESTARTSYS;

    if((res = lu_getname(dentry, slot->s_buf, LU_MAXDATA)) < 0){
	WARN("lu_getname failed!");
	goto out;
    }
    
    iov.iov_base = slot->s_buf;
    iov.iov_len = strlen(slot->s_buf) + 1;

    if((res = lu_execute(GET_INFO(dentry->d_sb), slot, PTYPE_RMDIR, &iov, 1, NULL, 0)) < 0)
	goto out;

    if(PIS_ERROR(res)){
	TRACE("rmdir failed!\n");
	res = PERROR(res);
	goto out;
    }
    res = 0;

  out:
    lu_putslot(slot);

    TRACE("out\n");
    return res;
}

static int lu_rename(struct inode *old_dir, struct dentry *old_dentry, struct inode *new_dir, struct dentry *new_dentry)
{
    struct server_slot *slot;
    int res;
    struct iovec iov[2];

    TRACE("in\n");

    if((slot = lu_getslot(GET_INFO(old_dentry->d_sb))) == NULL)
	return -ERESTARTSYS;

    if((res = lu_getname(old_dentry, slot->s_buf, LU_MAXPATHLEN)) < 0 ||
       (res = lu_getname(new_dentry, &(slot->s_buf[LU_MAXPATHLEN]), LU_MAXPATHLEN)) < 0){
	WARN("lu_getname failed!\n");
	goto out;
    }

    iov[0].iov_base = slot->s_buf;
    iov[0].iov_len = strlen(slot->s_buf) + 1;
    iov[1].iov_base = &(slot->s_buf[LU_MAXPATHLEN]);
    iov[1].iov_len = strlen(&(slot->s_buf[LU_MAXPATHLEN])) + 1;

    if((res = lu_execute(GET_INFO(old_dentry->d_sb), slot, PTYPE_RENAME, iov, 2, NULL, 0)) < 0)
	goto out;

    if(PIS_ERROR(res)){
	TRACE("rename failed!\n");
	res = PERROR(res);
	goto out;
    }
    res = 0;

  out:
    lu_putslot(slot);

    TRACE("out\n");
    return res;
}

static int lu_unlink(struct inode *dir, struct dentry *dentry)
{
    int res;
    struct server_slot *slot;
    struct iovec iov;

    TRACE("in\n");

    if((slot = lu_getslot(GET_INFO(dentry->d_sb))) == NULL)
	return -ERESTARTSYS;

    if((res = lu_getname(dentry, slot->s_buf, LU_MAXPATHLEN)) < 0){
	WARN("lu_getname failed!");
	goto out;
    }
    
    iov.iov_base = slot->s_buf;
    iov.iov_len = strlen(slot->s_buf) + 1;

    if((res = lu_execute(GET_INFO(dentry->d_sb), slot, PTYPE_UNLINK, &iov, 1, NULL, 0)) < 0)
	goto out;

    if(PIS_ERROR(res)){
	TRACE("unlink failed!\n");
	res = PERROR(res);
	goto out;
    }
    res = 0;

  out:
    lu_putslot(slot);

    TRACE("out\n");
    return res;
}


static int lu_link(struct dentry *old_dentry, struct inode *dir, struct dentry *dentry)
{
    int res;
    struct server_slot *slot;
    struct iovec iov[2];

    TRACE("in\n");

    if(S_ISDIR(old_dentry->d_inode->i_mode))
	return -EPERM;

    if(!(slot = lu_getslot(GET_INFO(old_dentry->d_sb))))
	return -ERESTARTSYS;

    if((res = lu_getname(old_dentry, slot->s_buf, LU_MAXPATHLEN)) < 0){
	WARN("lu_getname failed!\n");
	goto out;
    }

    if((res = lu_getname(dentry, &slot->s_buf[LU_MAXPATHLEN], LU_MAXPATHLEN)) < 0){
	WARN("lu_getname failed!\n");
	goto out;
    }

    iov[0].iov_base = slot->s_buf;
    iov[0].iov_len = strlen(slot->s_buf) + 1;
    iov[1].iov_base = &slot->s_buf[LU_MAXPATHLEN];
    iov[1].iov_len = strlen(&slot->s_buf[LU_MAXPATHLEN]) + 1;

    d_drop(dentry);

    if((res = lu_execute(GET_INFO(old_dentry->d_sb), slot, PTYPE_LINK, iov, 2, NULL, 0)) < 0)
	goto out;

    if(PIS_ERROR(res)){
	TRACE("link failed!\n");
	res = PERROR(res);
	goto out;
    }

    res = 0;

  out:
    lu_putslot(slot);
    TRACE("out\n");
    return res;
}

static int lu_symlink(struct inode *dir, struct dentry *dentry, const char *symname)
{
    int res;
    struct server_slot *slot;
    struct iovec iov[2];

    TRACE("in\n");
    TRACE("symlink: %s\n", symname);
    
    if(strlen(symname) > LU_MAXPATHLEN - 1)
	return -ENAMETOOLONG;

    if(!(slot = lu_getslot(GET_INFO(dentry->d_sb))))
	return -ERESTARTSYS;

    if((res = lu_getname(dentry, slot->s_buf, LU_MAXPATHLEN)) < 0){
	WARN("lu_getname failed!\n");
	goto out;
    }

    TRACE("fname: %s\n", slot->s_buf);

    strcpy(&slot->s_buf[LU_MAXPATHLEN], symname);

    iov[0].iov_base = slot->s_buf;
    iov[0].iov_len = strlen(slot->s_buf) + 1;
    iov[1].iov_base = &slot->s_buf[LU_MAXPATHLEN];
    iov[1].iov_len = strlen(&slot->s_buf[LU_MAXPATHLEN]) + 1;

    d_drop(dentry);

    if((res = lu_execute(GET_INFO(dentry->d_sb), slot, PTYPE_SYMLINK, iov, 2, NULL, 0)) < 0)
	goto out;

    if(PIS_ERROR(res)){
	TRACE("symlink failed!\n");
	res = PERROR(res);
	goto out;
    }

    res = 0;

  out:
    lu_putslot(slot);
    TRACE("out\n");
    return res;
}



