/*
 * file.c
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
#include <linux/pagemap.h>
#include <linux/socket.h>

#include <asm/uaccess.h>
#include <asm/system.h>

#include <linux/smp_lock.h>

#include "lufs.h"
#include "proc.h"

extern int lufs_notify_change(struct dentry*, struct iattr*);
extern int lu_revalidate_inode(struct dentry*);

static int lu_file_open(struct inode *inode, struct file *file)
{
    int res, gres;
    struct server_slot *slot;
    struct iovec iov[2];
    unsigned flags;

    TRACE("in\n");

    if((gres = generic_file_open(inode, file)) < 0)
	return gres;

    TRACE("f_mode: %u, i_mode: %u\n", file->f_mode, inode->i_mode);
    TRACE("f_flags: %u, i_flags: %u\n", file->f_flags, inode->i_flags);

    if((slot = lu_getslot(GET_INFO(file->f_dentry->d_sb))) == NULL)
	return gres;

    if((res = lu_getname(file->f_dentry, slot->s_buf, LU_MAXDATA)) < 0){
	WARN("lu_getname failed!\n");
	goto out;
    }

    flags = file->f_flags & O_ACCMODE;
    iov[0].iov_base = &flags;
    iov[0].iov_len = sizeof(flags);
    iov[1].iov_base = slot->s_buf;
    iov[1].iov_len = strlen(slot->s_buf) + 1;

    lu_execute(GET_INFO(file->f_dentry->d_sb), slot, PTYPE_OPEN, iov, 2, NULL, 0);

out:
    lu_putslot(slot);

    TRACE("out\n");
    return gres;
}

static int lu_file_release(struct inode *inode, struct file *file)
{
    int res;
    struct server_slot *slot;
    struct iovec iov;

    TRACE("in\n");

    if((slot = lu_getslot(GET_INFO(file->f_dentry->d_sb))) == NULL)
	return -ERESTARTSYS;

    if((res = lu_getname(file->f_dentry, slot->s_buf, LU_MAXPATHLEN)) < 0){
	WARN("lu_getname failed!\n");
	goto out;
    }
    
    iov.iov_base = slot->s_buf;
    iov.iov_len = strlen(slot->s_buf) + 1;

    if((res = lu_execute(GET_INFO(file->f_dentry->d_sb), slot, PTYPE_RELEASE, &iov, 1, NULL, 0)) < 0)
	goto out;

    if(PIS_ERROR(res)){
	TRACE("release failed\n");
	res = PERROR(res);
	goto out;
    }
    
    res = 0;

out:
    lu_putslot(slot);

    TRACE("out\n");
    return res;
}

static int lu_file_readpage(struct file *f, struct page *p)
{
    int res;
    struct iovec siov[3], riov;
    long long offset;
    unsigned long count;
    struct server_slot *slot;

    TRACE("in\n");

    if((slot = lu_getslot(GET_INFO(f->f_dentry->d_sb))) == NULL)
	return -ERESTARTSYS;

    get_page(p);

    if((res = lu_getname(f->f_dentry, slot->s_buf, LU_MAXDATA)) < 0){
	WARN("lu_getname failed!\n");
	goto out;
    }

    offset = p->index << PAGE_CACHE_SHIFT;
    count = PAGE_SIZE;

    siov[0].iov_base = &offset;
    siov[0].iov_len = sizeof(offset);
    siov[1].iov_base = &count;
    siov[1].iov_len = sizeof(count);
    siov[2].iov_base = slot->s_buf;
    siov[2].iov_len = strlen(slot->s_buf) + 1;

    riov.iov_base = page_address(p);
    riov.iov_len = count;

    if((res = lu_execute(GET_INFO(f->f_dentry->d_sb), slot, PTYPE_READ, siov, 3, &riov, 1)) < 0)
	goto out;

    if(PIS_ERROR(res)){
	TRACE("read failed\n");
	res = PERROR(res);
	goto out;
    }
    
    flush_dcache_page(p);
    SetPageUptodate(p);
    res = 0;
    
  out:
    lu_putslot(slot);
    unlock_page(p);
    put_page(p);
        
    TRACE("out\n");
    return res;
}

static int lu_file_writepage(struct page *p, struct writeback_control *wbc)
{
    TRACE("in\n");

    TRACE("out\n");
    return -1;
}

static int lu_file_preparewrite(struct file *f, struct page *p, unsigned offset, unsigned to)
{
    TRACE("in\n");

    TRACE("out\n");

    return 0;
}

static int lu_file_commitwrite(struct file *f, struct page *p, unsigned offset, unsigned to)
{
    int res;
    struct server_slot *slot;
    struct iovec iov[4];
    char *buf;
    long long off;
    unsigned long cnt;

    TRACE("in\n");

    if((slot = lu_getslot(GET_INFO(f->f_dentry->d_sb))) == NULL)
	return -ERESTARTSYS;

    if((res = lu_getname(f->f_dentry, slot->s_buf, LU_MAXDATA)) < 0){
	WARN("lu_getname failed!\n");
	goto out2;
    }

    lock_kernel();

    buf = kmap(p) + offset;
    cnt = to - offset;
    off = offset + (((long long)p->index) << PAGE_CACHE_SHIFT);

    iov[0].iov_base = &off;
    iov[0].iov_len = sizeof(off);
    iov[1].iov_base = &cnt;
    iov[1].iov_len = sizeof(cnt);
    iov[2].iov_base = slot->s_buf;
    iov[2].iov_len = strlen(slot->s_buf) + 1;
    iov[3].iov_base = buf;
    iov[3].iov_len = cnt;

    TRACE("write %s, offset %Ld, count %d\n", slot->s_buf, off, (int)cnt);

    if((res = lu_execute(GET_INFO(f->f_dentry->d_sb), slot, PTYPE_WRITE, iov, 4, NULL, 0)) < 0)
	goto out1;


    if(PIS_ERROR(res)){
	TRACE("write failed\n");
	res = PERROR(res);
	goto out1;
    }

    f->f_dentry->d_inode->i_mtime = f->f_dentry->d_inode->i_atime = CURRENT_TIME;
    if(off + cnt > f->f_dentry->d_inode->i_size)
	f->f_dentry->d_inode->i_size = off + cnt;

    res = cnt;

  out1:
    kunmap(p);
    unlock_kernel();
  out2:
    lu_putslot(slot);
    TRACE("out\n");
    return res;
}

static int lu_file_read(struct file *filp, char *buf, size_t count, loff_t *ppos)
{
    struct dentry *dentry = filp->f_dentry;
    int res;

    TRACE("in\n");

    if(!(res = lu_revalidate_inode(dentry)))
	res = generic_file_read(filp, buf, count, ppos);

    TRACE("out\n");
    
    return res;
}

static int lu_file_mmap(struct file *filp, struct vm_area_struct *vma)
{
    struct dentry *dentry = filp->f_dentry;
    int res;

    TRACE("in\n");

    if(!(res = lu_revalidate_inode(dentry)))
	res = generic_file_mmap(filp, vma);

    TRACE("out\n");

    return res;
}

static ssize_t lu_file_write(struct file *filp, const char *buf, size_t count, loff_t *ppos)
{
    struct dentry *dentry = filp->f_dentry;
    ssize_t res;

    TRACE("in\n");

    if(!(res = lu_revalidate_inode(dentry)) && (count > 0))
	res = generic_file_write(filp, buf, count, ppos);

    TRACE("out\n");

    return res;
}

static int lu_file_fsync(struct file *filp, struct dentry *dentryp, int datasync)
{    
    return 0;
}

struct file_operations lu_file_operations = {
    .llseek	= generic_file_llseek,
    .read	= lu_file_read,
    .write	= lu_file_write,
    .mmap	= lu_file_mmap,
    .open	= lu_file_open,
    .release	= lu_file_release,
    .fsync	= lu_file_fsync,
};

struct inode_operations lu_file_inode_operations = {
    .setattr	= lufs_notify_change,
};

struct address_space_operations lu_file_aops = {
    .readpage	       	= lu_file_readpage,
    .writepage		= lu_file_writepage,
    .prepare_write	= lu_file_preparewrite,
    .commit_write	= lu_file_commitwrite,
};



