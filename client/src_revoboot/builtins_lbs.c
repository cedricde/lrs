/*
 *  $Id$
 */
/*
 *  GRUB LBS functions
 *  Copyright (C) 2002 Linbox Free & Alter Soft
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

#include <shared.h>
#include <filesys.h>
#include <term.h>
#include "pci.h"
#include "etherboot.h"

#ifdef SUPPORT_NETBOOT
#include "zlib.h"
#define INBUFF 8192
#define OUTBUFF 24064
unsigned char *zcalloc (long toto, int nb, int size);
void zcfree (long toto, unsigned char *zone);
#include "pxe.h"
#endif

/* ugly global vars */
int fat, ntfs, files, new_len, new_type;

/* auto fill mode ?! */
int auto_fill = 1;

/* total/current bytes of data to decompress */
unsigned int total_kbytes = 0;
unsigned int current_bytes = 0;

/* default = cannot access to grub's command line */
int nosecurity = 0;

/* current image name being restored */
char imgname[32];

/* proto�*/
int new_get (char *file, int sect, int *endsect, int table);


void
sendACK (int block, int from, int port)
{
  unsigned char buffer[4];

  buffer[0] = 0;
  buffer[1] = 4;
  buffer[2] = block >> 8;
  buffer[3] = block & 0xFF;
  udp_send (buffer, 4, from, port);
}

void
sendERR (unsigned char *str, int from, int port)
{
  unsigned char buffer[40], i;

  buffer[0] = 0;
  buffer[1] = 5;
  buffer[2] = 0;
  buffer[3] = 123;
  for (i = 0; i <= strlen (str); i++)
    buffer[4 + i] = str[i];
  udp_send (buffer, 4 + strlen (str) + 1, from, port);
}


//#define TFTPBLOCK 1432
#define TFTPBLOCK 1456
#define BLKSIZE "1456"
//#define TFTPBLOCK 2000
//#define BLKSIZE "2000"

typedef struct diskbuffer_
{
//              unsigned char data[OUTBUFF];    -> Direct to BUFFERADDR
  int full;
  int size;
} diskbuffer;

typedef struct tftpbuffer_
{
  unsigned char udp[4];
  unsigned char data[TFTPBLOCK + 16];
  int length;			// 0 if available
  struct tftpbuffer_ *next;
} tftpbuffer;

#define NB_BUF 10

int
get_empty (tftpbuffer * buff, int *i)
{
  int j;

  for (j = 0; j < NB_BUF; j++)
    if (buff[j].length == 0)
      {
	*i = j;
	return 1;
      }

  return 0;
}

int
tot_lg (tftpbuffer * buff)
{
  int i = 0;

  do
    {
      i += buff->length;
      if (buff->next)
	buff = buff->next;
      else
	return i;
    }
  while (1 == 1);
}

#define TFTPSTARTPORT 8192
int tftpport = TFTPSTARTPORT;

void
inc (int *ptr, int *mask)
{
  *mask <<= 1;
  if (*mask == 256)
    {
      *mask = 1;
      *ptr = *ptr + 1;
    }
}

int
val (unsigned char *string)
{
  char *ptr, *cp;
  int i;

  ptr = (char *) BUFFERADDR;

  while (*ptr)
    {
      cp = ptr;
      i = 0;
      while (cp[i] == string[i])
	{
	  i++;
	}
      if ((string[i] == 0) && (cp[i] == '='))
	{
	  cp = cp + i + 1;
	  break;
	}
      cp = NULL;
      ptr++;
    }

  if (cp)
    {
      safe_parse_maxint (&cp, &i);
      return i;
    }

  return -1;
}

int
exist (unsigned char *string)
{
  char *ptr, *cp;
  int i;

  ptr = (char *) BUFFERADDR;

  while (*ptr)
    {
      cp = ptr;
      i = 0;
      while (cp[i] == string[i])
	{
	  i++;
	}
      if ((string[i] == 0) && (cp[i] == '='))
	{
	  return 1;
	}
      ptr++;
    }

  return 0;
}

