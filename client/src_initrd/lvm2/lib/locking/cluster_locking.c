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

/*
 * Locking functions for LVM.
 * The main purpose of this part of the library is to serialise LVM
 * management operations across a cluster.
 */

#include "lib.h"
#include "clvm.h"
#include "lvm-string.h"
#include "locking.h"
#include "locking_types.h"

#include <stddef.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <unistd.h>

#ifndef CLUSTER_LOCKING_INTERNAL
int lock_resource(struct cmd_context *cmd, const char *resource, int flags);
void locking_end(void);
int locking_init(int type, struct config_tree *cf, uint32_t *flags);
#endif

typedef struct lvm_response {
	char node[255];
	char *response;
	int status;
	int len;
} lvm_response_t;

/*
 * This gets stuck at the start of memory we allocate so we
 * can sanity-check it at deallocation time
 */
#define LVM_SIGNATURE 0x434C564D

/*
 * NOTE: the LVMD uses the socket FD as the client ID, this means
 * that any client that calls fork() will inherit the context of
 * it's parent.
 */
static int _clvmd_sock = -1;

/* FIXME Install SIGPIPE handler? */

/* Open connection to the Cluster Manager daemon */
static int _open_local_sock(void)
{
	int local_socket;
	struct sockaddr_un sockaddr;

	/* Open local socket */
	if ((local_socket = socket(PF_UNIX, SOCK_STREAM, 0)) < 0) {
		log_error("Local socket creation failed: %s", strerror(errno));
		return -1;
	}

	memset(&sockaddr, 0, sizeof(sockaddr));
	memcpy(sockaddr.sun_path, CLVMD_SOCKNAME, sizeof(CLVMD_SOCKNAME));

	sockaddr.sun_family = AF_UNIX;

	if (connect(local_socket,(struct sockaddr *) &sockaddr,
		    sizeof(sockaddr))) {
		int saved_errno = errno;

		log_error("connect() failed on local socket: %s",
			  strerror(errno));
		if (close(local_socket))
			stack;

		errno = saved_errno;
		return -1;
	}

	return local_socket;
}

/* Send a request and return the status */
static int _send_request(char *inbuf, int inlen, char **retbuf)
{
	char outbuf[PIPE_BUF];
	struct clvm_header *outheader = (struct clvm_header *) outbuf;
	int len;
	int off;
	int buflen;
	int err;

	/* Send it to CLVMD */
 rewrite:
	if ( (err = write(_clvmd_sock, inbuf, inlen)) != inlen) {
	        if (err == -1 && errno == EINTR)
		        goto rewrite;
		log_error("Error writing data to clvmd: %s", strerror(errno));
		return 0;
	}

	/* Get the response */
 reread:
	if ((len = read(_clvmd_sock, outbuf, sizeof(struct clvm_header))) < 0) {
	        if (errno == EINTR)
		        goto reread;
		log_error("Error reading data from clvmd: %s", strerror(errno));
		return 0;
	}

	if (len == 0) {
		log_error("EOF reading CLVMD");
		errno = ENOTCONN;
		return 0;
	}

	/* Allocate buffer */
	buflen = len + outheader->arglen;
	*retbuf = dbg_malloc(buflen);
	if (!*retbuf) {
		errno = ENOMEM;
		return 0;
	}

	/* Copy the header */
	memcpy(*retbuf, outbuf, len);
	outheader = (struct clvm_header *) *retbuf;

	/* Read the returned values */
	off = 1;		/* we've already read the first byte */
	while (off <= outheader->arglen && len > 0) {
		len = read(_clvmd_sock, outheader->args + off,
			   buflen - off - offsetof(struct clvm_header, args));
		if (len > 0)
			off += len;
	}

	/* Was it an error ? */
	if (outheader->status != 0) {
		errno = outheader->status;

		/* Only return an error here if there are no node-specific
		   errors present in the message that might have more detail */
		if (!(outheader->flags & CLVMD_FLAG_NODEERRS)) {
			log_error("cluster request failed: %s", strerror(errno));
			return 0;
		}

	}

	return 1;
}

