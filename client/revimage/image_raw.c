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

#include "config.h"

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

#include "compress.h"
#include "ui_newt.h"

typedef struct p
{
  unsigned long nb_sect;
  unsigned char *bitmap;
  unsigned long bitmap_lg;

}
PARAMS;

unsigned long info1, info2;

void
allocated_sectors (PARAMS * p, char *dev)
{
  int i, fd, bytes;
  int size;

  if ((fd = open (dev, O_RDONLY|O_DIRECT)) == -1) exit(1);
  
  if (ioctl(fd, BLKGETSIZE, &size) < 0) {
    /* it's a file not a block dev */
    struct stat st;
    
    fstat(fd, &st);
    size = (st.st_size/512);
    debug("Regular file: %d sectors\n",size);
  } else {
    debug("Block device: %d sectors\n",size);
  }
  close(fd);
  if (size == 0) exit(1);

  bytes = (size+7)/8;
  p->bitmap = (unsigned char *) calloc (1, bytes);
  p->bitmap_lg = bytes;

  p->nb_sect = size;

  for (i = 0; i < bytes-1; i++)
    p->bitmap[i] = 0xFF;
  /* mark remaining sectors */
  if (size & 7) {
    p->bitmap[i] = (0xFF >> (8-(size & 7))) & 0xFF;
  }
  
  info1 = size;
  info2 = size;

}

void
compress_vol (int fi, unsigned char *nameprefix, PARAMS * p)
{
  int i, j, k, nb;
  IMAGE_HEADER header;
  COMPRESS *c;
  unsigned char buffer[TOTALLG], *ptr, *dataptr;
  unsigned long remaining, used, skip;
  unsigned long long bytes = 0;
  unsigned short lg, datalg;
  FILE *fo, *fs, *index;
  unsigned char filename[128], firststring[200], *filestring,
    line[400], empty[] = "", numline[8];

  setblocksize(fi);
  //debug("Compressing Image :\n");

  //debug("- Bitmap lg    : %ld\n",p->bitmap_lg);
  nb = ((p->bitmap_lg + ALLOCLG - 1) / ALLOCLG);
  //debug("- Nb of blocks : %d\n",nb);

  remaining = p->bitmap_lg;
  ptr = p->bitmap;

  skip = 0;

  sprintf (firststring, "SECTORS=%ld|BLOCKS=%d|", p->nb_sect, nb);

  sprintf (filename, "%sidx", nameprefix);
  index = fopen (filename, "wt");

#include "compress-loop.h"

  fclose (index);
}

int
main (int argc, char *argv[])
{
  int fd;
  PARAMS params;

  if (argc != 3)
    {
      fprintf (stderr, "Usage : image_raw [device] [image prefix name]\n");
      exit (1);
    }

  if (argv[2][0] == '?')
    exit (0);

  allocated_sectors(&params, argv[1]);

  init_newt (argv[1], argv[2], info1, info2, argv[0]);
  fd = open (argv[1], O_RDONLY); //|O_DIRECT);
  compress_vol (fd, argv[2], &params);
  close (fd);
  stats();
  close_newt ();

  return 0;
}
