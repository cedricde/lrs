/*
 * proc.c
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
#include <linux/socket.h>
#include <linux/un.h>
#include <linux/types.h>
#include <linux/list.h>
#include <linux/smp_lock.h>
#include <linux/net.h>
#include <linux/vfs.h>
#include <linux/mount.h>

#include <asm/system.h>
#include <asm/uaccess.h>

#include "lufs.h"
#include "proc.h"

static int sock_send(struct socket *sock, struct iovec *iov, int len)
{
    struct msghdr msg = {
	.msg_name	= NULL,
	.msg_namelen	= 0,
	.msg_iov	= iov,
	.msg_iovlen	= len,
	.msg_control	= NULL,
	.msg_controllen	= 0,
	.msg_flags	= 0
    };
    int res, i, size;
    mm_segment_t fs;

    for(i = 0, size = 0; i < len; i++)
	size += iov[i].iov_len;
    
    fs = get_fs();
    set_fs(get_ds());
    res = sock_sendmsg(sock, &msg, size);
    set_fs(fs);

    return res;
}

static int sock_recv(struct socket *sock, struct iovec *iov, int len, int rsize, unsigned flags)
{
    struct msghdr msg = {
	.msg_flags	= flags,
	.msg_name	= NULL,
	.msg_namelen	= 0,
	.msg_iov	= iov,
	.msg_iovlen	= len,
	.msg_control	= NULL,
	.msg_controllen	= 0
    };
    mm_segment_t fs;
    int res, i, size;

    for(i = 0, size = 0; i < len; i++)
	size += iov[i].iov_len;

    if(size < rsize){
	VERBOSE("Trying to overflow old me?! Truncating...\n");
	rsize = size;
    }

    fs = get_fs();
    set_fs(get_ds());
    res = sock_recvmsg(sock, &msg, rsize, flags);
    set_fs(fs);

    return res;
}

static int sock_connect(char *path, struct socket **s)
{
    struct sockaddr_un addr;
    int res;

    if(strlen(path) > UNIX_PATH_MAX - 1){
	WARN("unix domain path too long: %s", path);
	return -1;
    }

    addr.sun_family = AF_UNIX;
    strcpy(addr.sun_path, path);

    if((res = sock_create(PF_UNIX, SOCK_STREAM, 0, s)) < 0){
	WARN("failed to create a unix domain socket!\n");
	return res;
    }

    if((res = (*s)->ops->connect(*s, (struct sockaddr*)&addr, sizeof(addr), 0)) < 0){
	WARN("failed to connect the socket: %d!\n", res);
	return res;
    }
    return 0;
}

static int slot_reconnect(struct lufs_sb_info *info, struct server_slot *slot)
{
    int res = 0, tries = 0;

    if(slot->s_sock){
	TRACE("closing socket.\n");
	sock_release(slot->s_sock);
	slot->s_sock = NULL;
    }

    while(tries++ < LU_MAXTRIES && (res = sock_connect(info->server_socket, &slot->s_sock)) < 0){
	TRACE("retrying...\n");
	sock_release(slot->s_sock);
	slot->s_sock = NULL;
    }

    if(res >= 0){
	TRACE("successfully reconnected.\n");
    }

    return res;
}

void lu_empty_slots(struct lufs_sb_info *info)
{
    struct server_slot *slot;

    while(!list_empty(&info->slots)){
	slot = list_entry(info->slots.next, struct server_slot, s_list);
	if(slot->s_sock)
	    sock_release(slot->s_sock);
	list_del(&slot->s_list);
	if(slot->s_buf)
	    kfree(slot->s_buf);
	kfree(slot);
    }
}

static int do_execute(struct socket *sock, unsigned short cmd, unsigned short msglen, struct iovec *siov, unsigned short slen, struct iovec *riov, unsigned short rlen)
{
    struct lu_msg msg;
    struct iovec iov;
    int res;

    TRACE("msg_len: %d\n", msglen);
    
    msg.msg_version = PVERSION;
    msg.msg_type = cmd;
    msg.msg_datalen = msglen;
    msg.msg_pid = current->pid;

    iov.iov_base = &msg;
    iov.iov_len = sizeof(struct lu_msg);

    if((res = sock_send(sock, &iov, 1)) < 0){
	WARN("sock_send failed!\n");
	return res;
    }
    if((res = sock_send(sock, siov, slen)) < 0){
	WARN("sock_send failed!\n");
	return res;
    }

    iov.iov_base = &msg;
    iov.iov_len = sizeof(struct lu_msg);
    if((res = sock_recv(sock, &iov, 1, sizeof(struct lu_msg), 0)) < 0){
	WARN("sock_recv failed!\n");
	return res;
    }
    if(res != sizeof(struct lu_msg)){
	WARN("Ayeeee, didn't read a whole header!\n");
	return -EBUSY;
    }
    
    if((msg.msg_datalen == 0))
	return msg.msg_type;

    if(riov == NULL){
	WARN("Unexpected data!!! Getting out of sync...\n");
	return -1;
    }
	
    if((res = sock_recv(sock, riov, rlen, msg.msg_datalen, 0)) < 0){
	WARN("sock_recv failed!\n");
	return res;
    }

    return msg.msg_type;
}

struct server_slot* lu_getslot(struct lufs_sb_info *info)
{
    struct list_head *p, *nd_best = NULL;
    struct server_slot *slot;
    int gotlock = 0;

    /* Look for a slot used by this process before */
    read_lock(&info->lock);
    list_for_each(p, &info->slots)
	if(list_entry(p, struct server_slot, s_list)->s_lastpid == current->pid){
	    TRACE("found a previous used slot for %u.\n", current->pid);
	    if(down_trylock(&list_entry(p, struct server_slot, s_list)->s_lock) == 0){
		gotlock = 1;
		break;
	    }
	    TRACE("oops! I still hold the lock! forget this one...\n");
	}else 
	    if(!nd_best){
		nd_best = p;
	    }

    /* if we couldn't find one, take the first not locked by us */	
    if(p == &info->slots){
	if(!nd_best){
	    ERROR("deadlock: all locks owned by us!\n");
	    read_unlock(&info->lock);
	    return NULL;
	}else
	    p = nd_best;
	
    }
    read_unlock(&info->lock);

    slot = list_entry(p, struct server_slot, s_list);
    
    /* Get the lock on that slot */
    if(!gotlock)
	if(down_interruptible(&slot->s_lock))
	    return NULL;

    slot->s_lastpid = current->pid;

    /* Move it to the tail */
    write_lock(&info->lock);
    list_del(p);
    list_add_tail(p, &info->slots);
    write_unlock(&info->lock);

    return slot;
}

