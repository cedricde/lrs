/*
 * inode.c
 * Copyright (C) 2002-2003 Florin Malita <mali@go.ro>
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
#include <linux/init.h>
#include <linux/fs.h>
#include <linux/slab.h>
#include <linux/list.h>
#include <linux/smp_lock.h>
#include <linux/signal.h>
#include <linux/sched.h>
#include <linux/socket.h>
#include <linux/string.h>
#include <linux/vfs.h>

#include <asm/system.h>
#include <asm/uaccess.h>

#include "lufs.h"
#include "proc.h"

MODULE_AUTHOR("Florin Malita <mali@go.ro>");
MODULE_DESCRIPTION("Linux Userland Filesystem");
#ifdef MODULE_LICENSE
MODULE_LICENSE("GPL");
#endif

extern struct file_operations lu_dir_operations, lu_file_operations;
extern struct inode_operations lu_dir_inode_operations, lu_file_inode_operations, lu_symlink_inode_operations;
extern struct address_space_operations lu_file_aops;
extern struct dentry_operations lufs_dentry_operations;

static void lu_delete_inode(struct inode*);
static void lu_put_super(struct super_block*);
static int  lu_statfs(struct super_block*, struct kstatfs*);

static struct super_operations lu_sops = {
    .drop_inode		= generic_delete_inode,
    .delete_inode	= lu_delete_inode,
    .put_super		= lu_put_super,
    .statfs		= lu_statfs,
};


/*
 * Ignore unknown options, they're probably for the userspace daemon.
 */
static void parse_options(struct lufs_sb_info *server, char *opts)
{
    char *p, *q;
    int len;

    if(!opts)
	return;

    len = strlen(opts);

    while((p = strsep(&opts, ","))){
	if(strncmp(p, "server_socket=", 14) == 0){
	    if(strlen(p+14) > UNIX_PATH_MAX)
		goto ugly_opts;
	    strcpy(server->server_socket, p+14);
	    TRACE("server_socket: %s\n", server->server_socket);
	}else 
	if(strncmp(p, "uid=", 4) == 0){
	    if(current->uid)
		ERROR("only root can use uid option!\n");
	    else{
		if(strlen(p+4) > 5)
		    goto ugly_opts;
		q = p + 4;
		server->config.uid = simple_strtoul(q, &q, 0);
		TRACE("uid: %d\n", server->config.uid); 
	    }
	}else
	if(strncmp(p, "gid=", 4) == 0){
	    if(current->uid)
		ERROR("only root can use gid option!\n");
	    else{
		if(strlen(p+4) > 5)
		    goto ugly_opts;
		q = p + 4;
		server->config.gid = simple_strtoul(q, &q, 0);
		TRACE("gid: %d\n", server->config.gid); 
	    }
	}else
	if(strncmp(p, "fmask=", 6) == 0){
	    if(strlen(p + 6) > 3)
		goto ugly_opts;
	    q = p + 6;
	    server->config.fmode = (((q[0] - '0') << 6) + ((q[1] - '0') << 3) + (q[2] - '0')) & (S_IRWXU | S_IRWXG | S_IRWXO);
	    TRACE("fmode: %d\n", server->config.fmode);
	}else
	if(strncmp(p, "dmask=", 6) == 0){
	    if(strlen(p + 6) > 3)
		goto ugly_opts;
	    q = p + 6;
	    server->config.dmode = (((q[0] - '0') << 6) + ((q[1] - '0') << 3) + (q[2] - '0')) & (S_IRWXU | S_IRWXG | S_IRWXO);
	    TRACE("dmode: %d\n", server->config.dmode);
	}else
	if(strncmp(p, "root=", 5) == 0){
	    if(strlen(p+5) >= UNIX_PATH_MAX - 1)
		goto ugly_opts;
	    strcpy(server->root, p+5);
	    server->rootlen = strlen(server->root);
	    
	    if(server->root[server->rootlen - 1] == '/'){
		server->root[server->rootlen - 1] = 0;
		server->rootlen--;
	    }
			    
	    TRACE("remote root: %s, len: %u\n", server->root, server->rootlen);
	}else
	if(strncmp(p, "channels=", 9) == 0){
	    if(strlen(p+9) > 5)
		goto ugly_opts;
	    q = p + 9;
	    server->config.channels = simple_strtoul(q, &q, 0);
	    
	    TRACE("channels: %u\n", server->config.channels);
	}else
	if(strncmp(p, "own_fs", 6) == 0){
	    server->config.own_fs = 1;
	    TRACE("forcing ownership\n");
	}else
	if(strncmp(p, "server_pid=", 11) == 0){
	    if(strlen(p+11) > 7)
		goto ugly_opts;
	    q = p + 11;
	    server->server_pid = simple_strtoul(q, &q, 0);

	    TRACE("server_pid: %u\n", server->server_pid);
	}
    }

    return;

  ugly_opts:
    WARN("evil options!\n");
}