/* inc */
int
inc_func (char *arg, int flags)
{
  unsigned char buffer[] = " xxxx\0";

  buffer[0] = 0xEC;
  buffer[1] = arg[0];
  buffer[2] = arg[1];
  buffer[3] = arg[2];
  buffer[4] = arg[3];

  udp_init ();
  udp_send_withmac (buffer, 6, 1001, 1001);
  udp_close ();

  return 0;
}

/* setdefault */
int
setdefault_func (char *arg, int flags)
{
  unsigned char buffer[] = " x\0";
  int i;

  safe_parse_maxint (&arg, &i);

  buffer[0] = 0xCD;
  buffer[1] = i & 255;

  udp_init ();
  udp_send_withmac (buffer, 3, 1001, 1001);
  udp_close ();

  return 0;
}

/* nosecurity */
int
nosecurity_func (char *arg, int flags)
{
  nosecurity = 1;

  return 0;
}


void
drive_info (unsigned char *buffer)
{
  int i, err;
  struct geometry geom;

  unsigned long partition, start, len, offset, ext_offset;
  unsigned int type, entry;
  unsigned char *buf = (char *) SCRATCHADDR;
  unsigned char disk[] = "(hdX)";

  for (i = '0'; i <= '9'; i++)
    {

      disk[3] = i;

      set_device (disk);
      err = get_diskinfo (current_drive, &geom);
      //      printf("err=%d\n", err);
      if (err)
	continue;

      grub_sprintf (buffer, "D:%s:CHS(%d,%d,%d)=%d\n", disk, geom.cylinders,
		    geom.heads, geom.sectors, geom.total_sectors);
      grub_printf ("%s: %d MB\n", disk, geom.total_sectors / 2048);
      while (*buffer)
	buffer++;

      start = 0;
      type = 0;
      len = geom.total_sectors;
      partition = 0xFFFFFF;

      while (next_partition
	     (current_drive, 0xFFFFFF, &partition, &type, &start, &len,
	      &offset, &entry, &ext_offset, buf))
	{
	  if ((type) && ((type != 5) && (type != 0xf) && (type != 0x85)))
	    {
	      grub_sprintf (buffer, "P:%d,t:%x,s:%d,l:%d\n",
			    (partition >> 16), type, start, len);
	      grub_printf (" P:%d,t:%x,s:%d,l:%d\n", (partition >> 16), type,
			   start, len);
	      while (*buffer)
		buffer++;
	    }
	}
    }
}


