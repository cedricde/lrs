/*
 *  $Id$
 */
/*
 *  Linbox Rescue Server
 *  Copyright (C) 2002-2005 Linbox FAS, Free & Alter Soft
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

#include "../config.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <linux/fs.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include "../zlib-1.2.1/zlib.h" 

#include "../compress.h"
#include "main.h"

#define BENCH 1
#define UI_READ_ERROR printf("!\n")

typedef struct {
  unsigned long nb_sect;
  unsigned char *bitmap;
  unsigned long bitmap_lg;
} PARAMS ;


void
compress_bench (int run)
{
  PARAMS *p, pp;
  IMAGE_HEADER header;
  COMPRESS *c;
  int i, j, k, size, fi, nb;
  unsigned long long bytes;
  unsigned char buffer[TOTALLG], *ptr, *dataptr;                                
  unsigned long remaining, used, skip;                                          
  unsigned short lg, datalg;                                                    
  FILE *fo, *fs, *index = NULL;
  unsigned char filename[128], firststring[200], *filestring, line[400], empty[] = "", numline[8]; 
  double t1, t2;

  t1=now();

  /* prepare the bitmap */
  size = 1024*2*10*(run);		/* 1O*run MB compression test */
  bytes = size/8;

  p = &pp;
  p->bitmap = (unsigned char *) calloc (1, bytes);
  p->bitmap_lg = bytes;
  p->nb_sect = size;
  for (i = 0; i < bytes-1; i++) {
    p->bitmap[i] = 0xFF;
  }

  /* open our test device */
  fi = open("/bin/sh", O_RDONLY);

  nb = ((p->bitmap_lg + ALLOCLG - 1) / ALLOCLG);
  remaining = p->bitmap_lg;
  ptr = p->bitmap;
  skip = 0;

#include "./compress-loop.h"

  close(fi);

  t2 = now();
  printf("Compression speed = %f MB/s\n", 10.0*run/(t2-t1));
}

void ui_write_error()
{

}
