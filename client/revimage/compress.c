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

//#include "config.h"

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <linux/fs.h>

#include "compress.h"

#define LARGE_OFF_T (((off_t) 1 << 62) - 1 + ((off_t) 1 << 62))                 

/* Check that off_t can represent 2**63 - 1 correctly.
     We can't simply define LARGE_OFF_T to be 9223372036854775807,
     since some C++ compilers masquerading as C compilers
     incorrectly reject 9223372036854775807.  */
/*	     
int off_t_is_large[(LARGE_OFF_T % 2147483629 == 721
                && LARGE_OFF_T % 2147483647 == 1) ? 1 : -1];
*/

#define BLOCKFLUSH 10

unsigned long long done, todo;

#if 0
void setblocksize(FILE *f)
{
    int bs=0, fd;
    
    fd = fileno(f);
    ioctl(fd, BLKBSZGET, &bs);
    bs = 512;
    if (ioctl(fd, BLKBSZSET, &bs)) {
	perror("Could not set block size to 512");
    }
    /* ioctl(fd, BLKBSZGET, &bs);
    printf("Block size= %d\n", bs); */

}

#else
void setblocksize(int fd)
{
    int bs=0;
    
    ioctl(fd, BLKBSZGET, &bs);
    bs = 512;
    if (ioctl(fd, BLKBSZSET, &bs)) {
	perror("Could not set block size to 512");
    }
    /* bs = 0;
    ioctl(fd, BLKBSZGET, &bs);
    printf("Block size= %d\n", bs); */

}
#endif

void
compress_init (COMPRESS ** c, int block, unsigned long long bytes,
	       FILE * index)
{
  *c = (COMPRESS *) malloc (sizeof (COMPRESS));
  (*c)->zptr = (z_streamp) malloc (sizeof (z_stream));
  (*c)->zptr->zalloc = Z_NULL;
  (*c)->zptr->zfree = Z_NULL;

//      deflateInit((*c)->zptr,Z_BEST_SPEED);
  deflateInit ((*c)->zptr, 3);

  (*c)->crc = adler32 (0L, Z_NULL, 0);
  (*c)->end = 0;
  (*c)->state = Z_NO_FLUSH;

  (*c)->header = 1;
  (*c)->block = block;
  (*c)->offset = 0;
  (*c)->f = index;
  (*c)->cbytes = bytes;
  (*c)->compressed_blocks = BLOCKFLUSH;

  (*c)->zptr->avail_out = OUTBUFF;
  (*c)->zptr->next_out = (*c)->outbuff;
}

void
compress_data (COMPRESS * c, unsigned char *data, int lg, FILE * out,
	       char end)
{
  int ret;
  size_t w;

  c->zptr->next_in = data;
  c->zptr->avail_in = lg;

  c->compressed_blocks++;

  if (c->compressed_blocks >= BLOCKFLUSH)
    {
      c->compressed_blocks = 0;
      c->state = Z_FULL_FLUSH;
    }

  if (end)
    c->end = 1;

  if (!c->header)
    {
      c->cbytes += lg;
      done += lg;
    }
  c->header = 0;

  do
    {
    deflate_again:
      //printf("Debug : IN : %ld / OUT : %ld\n",c->zptr->avail_in,c->zptr->avail_out);
      ret = deflate (c->zptr, (end == 0) ? c->state : Z_FINISH);

      if (c->zptr->avail_out == 0)
	{
	  w = fwrite (c->outbuff, OUTBUFF, 1, out);
	  if (w != 1)
	    compress_write_error ();
	  c->crc = adler32 (c->crc, c->outbuff, OUTBUFF);
	  c->zptr->avail_out = OUTBUFF;
	  c->zptr->next_out = c->outbuff;
	  c->offset += OUTBUFF;
	  goto deflate_again;
	}

      if (c->state != Z_NO_FLUSH)
	{			//printf("Debug : %d %d (%d)\n",c->zptr->avail_in,c->zptr->avail_out,ret);
	  if ((c->zptr->avail_in == 0) && (c->zptr->avail_out != 0))
	    {
	      // DEBUG code 
	      //fprintf (c->f, "%lld:%d-%ld\n", c->cbytes, c->block,
	      //       c->offset + OUTBUFF - c->zptr->avail_out);
	      c->state = Z_NO_FLUSH;
	    }
	}

      if (ret == Z_STREAM_END)
	{
	  w = fwrite (c->outbuff, OUTBUFF - c->zptr->avail_out, 1, out);
	  if ((w != 1) && (OUTBUFF - c->zptr->avail_out != 0))
	    compress_write_error ();
	  c->crc = adler32 (c->crc, c->outbuff, OUTBUFF - c->zptr->avail_out);
	  c->zptr->avail_out = OUTBUFF;
	  c->zptr->next_out = c->outbuff;
	  //printf("e");
	  return;
	}

      if (ret != Z_OK)
	{
	  printf ("ZLIB error in deflate : %d\n", ret);
	  exit (1);
	}

    }
  while ((c->zptr->avail_in) || (end));
}

unsigned long long
compress_end (COMPRESS * c, FILE * out)
{
  unsigned long long ret;

  if ((c->zptr->avail_out != OUTBUFF) || (!c->end))
    {				//printf("-");
      compress_data (c, NULL, 0, out, 1);
    }

  deflateEnd (c->zptr);
  free (c->zptr);
  {
    FILE *flog;
    flog = fopen ("/tmp/crc", "a+");
    fprintf (flog, "%d:%lx", c->block, c->crc);
    fclose (flog);
  }
  ret = c->cbytes;
  free (c);

  return ret;
}

void
compress_write_error (void)
{
  ui_write_error ();
  // loop foreever
  while (1)
    sleep (1);
}