/* partcopy START NAME_PREFIX [type] */
int
partcopy_func (char *arg, int flags)
{
  int new_start;
  /* int start_cl, start_ch, start_dh;
     int end_cl, end_ch, end_dh; */
  int entry;
  char *mbr = (char *) SCRATCHADDR, *path;
  static int sendlog = 1;

  int i, j, curr;
  unsigned long save_drive;
  char name[64];
  int old_perc;
  int l1 = 0, l2 = '0', l3 = '0';

  /* Convert a LBA address to a CHS address in the INT 13 format.  */
  auto void lba_to_chs (int lba, int *cl, int *ch, int *dh);
  static void lba_to_chs (int lba, int *cl, int *ch, int *dh)
  {
    int cylinder, head, sector;

    sector = lba % buf_geom.sectors + 1;
    head = (lba / buf_geom.sectors) % buf_geom.heads;
    cylinder = lba / (buf_geom.sectors * buf_geom.heads);

    if (cylinder >= buf_geom.cylinders)
      cylinder = buf_geom.cylinders - 1;

    *cl = sector | ((cylinder & 0x300) >> 2);
    *ch = cylinder & 0xFF;
    *dh = head;
  }


  /* Get the drive and the partition.  */
  if (!set_device (arg))
    return 1;

  /* The drive must be a hard disk.  */
  if (!(current_drive & 0x80))
    {
      errnum = ERR_BAD_ARGUMENT;
      return 1;
    }

  /* The partition must a primary partition.  
     if ((current_partition >> 16) > 3
     || (current_partition & 0xFFFF) != 0xFFFF)
     {
     errnum = ERR_BAD_ARGUMENT;
     return 1;
     }
   */

  entry = current_partition >> 16;

  save_drive = current_drive;

  /* update the disk geometry */
  get_diskinfo (current_drive, &buf_geom);
  if (biosdisk (BIOSDISK_READ, current_drive, &buf_geom, 0, 1, SCRATCHSEG))
    {
      grub_printf ("Error reading the 1st sector on disk %d\n",
		   current_drive);
      //return 1;
    }

#if 0
  grub_printf ("GEO : %d, %d, %d, %d E: %d DR: %d err=%d\n",
	       buf_geom.total_sectors, buf_geom.cylinders, buf_geom.heads,
	       buf_geom.sectors, entry, current_drive, 0);
#endif

  /* Get the new partition start.  */
  arg = skip_to (0, arg);

  if (entry <= 3)
    {
      // old code ? remove it ?
      if (grub_memcmp (arg, "-first", 6) == 0)
	new_start = buf_geom.sectors;
      else if (grub_memcmp (arg, "-next", 5) == 0)
	new_start =
	  buf_geom.sectors *
	  (((PC_SLICE_START (mbr, (entry - 1))) +
	    (PC_SLICE_LENGTH (mbr, (entry - 1))) + (buf_geom.sectors -
						    1)) / buf_geom.sectors);
      else if (!safe_parse_maxint (&arg, &new_start))
	return 1;
    }
  else if (!safe_parse_maxint (&arg, &new_start))
    return 1;


  /* get file path */
  path = skip_to (0, arg);

  /* find the image name */
  for (i = grub_strlen(path); i > 0; i--)
    {
      if (path[i] == '/') break;
    }
  for (j = i-1; j > 0; j--)
    {
      if (path[j] == '/') break;      
    }
  grub_memmove(imgname, &path[j+1], i-j);
  imgname[i-j-1] = '\0';

  /* try to get image size */
  if (total_kbytes == 0) {
    int i, olddrive = current_drive;

    strcpy(name, path);
    for (i = grub_strlen(name); i > 0; i--)
      {
	if (name[i] == '/') break;
      }
    strcpy(&name[i+1], "size.txt");

    if (new_tftpdir(name) < 0) {
      total_kbytes = 0;
    } else {
      if (grub_open (name)) {
	char buf[17], *ptr = buf;

	grub_read(ptr, 16);	
	safe_parse_maxint(&ptr, &total_kbytes);
	grub_printf("KB to download: %d\n", total_kbytes);
	grub_close();
      }
    }
    current_drive = olddrive;
  }

  grub_printf ("\nCopy from sector : %d\n", new_start);


  fat = 0;
  ntfs = 0;
  files = 1;
  new_len = -1;
  new_type = -1;
  curr = new_start;

  /* tell the LBS that we will restore a partition */
  if (sendlog) {
    udp_init ();
    grub_sprintf(name, "L2-%s", imgname);
    udp_send_lbs (name, grub_strlen(name));
    udp_close ();
    sendlog = 0;
  }

  for (i = 0; i < files; i++)
    {
      //    grub_printf("-> %d/%d : \r",i+1,files);
      old_perc = -1;

      grub_sprintf (name, "%s%d%c%c", path, l1, l2, l3);
      l3++;
      if (l3 > '9')
	{
	  l2++;
	  l3 = '0';
	  if (l2 > '9')
	    {
	      l1++;
	      l2 = '0';
	    }
	}

      if (new_get (name, curr, &curr, 0))
	{
	  errnum = ERR_FILE_NOT_FOUND;
	  return 1;
	}
    }
  grub_printf ("\nOne partition successfully restored.\n\n");

  return 0;
}