/*
 * Fill in inode attributes. 
 * Ivalidate the page_cache pages if the inode has been modified.
 */
static void set_inode_attr(struct inode *inode, struct lufs_fattr *fattr)
{
    time_t last_time = inode->i_mtime.tv_sec;
    loff_t last_sz = inode->i_size;

    TRACE("in\n");
    
    inode->i_mode = fattr->f_mode;
    inode->i_nlink = fattr->f_nlink;
    inode->i_uid = fattr->f_uid;
    inode->i_gid = fattr->f_gid;
    inode->i_ctime.tv_sec = fattr->f_ctime;
    inode->i_mtime.tv_sec = fattr->f_mtime;
    inode->i_atime.tv_sec = fattr->f_atime;
    inode->i_blksize = fattr->f_blksize;
    inode->i_blocks = fattr->f_blocks;
    inode->i_size = fattr->f_size;

    if(inode->i_mtime.tv_sec != last_time || inode->i_size != last_sz){
	TRACE("inode changed...\n");
	if(!S_ISDIR(inode->i_mode))
	    invalidate_inode_pages(inode->i_mapping);
    }

    TRACE("out\n");
}

static int lu_do_stat(struct dentry *dentry, struct lufs_fattr *fattr)
{
    struct server_slot *slot;
    struct iovec siov, riov;
    int res;

    TRACE("in\n");

    if((slot = lu_getslot(GET_INFO(dentry->d_sb))) == NULL)
	return -ERESTARTSYS;

    if((res = lu_getname(dentry, slot->s_buf, LU_MAXDATA)) < 0){
	WARN("lu_getname failed!\n");
	goto out;
    }

    TRACE("stating %s...\n", slot->s_buf);

    siov.iov_base = slot->s_buf;
    siov.iov_len = strlen(slot->s_buf) + 1;
    riov.iov_base = fattr;
    riov.iov_len = sizeof(struct lufs_fattr);

    if((res = lu_execute(GET_INFO(dentry->d_sb), slot, PTYPE_STAT, &siov, 1, &riov, 1)) < 0)
	goto out;

    if(PIS_ERROR(res)){
	WARN("stat failed!\n");
	res = PERROR(res);
	goto out;
    }

    lu_fixattrs(GET_INFO(dentry->d_sb), fattr);

    res = 0;

  out:
    TRACE("out\n");
    lu_putslot(slot);
    return res;
}

/*
 * Reload inode attributes.
 */
static int lu_refresh_inode(struct dentry *dentry)
{
    struct inode *inode = dentry->d_inode;
    struct lufs_fattr fattr;
    int res;

    TRACE("in\n");

    if((res = lu_do_stat(dentry, &fattr)) < 0)
	return res;

    dentry->d_time = jiffies;

    if(!inode)
	return 0;

    if((inode->i_mode & S_IFMT) == (fattr.f_mode & S_IFMT))
	set_inode_attr(inode, &fattr);
    else{
	WARN("inode changed mode, %x to %x\n", inode->i_mode, (unsigned int)fattr.f_mode);
	TRACE("oops!\n");
	
	fattr.f_mode = inode->i_mode;
	make_bad_inode(inode);
	inode->i_mode = fattr.f_mode;

	if(!S_ISDIR(inode->i_mode))
	    invalidate_inode_pages(inode->i_mapping);
	    
	return -EIO;
    }

    TRACE("out\n");
    return 0;
}

int lu_revalidate_inode(struct dentry *dentry)
{
    int res = 0;

    TRACE("in\n");
    
    lock_kernel();
    
    if(time_before(jiffies, dentry->d_time + LU_MAXAGE))
	goto out;

    res = lu_refresh_inode(dentry);

  out:
    TRACE("out\n");
    unlock_kernel();
    return res;
}