void lu_putslot(struct server_slot *slot)
{
    up(&slot->s_lock);
}

int lu_execute(struct lufs_sb_info *info, struct server_slot *slot, unsigned short cmd, struct iovec *siov, unsigned short slen, struct iovec *riov, unsigned short rlen)
{
    int res, i, msglen;
    struct iovec bkup[LU_MAXIOVEC];

    for(i = 0, msglen = 0; i < slen; i++){
	bkup[i] = siov[i];
	msglen += siov[i].iov_len;
    }

    if(slot->s_sock == NULL){
	TRACE("slot not connected.\n");
	if((res = slot_reconnect(info, slot)) < 0){
	    ERROR("failed to connect!\n");
	    goto out;
	}
    }

    if((res = do_execute(slot->s_sock, cmd, msglen, siov, slen, riov, rlen)) < 0){
	TRACE("do_execute failed!\n");

	if(signal_pending(current) && (!sigismember(&current->pending.signal, SIGPIPE))){
	    TRACE("interrupted by a signal. disconnecting this slot...\n");
	    sock_release(slot->s_sock);
	    slot->s_sock = NULL;
	    goto out;
	}
	
	if(sigismember(&current->pending.signal, SIGPIPE)){
	    TRACE("got a SIGPIPE\n");
	    sigdelset(&current->pending.signal, SIGPIPE);
	}

	if((res = slot_reconnect(info, slot)) < 0){
	    ERROR("could't reconnect!\n");
	    goto out;
	}
	    
	for(i = 0; i < slen; i++)
	    siov[i] = bkup[i];
	        
	if((res = do_execute(slot->s_sock, cmd, msglen, siov, slen, riov, rlen)) < 0){
	    ERROR("error executing command!\n");
	    goto out;
	}
    }
    
 out:
    return res;
}

int lu_getname(struct dentry *d, char *name, int max)
{
    int len = 0;
    struct dentry *p;
    struct lufs_sb_info *info = GET_INFO(d->d_sb);
    
    for(p = d; p != p->d_parent; p = p->d_parent)
	len += p->d_name.len + 1;

    TRACE("root: %s, rootlen: %d, namelen: %d\n", info->root, info->rootlen, len);
    
    if(len + info->rootlen > max)
	return -1;

    strcpy(name, info->root);

    if(len + info->rootlen == 0){
	strcat(name, "/");
    	goto out;
    }
    
    len += info->rootlen;

    name[len] = 0;
    for(p = d; p != p->d_parent; p = p->d_parent){
	len -= p->d_name.len;
	strncpy(&(name[len]), p->d_name.name, p->d_name.len);
	name[--len] = '/';
    }

out:
    TRACE("name resolved to %s\n", name);
    return 0;
}