/* ptabs */
int
ptabs_func (char *arg, int flags)
{
  char buf[516];
  char *secbuf = (char *) SCRATCHADDR;
  unsigned long sect;
  int save_drive, i, nb = 0;
  char *sep = "\n================================================================================\n";

  if (!set_device (arg))
    return 1;

  save_drive = current_drive;

  // warning message
  grub_sprintf(buf, "%s/etc/warning.txt", basedir);
  if (new_tftpdir(buf) >= 0) 
    {
      if (grub_open (buf)) {
	char c;
	grub_printf(sep);
	while (grub_read (&c, 1))
	  grub_putchar (c);
	grub_printf(sep);
	grub_close ();
      }
    }

  arg = skip_to (0, arg);

  if (!grub_open (arg))
    return 1;

  while (grub_read (buf, 516))
    {
      sect = *(unsigned long *) buf;

//    printf("Writing sect : %d\n",sect);

      for (i = 0; i < 512; i++)
	secbuf[i] = buf[i + 4];

      current_drive = save_drive;
      buf_track = -1;
      if (biosdisk
	  (BIOSDISK_WRITE, current_drive, &buf_geom, sect, 1, SCRATCHSEG))
	{			
	  errnum = ERR_WRITE;
	  return 1;
	}
      nb++;
    }

  printf ("Wrote %d sectors\n", nb);

  grub_close ();

  return 0;
}

/* send a fatal error */
void fatal(void)
{
  udp_init ();
  udp_send_lbs ("L8", 2);
  udp_close ();
}