/* Build the structure header and parse-out wildcard node names */
static void _build_header(struct clvm_header *head, int cmd, const char *node,
			  int len)
{
	head->cmd = cmd;
	head->status = 0;
	head->flags = 0;
	head->clientid = 0;
	head->arglen = len;

	if (node) {
		/*
		 * Allow a couple of special node names:
		 * "*" for all nodes,
		 * "." for the local node only
		 */
		if (strcmp(node, "*") == 0) {
			head->node[0] = '\0';
		} else if (strcmp(node, ".") == 0) {
			head->node[0] = '\0';
			head->flags = CLVMD_FLAG_LOCAL;
		} else
			strcpy(head->node, node);
	} else
		head->node[0] = '\0';
}

/*
 * Send a message to a(or all) node(s) in the cluster and wait for replies
 */
static int _cluster_request(char cmd, const char *node, void *data, int len,
			   lvm_response_t ** response, int *num)
{
	char outbuf[sizeof(struct clvm_header) + len + strlen(node) + 1];
	int *outptr;
	char *inptr;
	char *retbuf = NULL;
	int status;
	int i;
	int num_responses = 0;
	struct clvm_header *head = (struct clvm_header *) outbuf;
	lvm_response_t *rarray;

	*num = 0;

	if (_clvmd_sock == -1)
		_clvmd_sock = _open_local_sock();

	if (_clvmd_sock == -1)
		return 0;

	_build_header(head, cmd, node, len);
	memcpy(head->node + strlen(head->node) + 1, data, len);

	status = _send_request(outbuf, sizeof(struct clvm_header) +
			      strlen(head->node) + len, &retbuf);
	if (!status)
		goto out;

	/* Count the number of responses we got */
	head = (struct clvm_header *) retbuf;
	inptr = head->args;
	while (inptr[0]) {
		num_responses++;
		inptr += strlen(inptr) + 1;
		inptr += sizeof(int);
		inptr += strlen(inptr) + 1;
	}

	/*
	 * Allocate response array.
	 * With an extra pair of INTs on the front to sanity
	 * check the pointer when we are given it back to free
	 */
	outptr = dbg_malloc(sizeof(lvm_response_t) * num_responses +
			    sizeof(int) * 2);
	if (!outptr) {
		errno = ENOMEM;
		status = 0;
		goto out;
	}

	*response = (lvm_response_t *) (outptr + 2);
	outptr[0] = LVM_SIGNATURE;
	outptr[1] = num_responses;
	rarray = *response;

	/* Unpack the response into an lvm_response_t array */
	inptr = head->args;
	i = 0;
	while (inptr[0]) {
		strcpy(rarray[i].node, inptr);
		inptr += strlen(inptr) + 1;

		rarray[i].status = *(int *) inptr;
		inptr += sizeof(int);

		rarray[i].response = dbg_malloc(strlen(inptr) + 1);
		if (rarray[i].response == NULL) {
			/* Free up everything else and return error */
			int j;
			for (j = 0; j < i; j++)
				dbg_free(rarray[i].response);
			free(outptr);
			errno = ENOMEM;
			status = -1;
			goto out;
		}

		strcpy(rarray[i].response, inptr);
		rarray[i].len = strlen(inptr);
		inptr += strlen(inptr) + 1;
		i++;
	}
	*num = num_responses;
	*response = rarray;

      out:
	if (retbuf)
		dbg_free(retbuf);

	return status;
}

/* Free reply array */
static int _cluster_free_request(lvm_response_t * response)
{
	int *ptr = (int *) response - 2;
	int i;
	int num;

	/* Check it's ours to free */
	if (response == NULL || *ptr != LVM_SIGNATURE) {
		errno = EINVAL;
		return 0;
	}

	num = ptr[1];

	for (i = 0; i < num; i++) {
		dbg_free(response[i].response);
	}

	dbg_free(ptr);

	return 1;
}