int lufs_notify_change(struct dentry *dentry, struct iattr *iattr)
{
    struct server_slot *slot;
    struct iovec iov[2];
    struct lufs_fattr fattr;
    int res;

    TRACE("in\n");

    if((res = lu_do_stat(dentry, &fattr)) < 0)
	return res;

    if((slot = lu_getslot(GET_INFO(dentry->d_sb))) == NULL)
	return -ERESTARTSYS;

    if((res = lu_getname(dentry, slot->s_buf, LU_MAXDATA)) < 0){
	WARN("lu_getname failed!\n");
	goto out;
    }
    
    if(iattr->ia_valid & ATTR_MODE)
	fattr.f_mode = iattr->ia_mode;
    if(iattr->ia_valid & ATTR_UID)
	fattr.f_uid  = iattr->ia_uid;
    if(iattr->ia_valid & ATTR_GID)
	fattr.f_gid  = iattr->ia_gid;
    if(iattr->ia_valid & ATTR_SIZE)
	fattr.f_size = iattr->ia_size;
    if(iattr->ia_valid & ATTR_ATIME)
	fattr.f_atime= iattr->ia_atime.tv_sec;
    if(iattr->ia_valid & ATTR_MTIME)
	fattr.f_mtime= iattr->ia_mtime.tv_sec;
    if(iattr->ia_valid & ATTR_CTIME)
	fattr.f_ctime= iattr->ia_ctime.tv_sec;

    iov[0].iov_base = &fattr;
    iov[0].iov_len = sizeof(struct lufs_fattr);
    iov[1].iov_base = slot->s_buf;
    iov[1].iov_len = strlen(slot->s_buf) + 1;

    if((res = lu_execute(GET_INFO(dentry->d_sb), slot, PTYPE_SETATTR, iov, 2, NULL, 0)) < 0)
	goto out;

    if(PIS_ERROR(res)){
	WARN("setattr failed!\n");
	res = PERROR(res);
	goto out;
    }

    res = 0;

    lu_refresh_inode(dentry);

  out:
    TRACE("out\n");
    lu_putslot(slot);
    return res;
}

/*
 * We always create a new inode here.
 */
struct inode* lu_iget(struct super_block *sb, struct lufs_fattr *fattr)
{
    struct inode *res;

    TRACE("in\n");
    
    res = new_inode(sb);
    if(!res)
	return NULL;
    res->i_ino = fattr->f_ino;
    set_inode_attr(res, fattr);

    if(S_ISDIR(res->i_mode)){
	TRACE("it's a dir.\n");
	res->i_op = &lu_dir_inode_operations;
	res->i_fop = &lu_dir_operations;
    }else if(S_ISLNK(res->i_mode)){
	TRACE("it's a link.\n");
	res->i_op = &lu_symlink_inode_operations;
    }else{
	TRACE("it's a file.\n");
	res->i_op = &lu_file_inode_operations;
	res->i_fop = &lu_file_operations;
	res->i_data.a_ops = &lu_file_aops;
    }
	
    insert_inode_hash(res);
    return res;
}

static int lu_statfs(struct super_block *sb, struct kstatfs *attr)
{
    int res;
    struct iovec riov;
    struct server_slot *slot;
    struct lufs_sbattr sbattr;

    TRACE("in\n");
    
    if((slot = lu_getslot(GET_INFO(sb))) == NULL)
	return -ERESTARTSYS;

    riov.iov_base = &sbattr;
    riov.iov_len = sizeof(sbattr);

    if((res = lu_execute(GET_INFO(sb), slot, PTYPE_STATFS, NULL, 0, &riov, 1)) < 0)
	goto out;

    if(PIS_ERROR(res)){
	WARN("statfs failed\n");
	res = PERROR(res);
	goto out;
    }

    attr->f_type = LU_MAGIC;
    attr->f_bsize = LU_BLOCKSIZE;
    attr->f_blocks = sbattr.sb_bytes / LU_BLOCKSIZE;
    attr->f_bfree = sbattr.sb_bytes_free / LU_BLOCKSIZE;
    attr->f_bavail = sbattr.sb_bytes_available / LU_BLOCKSIZE;
    attr->f_files = sbattr.sb_files;
    attr->f_ffree = sbattr.sb_ffree;
    attr->f_namelen = 0xFF;

    res = 0;

  out:
    TRACE("out\n");
    lu_putslot(slot);
    return res;
}