/* get and decompress tftp files */
int
new_get (char *file, int sect, int *endsect, int table)
{

  unsigned long in_sect = sect;

  unsigned char buffer[2100], alloc[24064 - 2048], *cp;
  unsigned char compressed[INBUFF], compressed_full, *ptr;
  int compr_lg, firstblock, sectptr, sectmask, nb, maxpack;
  int i, size, src, to, block, op, tftpend, end, newp, oldp, lastblk;
  int resendack = 0;
  unsigned char progr, progress[] = "/-\\|";
  int save_sect;

  z_stream zptr;
  int state;
  int ret;
  int ltime;
  int timeout;
restart:
  save_sect = in_sect;
  sect = in_sect;
  compr_lg = 0;
  firstblock = 1;
  maxpack = 0;
  to = 0;
  tftpend = 0;
  end = 0;
  newp = -1;
  oldp = -1;
  progr = 0;
  state = Z_SYNC_FLUSH;

  tftpbuffer tbuf[NB_BUF], *first, *last, *curr;
  diskbuffer dbuf;

  dbuf.full = 0;
  for (i = 0; i < NB_BUF; i++)
    {
      tbuf[i].length = 0;
      tbuf[i].next = NULL;
    }
  first = last = curr = NULL;
  compressed_full = 0;

  zptr.zalloc = Z_NULL;		//zcalloc;
  zptr.zfree = Z_NULL;		//zcfree;

  zptr.avail_in = 0;
  zptr.next_out = (char *) BUFFERADDR;	// was dbuf.data;
  zptr.avail_out = OUTBUFF;

  inflateInit (&zptr);

  for (i = 0, ret = 0; i < strlen (file); i++)
    if (file[i] == '/')
      ret = i;
  grub_printf
    ("\r                                                                              "
     "\rGet %s : ", file + ret + 1);

  buffer[0] = 0;
  buffer[1] = 1;
  strcpy (buffer + 2, file);
  i = 2 + strlen (file) + 1;
  strcpy (buffer + i, "octet");
  strcpy (buffer + i + 6, "tsize");
  strcpy (buffer + i + 12, "0");
  strcpy (buffer + i + 14, "blksize");
  strcpy (buffer + i + 22, BLKSIZE);

  udp_init ();

  lastblk = -1;
  tftpport++;
  if (tftpport > TFTPSTARTPORT + 127)
    tftpport = TFTPSTARTPORT;	/* helper for traffic shaping */

  udp_send (buffer, i + 27, tftpport, 69);	/* Request */
  to = 69;
  ltime = getrtsecs ();
  timeout = 0;

  do
    {
      do			/* while udp_get */
	{

	  if (dbuf.full)
	    {
	      if (firstblock)
		{
		  fast_memmove (alloc, (char *) BUFFERADDR + 2048,
				24064 - 2048);
//                      grub_printf("%s",(char *)BUFFERADDR);
		  firstblock = 0;
		  sectptr = 0;
		  sectmask = 1;

		  save_sect += val ("ALLOCTABLELG") * 8;

		  if (exist ("FAT32"))
		    fat = 1;
		  if (exist ("NTFS"))
		    ntfs = 1;

		  if (exist ("BLOCKS"))
		    {
		      unsigned short xypos;
		      files = val ("BLOCKS");
#ifdef DEBUG
		      grub_printf ("\n%d blocks\n", files);
#endif
		      xypos = getxy ();
		      gotoxy (50, (xypos & 255) - 1);
		      grub_printf ("Blocks to get: %d", files);
		      gotoxy (xypos >> 8, xypos & 255);
		    }
		  if (exist ("SECTORS"))
		    {
		      new_len = val ("SECTORS");
#ifdef DEBUG
		      grub_printf ("\n%d sectors\n", new_len);
#endif
		    }
		  if (exist ("TYPE"))
		    {
		      new_type = val ("TYPE");
#ifdef DEBUG
		      grub_printf ("\nType : %d\n", new_type);
#endif
		    }
		}
	      else
		{
		  for (i = 0; i < dbuf.size / 512;)
		    {
		      while (!(alloc[sectptr] & sectmask))
			{
			  sect++;
			  inc (&sectptr, &sectmask);
			}
		      nb = 0;
		      while ((alloc[sectptr] & sectmask)
			     && ((i + nb) < dbuf.size / 512))
			{
			  nb++;
			  inc (&sectptr, &sectmask);
			}

		      if (sect < buf_geom.total_sectors)
			{
			  if ((sect + nb) > buf_geom.total_sectors)
			    {
			      nb = buf_geom.total_sectors - sect;
			      printf ("End of disk, flushing %d sectors\n",
				      nb);
			    }
			  buf_track = -1;
			  ret =
			    biosdisk (BIOSDISK_WRITE, current_drive,
				      &buf_geom, sect, nb,
				      BUFFERSEG + i * 32);
			  if (ret)
			    {
			      grub_printf
				("\n!!! Disk Write Error (%d) sector %d, drive %d\nPress a key\n",
				 ret, sect, current_drive);
#if 0
			      grub_printf ("GEO : %d, %d, %d, %d E: %d DR: %d err=%d\n",
					   buf_geom.total_sectors, buf_geom.cylinders, buf_geom.heads,
					   buf_geom.sectors, 0, current_drive, 0);
#endif
			      fatal ();
			      getkey ();
			    }
			}
		      else
			{
			  printf
			    ("\n!!! Writing after end of disk (%d>=%d)\nPress a Key\n",
			     sect, buf_geom.total_sectors);
			  fatal();
			  getkey ();
			}
		      if (maxpack)
			{
			  if (oldp != newp)
			    {
			      int i;
			      int percent = 0;

			      grub_printf (" [");
			      for (i = 0; i < 32; i++)
				if (i < newp)
				  grub_printf ("=");
				else
				  grub_printf (" ");

			      if (total_kbytes != 0) 
				percent = (((current_bytes/1024)*100)/total_kbytes);
			      if (percent > 99) percent = 99;		    

			      grub_printf ("] %c  %d%%", progress[progr], percent);
			      progr = (progr + 1) & 3;
			      for (i = 0; i < 41; i++)
				grub_printf ("\b");
			      if (percent >= 10) 
				grub_printf ("\b");
			      oldp = newp;
			    }
			}
		      else
			{
			  grub_printf ("%c\b", progress[progr]);
			  progr = (progr + 1) & 3;
			}

		      i += nb;
		      sect += nb;
		    }
		}

	      zptr.next_out = (char *) BUFFERADDR;	// was dbuf.data;
	      zptr.avail_out = OUTBUFF;
	      dbuf.full = 0;
	      if (end == 1)
		{
		  end = 2;
		}
	      goto endturn;
	    }

	  if (!end && (compressed_full))
	    {
	      if (zptr.avail_in == 0)
		{
		  zptr.avail_in = compr_lg;
		  zptr.next_in = compressed;
		}
//                              else grub_printf("b");
	    }

	  if ((zptr.avail_out > 0) && (zptr.avail_in > 0))
	    {
//               grub_printf("Pre : avin = %d , avout = %d\n",zptr.avail_in,zptr.avail_out);
	      ret = inflate (&zptr, state);

	      if ((ret == Z_BUF_ERROR) && (zptr.avail_out == 0))
		ret = Z_OK;

	      if (ret == Z_STREAM_END)
		{
//                      grub_printf("Post: avin = %d , avout = %d (ret=%d)\n",zptr.avail_in,zptr.avail_out,ret);
		  state = Z_FINISH;
		  ret = Z_OK;
		  end = 1;
		  dbuf.full = 1;
		  dbuf.size = OUTBUFF - zptr.avail_out;
		  goto endturn;
		}

	      if (ret != Z_OK)
		{
		  grub_printf ("Post: avin = %d , avout = %d (ret=%d)\n",
			       zptr.avail_in, zptr.avail_out, ret);
		  inflateEnd (&zptr);
		  sendERR ("Error ZLIB", tftpport, to);
		  udp_close ();
		  goto restart;
		}

	      if (zptr.avail_in == 0)
		compressed_full = 0;

	      if (zptr.avail_out == 0)
		{
		  dbuf.full = 1;
		  dbuf.size = OUTBUFF - zptr.avail_out;
		}

	      goto endturn;
	    }

	  if ((first && (tot_lg (first) >= INBUFF))
	      || (tftpend && first && tot_lg (first) > 0))
	    {
	      if (compressed_full)
		grub_printf ("B");
	      else
		{
		  if (tftpend)
		    i = tot_lg (first);
		  else
		    i = INBUFF;
		  if (i > INBUFF)
		    i = INBUFF;
		  ptr = compressed;
		  compr_lg = i;
		  while (i > 0)
		    {
		      if (first->length <= i)
			{
//                 grub_printf("F");
			  fast_memmove (ptr, first->data, first->length);
			  i -= first->length;
			  ptr += first->length;
			  curr = first->next;
			  first->length = 0;
			  first->next = NULL;
			  if (last == first)
			    last = NULL;
			  first = curr;
			}
		      else
			{
//                 grub_printf("h");
			  fast_memmove (ptr, first->data, i);
			  ptr += i;
			  fast_memmove (first->data, first->data + i,
					first->length - i);
			  first->length -= i;
			  i = 0;
			}
		    }
		  compressed_full = 1;
		}
	    }
	endturn:
	  if (getrtsecs () != ltime)
	    {
#if 0
	      int val;
	      asm (
		   "movl %1, %%eax;"
		   "movl %%ebp, %0;"
		   :"=&r"(val) /* y is output operand, note the  & constraint modifier. */
		   :"r"(val)   /* x is input operand */
		   :"%eax"); /* %eax is clobbered register */
	      grub_printf("%x ", val);
#endif
	      // called every second
	      timeout++;
	      ltime = getrtsecs ();
	      if (timeout > 10)
		{
		  grub_printf ("TFTP Timeout...\n");
		  inflateEnd (&zptr);
		  sendERR ("Error Timeout", tftpport, to);
		  udp_close ();
		  goto restart;
		}
	    }
	}
      while (dbuf.full || !get_empty (tbuf, &i) 
	     || (!tftpend && udp_get (tbuf[i].udp, &size, tftpport, &src)));

//      grub_printf("-> %d %d : ",size,src);
//      grub_printf("%x %x\n",buffer[0],buffer[1]);
      if (!tftpend)
	{
	  unsigned char *buffer;
	  ltime = getrtsecs ();
	  timeout = 0;
	  buffer = tbuf[i].udp;
	  op = buffer[1] + 256 * buffer[0];

	  switch (op)
	    {
	    case 0x06:
	      grub_printf ("...");
	      if (lastblk != -1)
		{
		  inflateEnd (&zptr);
		  sendERR ("Got unexpected OACK", tftpport, to);
		  udp_close ();
		  goto restart;
		}
	      lastblk = 0;
	      cp = buffer + 8;
	      safe_parse_maxint (&cp, &maxpack);
	      maxpack /= TFTPBLOCK;
	      to = src;
	      sendACK (0, tftpport, to);
	      break;
	    case 0x03:
	      block = buffer[3] + 256 * buffer[2];
	      if (block == lastblk)
		{
		  /* The Server retransmitted the packet: Let's ACK but throw away data */
		  grub_printf ("Got same packet number...%x\n", block);
		  /* If we send an ACK the tftp server must not have the Appentice Sorcerer Syndrome 
		   * described in RFC 1123, or the network will blow !
		   */
		  inflateEnd (&zptr);
		  udp_close ();
		  goto restart;

		  //resendack = block;
		  //break;
		}
	      else if (block != (lastblk + 1))
		{
		  grub_printf ("Got wrong packet number...%d should be %d\n",
			       block, lastblk + 1);
		  inflateEnd (&zptr);
		  sendERR ("Got wrong packet number", tftpport, to);
		  udp_close ();
		  goto restart;
		}
	      else
		{
		  resendack = 0;
		  lastblk = block;
		  //grub_printf("DATA : %x (%d)\r",block,size);
		  if (maxpack > 0)
		    newp = (32 * block) / maxpack;
		  else
		    newp = oldp;
		  sendACK (block, tftpport, to);
		  //if (!get_empty(tbuf,&i)) {grub_printf("No TFTP buffer free...\n");goto nel;}
		  if (last)
		    last->next = &tbuf[i];
		  else
		    first = &tbuf[i];
		  //grub_memmove(tbuf[i].data,buffer+4,size-4);
		  tbuf[i].length = ((size - 4) < TFTPBLOCK) ? size - 4 : TFTPBLOCK;
		  current_bytes += tbuf[i].length;
		  last = &tbuf[i];
		  if (size - 4 < TFTPBLOCK)
		    {
#ifdef DEBUG
		      grub_printf ("End (%d)", size - 4);
#endif
		      tftpend = 1;
		    }
		}
	      break;
	    default:
	      grub_printf ("\nDEF : %x %x \n", buffer[0], buffer[1]);
	      if (buffer[1] == 5)
		{
		  grub_printf ("File not found...\n");
		  inflateEnd (&zptr);
		  udp_close ();
		  return 1;
		}
	      for (i = 0; i < NB_BUF; i++)
		grub_printf ("%d %d -> %x\n", i, tbuf[i].length,
			     tbuf[i].next);
	      inflateEnd (&zptr);
	      sendERR ("Error TFTP", tftpport, to);
	      udp_close ();
	      goto restart;
	    }
//        if (first&&tftpend) grub_printf("Remain : %d\n",tot_lg(first));
	}
    }
  while (end != 2);

  grub_printf (".");

  inflateEnd (&zptr);
  udp_close ();
  *endsect = save_sect;
  return 0;
}