int lu_getname_dumb(struct dentry *d, char *name, int max)
{
    int len = 0;
    struct dentry *p;

    for(p = d; p != p->d_parent; p = p->d_parent)
	len += p->d_name.len + 1;

    if(len > max)
	return -1;

    if(len == 0){
	name[0] = '/';
	name[1] = 0;
	goto out;
    }

    name[len] = 0;
    for(p = d; p != p->d_parent; p = p->d_parent){
	len -= p->d_name.len;
	strncpy(&(name[len]), p->d_name.name, p->d_name.len);
	name[--len] = '/';
    }

out:
    return 0;
}

static void init_root_dirent(struct lufs_sb_info *server, struct lufs_fattr *fattr)
{
    memset(fattr, 0, sizeof(struct lufs_fattr));
    fattr->f_nlink = 1;
    fattr->f_uid = server->config.uid;
    fattr->f_gid = server->config.gid;
    fattr->f_blksize = 512;
    fattr->f_ino = 2;
    fattr->f_mtime = CURRENT_TIME.tv_sec;
    fattr->f_mode = S_IRUSR | S_IRGRP | S_IROTH | S_IXUSR | S_IXGRP | S_IXOTH | S_IFDIR | server->config.dmode;
    fattr->f_size = 512;
    fattr->f_blocks = 1;
}

void lu_lookup_root(struct lufs_sb_info *server, struct lufs_fattr *fattr)
{
    struct server_slot *slot;
    struct iovec siov, riov;
    int res;

    TRACE("in\n");

    if((slot = lu_getslot(server)) == NULL){
	init_root_dirent(server, fattr);
	return;
    }
    
    if(server->rootlen)
	strcpy(slot->s_buf, server->root);
    else
	strcpy(slot->s_buf, "/");
	
    TRACE("stating root %s\n", slot->s_buf);

    siov.iov_base = slot->s_buf;
    siov.iov_len = strlen(slot->s_buf) + 1;
    riov.iov_base = fattr;
    riov.iov_len = sizeof(struct lufs_fattr);

    if((res = lu_execute(server, slot, PTYPE_STAT, &siov, 1, &riov, 1)) < 0){
	init_root_dirent(server, fattr);
	goto out;
    }

    if(PIS_ERROR(res)){
	WARN("stat failed!\n");
	init_root_dirent(server, fattr);
	goto out;
    }

    lu_fixattrs(server, fattr);

    fattr->f_ino = 2;

  out:
    TRACE("out\n");
    lu_putslot(slot);
}

void lu_fixattrs(struct lufs_sb_info *info, struct lufs_fattr *fattr)
{

    fattr->f_blksize = LU_BLOCKSIZE;
    
    if(S_ISREG(fattr->f_mode) || S_ISDIR(fattr->f_mode))
	fattr->f_blocks = (fattr->f_size + LU_BLOCKSIZE - 1) / LU_BLOCKSIZE;
    else
	fattr->f_blocks = 0;

    if(info->config.own_fs){

	if(!fattr->f_uid)
	    fattr->f_mode = (fattr->f_mode & ~S_IRWXU) | ((fattr->f_mode & S_IRWXO)*(S_IRWXU/S_IRWXO));

	if(!fattr->f_gid)
	    fattr->f_mode = (fattr->f_mode & ~S_IRWXG) | ((fattr->f_mode & S_IRWXO)*(S_IRWXG/S_IRWXO));
	
	fattr->f_uid = info->config.uid;
	fattr->f_gid = info->config.gid;

    }else{
	
	if(fattr->f_uid)
	    fattr->f_uid = info->config.uid;
	else
	    fattr->f_uid = LU_DEF_UID;

	if(fattr->f_gid)
	    fattr->f_gid = info->config.gid;
	else
	    fattr->f_gid = LU_DEF_GID;
    }

    if(fattr->f_mode & S_IFDIR)
	fattr->f_mode |= info->config.dmode;
    else
	fattr->f_mode |= info->config.fmode;
}

void lu_xlate_symlink(char *link, char *target, char *buf)
{
    int i;
    char *c1, *c2 = link;

    TRACE("translating %s->%s\n", link, target);

    for(c1 = strchr(link, '/'); c1 && !strncmp(link, target, c1 - link); c2 = c1, c1 = strchr(c1 + 1, '/'));

    TRACE("disjoint paths: %s, %s\n", c2, target + (c2 - link));

    for(i = 0, c1 = c2; (c1 = strchr(c1 + 1, '/')); i++);

    strcpy(buf, "./");
    
    for(; i > 0; i--)
	strcat(buf, "../");

    strcat(buf, target + (c2 - link) + 1);
    
    TRACE("absolute link resolved to %s\n", buf);
   
}