static void lu_put_super(struct super_block *sb)
{
    struct siginfo info;

    TRACE("in\n");

    info.si_signo = SIGUSR1;
    info.si_errno = 0;
    info.si_code = SI_USER;
    info.si_pid = current->pid;
    info.si_uid = current->uid;
    
    /* notify the daemon that we're going bye-bye */
    kill_proc_info(SIGUSR1, &info, GET_INFO(sb)->server_pid);

    lu_empty_slots(GET_INFO(sb));
    kfree(GET_INFO(sb));
    TRACE("out\n");
}

static void lu_delete_inode(struct inode *in)
{
    TRACE("in\n");
    clear_inode(in);
    TRACE("out\n");
}

static int lu_fill_super(struct super_block *sb, void *opts, int silent)
{
    struct lufs_sb_info *info;
    struct server_slot *slot;
    struct lufs_fattr root_attr;
    struct inode *root_inode;

    int i;

    TRACE("in\n");
    
    if(!opts){
	ERROR("need some options here!\n");
	goto out;
    }
    
    if((info = (struct lufs_sb_info*)kmalloc(sizeof(struct lufs_sb_info), GFP_KERNEL)) == NULL){
	ERROR("kmalloc error!\n");
	goto out;
    }
    memset(info, 0, sizeof(struct lufs_sb_info));
    info->lock = RW_LOCK_UNLOCKED;
    INIT_LIST_HEAD(&info->slots);

    info->config.uid = current->uid;
    info->config.gid = current->gid;    
    info->config.channels = LU_NRSLOTS;
    
    parse_options(info, opts);
    
    if(!info->server_socket[0]){
	ERROR("no server_socket specified!\n");
	goto out_info;
    }
    
    for(i = 0; i < info->config.channels; i++){
	if((slot = kmalloc(sizeof(struct server_slot), GFP_KERNEL)) == NULL){
	    ERROR("kmalloc error!\n");
	    goto out_slots;
	}
	memset(slot, 0, sizeof(struct server_slot));
	init_MUTEX(&slot->s_lock);
	if((slot->s_buf = kmalloc(LU_MAXDATA, GFP_KERNEL)) == NULL){
	    ERROR("kmalloc error!\n");
	    goto out_slots;
	}
	list_add(&slot->s_list, &info->slots);
    }

    sb->s_fs_info = info;
    sb->s_blocksize = LU_BLOCKSIZE;
    sb->s_blocksize_bits = LU_BLOCKSIZEBITS;
    sb->s_magic = LU_MAGIC;
    sb->s_op = &lu_sops;
    sb->s_flags = 0;
    sb->s_maxbytes = ((((long long)1) << 32) << LU_BLOCKSIZEBITS) - 1;
    TRACE("sb->s_maxbytes=%Ld\n",sb->s_maxbytes);

    lu_lookup_root(info, &root_attr);
    root_inode = lu_iget(sb, &root_attr);
    if(!root_inode)
	goto out_slots;
    sb->s_root = d_alloc_root(root_inode);
    if(!sb->s_root)
	goto out_slots;

    sb->s_root->d_op = &lufs_dentry_operations;
    sb->s_root->d_time = jiffies;

    TRACE("mount succeded: %s\n", info->server_socket);
    return 0;

 out_slots:
    lu_empty_slots(info);
 out_info:
    kfree(info);
 out:
    ERROR("mount failed!\n");
    return -EINVAL;
}

static struct super_block *lu_get_sb(struct file_system_type *fs_type, int flags, const char *dev_name, void *data)
{
    return get_sb_nodev(fs_type, flags, data, lu_fill_super);
}

static struct file_system_type lu_fs_type = {
    .owner	= THIS_MODULE,
    .name	= "lufs",
    .get_sb	= lu_get_sb,
    .kill_sb	= kill_anon_super,
};

static int __init lu_init(void)
{
    VERBOSE("UserLand File System\n");
    VERBOSE("Copyright (c) 2002, Florin Malita\n");
    return register_filesystem(&lu_fs_type);
}

static void __exit lu_release(void)
{
    VERBOSE("Unregistering lufs...\n");
    unregister_filesystem(&lu_fs_type);
}

module_init(lu_init);
module_exit(lu_release);