/* SMBios */
char *smbios_addr = NULL;
__u16 smbios_len = 0;
__u16 smbios_num = 0;
__u8 *smbios_base =  NULL;



/*
 * find smbios area 
 * ret: 0=nothing found, 1=ok
 */
int smbios_init(void)
{
  char *check;

  for (check = (char *)0xf0000; check <= (char *)0xfffe0; check += 16)
    {
      if (grub_memcmp(check, "_SM_", 4) == 0)
	if (grub_memcmp(check+16, "_DMI_", 5) == 0) 
	  {
	    smbios_addr = check;
	    smbios_len = *(__u16 *)(check+0x16);
	    smbios_num = *(__u16 *)(check+0x1C);
	    smbios_base = *(__u32 *)(check+0x18);
	    if (smbios_base == 0 || smbios_num == 0 || smbios_len == 0) continue;
#ifdef DEBUG
	    grub_printf("SMBios found. version %d.%d len %d  num %d %x\n", *(check+6), *(check+7), smbios_len, smbios_num, smbios_base );
	    getkey();
#else
	    grub_printf("SMBios found. version %d.%d\n", *(check+6), *(check+7) );
#endif
	    return 1;
	  }     
    }
  return 0;
}

void smbios_sum(void)
{
  /* TODO */
}