static int _lock_for_cluster(unsigned char cmd, unsigned int flags, char *name)
{
	int status;
	int i;
	char *args;
	const char *node = "";
	int len;
	int saved_errno = errno;
	lvm_response_t *response = NULL;
	int num_responses;

	assert(name);

	len = strlen(name) + 3;
	args = alloca(len);
	strcpy(args + 2, name);

	args[0] = flags & 0xBF; /* Maskoff LOCAL flag */
	args[1] = 0;		/* Not used now */

	/*
	 * VG locks are just that: locks, and have no side effects
	 * so we only need to do them on the local node because all
	 * locks are cluster-wide.
	 * Also, if the lock is exclusive it makes no sense to try to
	 * acquire it on all nodes, so just do that on the local node too.
	 */
	if (cmd == CLVMD_CMD_LOCK_VG ||
	    (flags & LCK_TYPE_MASK) == LCK_EXCL ||
	    (flags & LCK_LOCAL))
		node = ".";

	status = _cluster_request(cmd, node, args, len,
				  &response, &num_responses);

	/* If any nodes were down then display them and return an error */
	for (i = 0; i < num_responses; i++) {
		if (response[i].status == EHOSTDOWN) {
			log_error("clvmd not running on node %s",
				  response[i].node);
			status = 0;
			errno = response[i].status;
		} else if (response[i].status) {
			log_error("Error locking on node %s: %s",
				  response[i].node,
				  response[i].response[0] ?
				  	response[i].response :
				  	strerror(response[i].status));
			status = 0;
			errno = response[i].status;
		}
	}

	saved_errno = errno;
	_cluster_free_request(response);
	errno = saved_errno;

	return status;
}

/* API entry point for LVM */
#ifdef CLUSTER_LOCKING_INTERNAL
static int _lock_resource(struct cmd_context *cmd, const char *resource,
			  int flags)
#else
int lock_resource(struct cmd_context *cmd, const char *resource, int flags)
#endif
{
	char lockname[PATH_MAX];
	int cluster_cmd = 0;

	assert(strlen(resource) < sizeof(lockname));

	switch (flags & LCK_SCOPE_MASK) {
	case LCK_VG:
		/* If the VG name is empty then lock the unused PVs */
		if (!resource || !*resource)
			lvm_snprintf(lockname, sizeof(lockname), "P_orphans");
		else
			lvm_snprintf(lockname, sizeof(lockname), "V_%s",
				     resource);

		cluster_cmd = CLVMD_CMD_LOCK_VG;
		flags &= LCK_TYPE_MASK;
		break;

	case LCK_LV:
		cluster_cmd = CLVMD_CMD_LOCK_LV;
		strcpy(lockname, resource);
		flags &= 0xffdf;	/* Mask off HOLD flag */
		break;

	default:
		log_error("Unrecognised lock scope: %d",
			  flags & LCK_SCOPE_MASK);
		return 0;
	}

	/* Send a message to the cluster manager */
	log_very_verbose("Locking %s at 0x%x", lockname, flags);

	return _lock_for_cluster(cluster_cmd, flags, lockname);
}

#ifdef CLUSTER_LOCKING_INTERNAL
static void _locking_end(void)
#else
void locking_end(void)
#endif
{
	if (_clvmd_sock != -1 && close(_clvmd_sock))
		stack;

	_clvmd_sock = -1;
}

#ifdef CLUSTER_LOCKING_INTERNAL
static void _reset_locking(void)
#else
void reset_locking(void)
#endif
{
	if (close(_clvmd_sock))
		stack;

	_clvmd_sock = _open_local_sock();
	if (_clvmd_sock == -1)
	        stack;
}

#ifdef CLUSTER_LOCKING_INTERNAL
int init_cluster_locking(struct locking_type *locking, struct config_tree *cft)
{
	locking->lock_resource = _lock_resource;
	locking->fin_locking = _locking_end;
	locking->reset_locking = _reset_locking;
	locking->flags = LCK_PRE_MEMLOCK;

	_clvmd_sock = _open_local_sock();
	if (_clvmd_sock == -1)
		return 0;

	return 1;
}
#else
int locking_init(int type, struct config_tree *cf, uint32_t *flags)
{
	_clvmd_sock = _open_local_sock();
	if (_clvmd_sock == -1)
		return 0;

	/* Ask LVM to lock memory before calling us */
	*flags |= LCK_PRE_MEMLOCK;

	return 1;
}
#endif
