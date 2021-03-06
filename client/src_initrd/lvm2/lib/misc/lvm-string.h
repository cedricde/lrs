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

#ifndef _LVM_STRING_H
#define _LVM_STRING_H

#include <stdio.h>
#include <stdarg.h>

struct pool;

/*
 * On error, up to glibc 2.0.6, snprintf returned -1 if buffer was too small;
 * From glibc 2.1 it returns number of chars (excl. trailing null) that would 
 * have been written had there been room.
 *
 * lvm_snprintf reverts to the old behaviour.
 */
int lvm_snprintf(char *buf, size_t bufsize, const char *format, ...);

int emit_to_buffer(char **buffer, size_t *size, const char *fmt, ...);

int split_words(char *buffer, unsigned max, char **argv);

char *build_dm_name(struct pool *mem, const char *vg,
                    const char *lv, const char *layer);

int split_dm_name(struct pool *mem, const char *dmname,
                  char **vgname, char **lvname, char **layer);

#endif