char *smbios_string(__u8 *dm, __u8 s)
{
  char *bp=(char *)dm;
  int i;
  
  if(s==0) return "-";

  bp += dm[1];
  while(s>1 && *bp) 
    {
      bp += strlen(bp);
      bp++;
      s--;
    }
  if(!*bp) return "badindex";
  
  for(i=0; i<strlen(bp); i++)
    if(bp[i]<32 || bp[i]==127)
      bp[i]='.';
  return bp;
  
}

char *smbios_uuid(__u8 *dm, __u8 s)
{
  char *bp=(char *)dm;
  int i;
  
  if(s==0) return "-";

  bp += dm[1];
  while(s>1 && *bp) 
    {
      bp += strlen(bp);
      bp++;
      s--;
    }
  if(!*bp) return "badindex";
  
  for(i=0; i<strlen(bp); i++)
    if(bp[i]<32 || bp[i]==127)
      bp[i]='.';
  return bp;
  
}



__u8 *smbios_get(int rtype, __u8 **rnext)
{
  int i = 0;
  __u8 *ptr;
  __u8 *next;

  //  if (ptr == NULL)
    ptr = smbios_base;

  while (i < smbios_num)
    {
      int type, len, handle;

      type = ptr[0];
      len = ptr[1];
      handle = *(__u16 *)(ptr+2);

      if (len == 0) {
	//xif (*rnext != NULL) *rnext = NULL;
	return NULL;
      }

      next = ptr + len;
      while ((next-smbios_base+1) < smbios_len && (next[0] || next[1]))
	next++;
#ifdef DEBUG
      grub_printf("%d %d %x\n", type, len, handle);
#endif

      if (type == rtype) 
	{
	  //if (*rnext != NULL) *rnext = next + 2;
	  return ptr;
	}
      next += 2;
      ptr = next;
      i++;
    }
  //if (*rnext != NULL) *rnext = NULL;
  return NULL;
}


