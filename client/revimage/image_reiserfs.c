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

#include <sys/mount.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <asm/types.h>
#include <errno.h>
#include <stdio.h>
#include <mntent.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdlib.h>

#include "./reiserfsprogs/include/io.h"
#include "./reiserfsprogs/include/misc.h"
#include "./reiserfsprogs/include/reiserfs_lib.h"
#include "./reiserfsprogs/version.h"

#include "compress.h"
#include "ui_newt.h"

typedef struct p
{
  reiserfs_bitmap_t bm;
  unsigned long blocks;
}
CPARAMS;

unsigned long info1, info2;

void
allocated_sectors (PARAMS * p, CPARAMS *cp)
{
  unsigned long i, used = 0;
  unsigned long bitmap_lg;

  void setbit (unsigned char *base, unsigned long bit)
  {
    unsigned char mask[8] =
      { 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80 };

    base[bit >> 3] |= mask[bit & 7];
  }

  // TODO : check if block is really 4096 byte long...
  //
  p->nb_sect = cp->blocks * 8;

  p->bitmap = (unsigned char *) calloc (bitmap_lg = (p->nb_sect + 7) / 8, 1);
  p->bitmaplg = bitmap_lg;

  for (i = 0; i < p->nb_sect; i++)
    if (reiserfs_bitmap_test_bit (cp->bm, i / 8))
      {
	setbit (p->bitmap, i);
	used++;
      }

  info1 = p->nb_sect;
  info2 = used;
}

int
main (int argc, char *argv[])
{
  reiserfs_bitmap_t bm;
  reiserfs_filsys_t fs;
  PARAMS params;
  CPARAMS cp;
  int err = 0;
  int fd;

  if (argc != 3)
    {
      fprintf (stderr,
	       "Usage : image_reiserfs [device] [image prefix name]\n");
      exit (1);
    }

  //

  fs = reiserfs_open (argv[1], O_RDONLY, &err, 0);

  if ((!(fs)) || err)
    {
      debug ("Open failed\n");
      exit (1);
    }
  if (fs->s_blocksize != 4096)
    {
      debug ("Bad blocksize (!= 4096)\n");
      exit (1);
    }
  debug ("Bitmap  : %d bits\n", SB_BLOCK_COUNT (fs));
  bm = reiserfs_create_bitmap (SB_BLOCK_COUNT (fs));

  reiserfs_fetch_disk_bitmap (bm, fs);

  cp.bm = bm;
  cp.blocks = rs_block_count (fs->s_rs);
  assert (fs->s_blocksize == 4096);

  allocated_sectors (&params, &cp);

  reiserfs_close (fs);

  if (argv[2][0] == '?')
    exit (0);

  // Compress now
  //

  init_newt (argv[1], argv[2], info1, info2, argv[0]);
  fd = open (argv[1], O_RDONLY);
  compress_vol (fd, argv[2], &params);
  close (fd);
  stats();
  close_newt ();

  return 0;
}