/*
 * Returns pointers to: Manufacturer, Product Name, Version, Serial Number, UUID
 */
void smbios_get_sysinfo(char **p1, char **p2, char **p3, char **p4, char **p5) 
{
  __u8 *ptr;

  ptr = smbios_get(1, NULL);
  if (ptr == NULL) return;
  *p1 = smbios_string(ptr, ptr[0x4]);
  *p2 = smbios_string(ptr, ptr[0x5]);
  *p3 = smbios_string(ptr, ptr[0x6]);
  *p4 = smbios_string(ptr, ptr[0x7]);
#ifdef DEBUG
  printf("Manufacturer: %s\n", *p1);
  printf("Product: %s\n", *p2);
  printf("Version: %s\n", *p3);
  printf("Serial: %s\n", *p4);
#endif
  /* in smbios 2.1+ only */
  *p5 = &ptr[8];
}

/*
 * Returns pointers to: Vendor, Version, Release
 */
void smbios_get_biosinfo(char **p1, char **p2, char **p3) 
{
  __u8 *ptr;

  ptr = smbios_get(0, NULL);
  if (ptr == NULL) return;
  *p1 = smbios_string(ptr, ptr[0x4]);
  *p2 = smbios_string(ptr, ptr[0x5]);
  *p3 = smbios_string(ptr, ptr[0x8]);
#ifdef DEBUG
  printf("Vendor: %s\n", *p1);
  printf("Version: %s\n", *p2);
  printf("Date: %s\n", *p3);
  getkey();
#endif
}

/*
 * Returns pointers to: Vendor, Type 
 */
void smbios_get_enclosure(char **p1, char **p2) 
{
  __u8 *ptr;

  ptr = smbios_get(3, NULL);
  if (ptr == NULL) return;
  *p1 = smbios_string(ptr, ptr[0x4]);
  *p2 = &ptr[0x5];
}


/* Translate a special key to a common ascii code.  */
int
translate_keycode (int c)
{
    {
      switch (c)
	{
	case KEY_LEFT:
	  c = 2;
	  break;
	case KEY_RIGHT:
	  c = 6;
	  break;
	case KEY_UP:
	  c = 16;
	  break;
	case KEY_DOWN:
	  c = 14;
	  break;
	case KEY_HOME:
	  c = 1;
	  break;
	case KEY_END:
	  c = 5;
	  break;
	case KEY_DC:
	  c = 4;
	  break;
	case KEY_BACKSPACE:
	  c = 8;
	  break;
	}
    }
  
  return ASCII_CHAR (c);
}
