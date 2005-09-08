/*
 * Program launched to restore all partitions
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

/* How it works:
 * - mounts the filesystem with autorestore.sh
 * - opens and interprets conf.txt
 */

char *cvsid = "$Id$";

#define _GNU_SOURCE
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdarg.h>
#include <ctype.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>
#include <time.h>
#include <sys/ioctl.h>
#include <linux/hdreg.h>
#include <linux/fs.h>
#include <dirent.h>

#include <sys/socket.h>
#include <netinet/in.h>
#include <net/if.h>
#include <linux/sockios.h>

//#include "autosave.h"
#include "ui_newt.h"

#define DEBUG(a)
//#define TEST 1
//#define TEST_PARTONLY 1
#define LOGTXT "/revoinfo/log.restore"

#include "zlib.h"

#define INSIZE 2048

unsigned char *BUFFER;
unsigned char *Bitmap;
unsigned char *IN;
unsigned char zero[512];

unsigned long s_min = 0xFFFFFFFF, s_max = 0;

int dnum;
/* default NFS read/write size */
int rsize = 8192;

unsigned char buf[80];

unsigned char command[120];

unsigned char servip[40] = "";
unsigned char servprefix[80] = "";
unsigned char storagedir[80] = "";
char hostname[32] = "";

/* do we have the bios HD map ? */
int has_hdmap=0;
char * hdmap[65536];
unsigned int exclude[65536];
int nonewt = 0;


/* LDM's privhead */
typedef struct privhead_s {
  __u64     logical_disk_start;                                             
  __u64     logical_disk_size;                                              
  __u64     config_start;                                                   
  __u64     config_size;                                                    
} privhead;

/* */
typedef struct params_
{
  int bitindex;
  int fo;
  __u64 offset;
}
PARAMS;


/* proto */
int gethdbios(unsigned int sect);
int isexcluded(int d, int p);

/* Q&D IO abstraction layer */
struct fops_
{
  int (*get)(char *fname, int filenum);
  FILE * (*open)(char *fname, int filenum);
  int  (*close)(FILE *stream);
} fops;

/* KB decompressed */
int todo = 0, done = 0;

/*
 * printf() func with logging
 */
void myprintf( const char *format_str, ... )
{
    va_list ap;
    FILE *foerr;

    /* write some info */
    foerr = fopen(LOGTXT, "a");
    fprintf(foerr, "\n==== misc ====\n");
    va_start( ap, format_str );
    vfprintf( foerr, format_str, ap );
    va_end(ap);
    fclose(foerr);
}

/*
 * system() func with logging
 */
int mysystem(const char *s)
{
    char cmd[1024];
    char *redir = " 2>> " LOGTXT;
    FILE *foerr;

    strncpy(cmd, s, 1024 - strlen(redir) - 1);
    strcat(cmd, redir);

    /* write some info */
    foerr = fopen(LOGTXT, "a");
    // ctime()
    fprintf(foerr, "\n==== %s ====\n", s);
    fclose(foerr);
#ifdef TEST
    return 0;
#endif
    return (system(cmd));
    
}

/*
 * system() func with logging (logs stdout not stderr)
 */
int mysystem1(const char *s)
{
    char cmd[1024];
    char *redir = " 1>> " LOGTXT;
    FILE *foerr;

    strncpy(cmd, s, 1024 - strlen(redir) - 1);
    strcat(cmd, redir);

    /* write some info */
    foerr = fopen(LOGTXT, "a");
    // ctime()
    fprintf(foerr, "\n==== %s ====\n", s);
    fclose(foerr);

    return (system(cmd));
    
}

/* 
 * Fatal error
 */
void fatal(void)
{
  system("/bin/revosendlog 8");
  while (1)
    sleep(1);
}

/*
 * Restore a raw partition file to 'device'x
 */
void restore_raw(char *device, char *fname)
{
  char buffer[1024];
  __u32 sect;
  int fo, fp;

  fo = open(device, O_WRONLY | O_LARGEFILE);
  sprintf(buffer, "/revosave/%s", fname);
  fp = open(buffer, O_RDONLY | O_LARGEFILE);

  while (1) {
    if (read(fp, buffer, 516) == 0) {
      break;
    }
    sect = *(__u32 *) buffer;
    if (lseek64(fo, (__u64)512 * (__off64_t) sect, SEEK_SET) == -1) {
      DEBUG(printf("restore_raw: seek error\n"));
      ui_write_error(device, __LINE__, errno, fo);
    }
    if (write(fo, buffer+4, 512) != 512) {
      DEBUG(printf("restore_raw: write error\n"));
      ui_write_error(device, __LINE__, errno, fo);
    }
  }
  close(fp);
  if (ioctl(fo, BLKRRPART) < 0) {
    printf("Reloading partition table failed\n");
  }
  close(fo);
}


/* 
 * File ops
 */
int file_get(char *fname, int filenum)
{
  char f[64];
  struct stat st;

  sprintf(f, "%s%03d", fname, filenum);
  DEBUG (printf ("** File: %s **", f));
  chdir("/revosave");
  return (stat(f, &st));
}

FILE *file_open(char *fname, int filenum)
{
  char f[64];
  
  sprintf(f, "%s%03d", fname, filenum);
  return (fopen(f, "r"));
}

int file_close(FILE *stream)
{
  return fclose(stream);
}

/* 
 * Tftp ops
 */
int tftp_get(char *fname, int filenum)
{
  char f[64], cmd[512];
  struct stat st;

  sprintf(f, "%s%03d", fname, filenum);
  DEBUG (printf ("** File: %s **", f));
  chdir("/tmpfs");
  if (!nonewt) update_file(fname, filenum, -2, "Waiting", done);
  sprintf(cmd, "/bin/revowait %s", f);
  system(cmd);
  if (!nonewt) update_file(fname, filenum, -2, "Downloading", done);
  /* get files */
  do 
    {
      system("rm * >/dev/null 2>&1");
      sprintf(cmd, "/bin/atftp --tftp-timeout 10 --option \"blksize 4096\" --option multicast -g -r %s/%s/%s %s 69 2>/tmp/atftp.log", servprefix, storagedir, f, servip);
    } while (system(cmd));
  
  return (stat(f, &st));
}

FILE *tftp_open(char *fname, int filenum)
{
  char f[64];
  
  sprintf(f, "%s%03d", fname, filenum);
  return (fopen(f, "r"));
}

int tftp_close(FILE *stream)
{
  int ret = fclose(stream);
  /* delete files */
  //system("rm * >/dev/null 2>&1");
  return ret;
}

/*
 */
int
eof (int fd)
{
  __off64_t pos, end;
  pos = lseek64 (fd, 0, SEEK_CUR);
  if (pos < 0)
    {
      fprintf (stderr, "Error LSEEK : eof,pos\n");
    }
  end = lseek64 (fd, 0, SEEK_END);
  if (end < 0)
    {
      fprintf (stderr, "Error LSEEK : eof,end\n");
    }
  if (lseek64 (fd, pos, SEEK_SET) < 0)
    {
      fprintf (stderr, "Error LSEEK, reseek\n");
    }
  if (end == pos)
    return 1;
  return 0;
}

/*
 *
 */
void
fill (int fd, int bytes, int dir)
{
  /* fills are not larger than 90MB so an 'int'should be enough */
  int err = 0;

  if (lseek64 (fd, bytes, dir) < 0)
    {
      ui_write_error(__FILE__, __LINE__, errno, fd);
      err = 1;
    }
}


/*
 *
 */
void
flushToDisk (unsigned char *buff, unsigned char *bit, PARAMS * cp, int lg)
{
  unsigned char *ptr = buff;
  unsigned char mask[] = { 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80 };
  int indx = cp->bitindex;
  

// printf("Enter : bitindex -> %d\n",indx);
  while (lg > 0)
    {
      __u64 s = 0;
      while (!(bit[indx >> 3] & mask[indx & 7]))
	{
	  indx++;
	  cp->offset += 512;
	  s += 512;
	}
      if (( s != 0) && (lseek64 (cp->fo, s, SEEK_CUR) < 0))
	{
	  ui_write_error(__FILE__, __LINE__, errno, cp->fo);
	}
//      printf("Write @offset : %lld\t",cp->offset);
//      {int i; for(i=0;i<15;i++) printf("%02x ",ptr[i]); printf("\n");}
      if (cp->fo)
	{
	  if (write (cp->fo, ptr, 512) != 512)
	    {
	      ui_write_error(__FILE__, __LINE__, errno, cp->fo);
	    }
	}
      cp->offset += 512;
      ptr += 512;
      indx++;
      lg -= 512;
    }
// printf("Exit  : bitindex -> %d\n",indx);
  cp->bitindex = indx;
}


/*
 *
 */
void restore(char *device, unsigned int sect, char *fname)
{
  int fo;			/* output device */
  z_stream zptr;
  int state, filenum, fmax = -1;
  int ret, firstpass, bitmaplg;
  FILE *fi;
  PARAMS currentparams;
  __u64 i, starto;

  currentparams.offset = 512*(__u64)sect;
  currentparams.bitindex = 0;
  memset (zero, 0, 512);

  // log
  myprintf("restore: %s, offset %d sectors, %s\n", device, sect, fname);

  // open the output device
  fo = open(device, O_WRONLY | O_LARGEFILE );
  currentparams.fo = fo;
  DEBUG(printf ("Seeking to : %lld\n", currentparams.offset));
  i = lseek64 (currentparams.fo, currentparams.offset, SEEK_SET);
  if (i != currentparams.offset) {
    fprintf (stderr, "Seek error : %lld\n", i);
  }

  // open the data directory
  filenum = 0;
  while (!fops.get(fname ,filenum))
    {
      /*      name = ep->d_name;
      l = strlen(name);
      if (strncmp(name, fname, strlen(fname))) continue;
      if (l < 4) continue;
      if (!isdigit(name[l-1]) || !isdigit(name[l-2]) || !isdigit(name[l-3]) ) continue;	  
      DEBUG (printf ("** File: %s **", fname));
      */
    start:
      if (!nonewt) update_file(fname, filenum, fmax, device, done);

      state = Z_SYNC_FLUSH;
      firstpass = 1;
      bitmaplg = 0;
      
      zptr.zalloc = NULL;
      zptr.zfree = NULL;

      starto = lseek64(currentparams.fo, 0 , SEEK_CUR);	/* save the current offset */

      fi = fops.open (fname, filenum);
      if (fi == NULL)
	{
	  /*printf ("Cannot open input file\n");*/
	  system("/revobin/image_error \"Cannot open input file\"");
	  fatal();
	}

      zptr.avail_in = fread (IN, 1, INSIZE, fi);
            
      currentparams.offset = 0;
      currentparams.bitindex = 0;
      
      zptr.next_in = (unsigned char *) IN;
      zptr.next_out = (unsigned char *) BUFFER;	// was dbuf.data;
      zptr.avail_out = 24064;
      
      inflateInit (&zptr);

      do
	{
//  if (inflateSyncPoint(&zptr)) printf("#");

	      ret = inflate (&zptr, state);
	      if (!nonewt) update_progress( done + (zptr.total_in/1024) );

//  printf("-> %d : %d / %d\n",ret ,zptr.avail_in ,zptr.avail_out );

	      if ((ret == Z_OK) && (zptr.avail_out == 0))
		{
		  if (firstpass)
		    {
		      DEBUG (printf ("Params : *%s\n", BUFFER));
		      if (strstr (BUFFER, "BLOCKS="))
			{
			  int i = 0;
			  if (sscanf (strstr (BUFFER, "BLOCKS=") + 7, "%d", &i) == 1) {
			    fmax = i;
			  }
			}
		      if (strstr (BUFFER, "ALLOCTABLELG="))
			sscanf (strstr (BUFFER, "ALLOCTABLELG=") + 13, "%d",
				&bitmaplg);
		      memcpy (Bitmap, BUFFER + 2048, 24064 - 2048);
		      currentparams.bitindex = 0;
		      firstpass = 0;
		    }
		  else
		    {
		      flushToDisk (BUFFER, Bitmap, &currentparams, 24064);
		    }

		  zptr.next_out = (unsigned char *) BUFFER;
		  zptr.avail_out = 24064;
		}

	      if ((ret == Z_OK) && (zptr.avail_in == 0))
		{
		  zptr.avail_in = fread (IN, 1, INSIZE, fi);
		  zptr.next_in = (unsigned char *) IN;
		}
	    }
	  while (ret == Z_OK);

	  if (ret == Z_STREAM_END)
	    {
	      {
		if (firstpass)
		  {
		    DEBUG (printf ("Params : *%s*\n", BUFFER));
		    if (strstr (BUFFER, "BLOCKS="))
		      {
			int i = 0;
			if (sscanf (strstr (BUFFER, "BLOCKS=") + 7, "%d", &i) == 1) {
			  fmax = i;
			}
		      }
		    if (strstr (BUFFER, "ALLOCTABLELG="))
		      sscanf (strstr (BUFFER, "ALLOCTABLELG=") + 13, "%d",
			      &bitmaplg);
		    memcpy (Bitmap, BUFFER + 2048, 24064 - 2048);
		    zptr.next_out = (unsigned char *) BUFFER;
		    zptr.avail_out = 24064;
		  }
	      }

	      //printf ("Flushing to EOF ... (%d bytes)\n",
		//      24064 - zptr.avail_out);
	      flushToDisk (BUFFER, Bitmap, &currentparams, 24064 - zptr.avail_out);
	      zptr.next_out = (unsigned char *) BUFFER;
	      zptr.avail_out = 24064;
	    }

	  ret = inflate (&zptr, Z_FINISH);
	  inflateEnd (&zptr);


	  if (ret < 0)
	    {
	      /*printf ("Returned : %d\t", ret);
	        printf ("(AvailIn : %d / ", zptr.avail_in);
		printf ("AvailOut: %d)\n", zptr.avail_out);
		printf ("(TotalIn : %ld / ", zptr.total_in);
		printf ("TotalOut: %ld)\n", zptr.total_out);*/
	      ui_zlib_error(ret);
	      fops.close (fi);
	      fops.get(fname ,filenum); /* reget file */
	      /* return to the correct offset */
	      lseek64(currentparams.fo, starto , SEEK_SET);	

	      goto start;
	    }

	  /*printf ("Offset : %lld\n", currentparams.offset);
	  printf ("Bitmap index : %d\n", currentparams.bitindex);*/

	  if (bitmaplg)
	    {
	      if (bitmaplg * 8 > currentparams.bitindex)
		{
		  //printf ("Remaining bitmap : %d\n",
		  //	  bitmaplg * 8 - currentparams.bitindex);
		  currentparams.offset +=
		    (__u64)512 * (bitmaplg * 8 - currentparams.bitindex);
		  if (currentparams.fo)
		    {
		      fill (currentparams.fo,
		    	    (__u64)512 * (bitmaplg * 8 - currentparams.bitindex),
		    	    SEEK_CUR);
		    }
		}
	    }

	  filenum ++;
	  fops.close (fi);
	  done += zptr.total_in/1024;
	  if ((fmax != -1) && (filenum >= fmax)) break;
    }
  close(fo);
}

/*
 */
unsigned char *find(const char *str, const char *fname)
{
    FILE *f;

    f = fopen(fname, "r");
    if (f == NULL)
	return NULL;
    while (fgets((char *)buf, 80, f)) {
	if (strstr(buf, str)) {
	    fclose(f);
	    return strstr(buf, str) + strlen(str);
	}
    }
    fclose(f);
    return NULL;
}

/*
 * Get NFS server informations
 */
void netinfo(void)
{
    unsigned char *ptr, *ptr2;

    if ((ptr = find("Next server: ", "/etc/netinfo.log"))) {
	ptr2 = ptr;
	while (*ptr2) {
	    if (*ptr2 < ' ') {
		*ptr2 = 0;
		break;
	    } else
		ptr2++;
	}
	//printf ("*%s*\n", ptr);
	strcpy(servip, ptr);
    }

    if ((ptr = find("Boot file: ", "/etc/netinfo.log"))) {
	ptr2 = strstr(ptr, "/bin");
	if (ptr2)
	    *ptr2 = 0;
	//printf ("*%s*\n", ptr);
	strcpy(servprefix, ptr);
    }
}

/*
 * Get the LBS host name
 */
void gethost(void)
{
    FILE *f;

    hostname[0] = 0;

    f = fopen("/etc/lbxname", "r");
    if (f != NULL) {
        fscanf(f, "%31s", hostname);
	fclose(f);    
    }

    f = fopen("/revoinfo/hostname", "r");
    if (f == NULL)
	return ;
    fscanf(f, "%31s", hostname);
    fclose(f);    
}

void commandline(void)
{
    unsigned char *ptr, *ptr2;

    if ((ptr = find("revosavedir=", "/etc/cmdline"))) {
	ptr2 = ptr;
	while (*ptr2 != ' ')
	    ptr2++;
	*ptr2 = 0;
	//printf ("*%s*\n", ptr);
	strcpy(storagedir, ptr);
    }

    if ((ptr = find("slownfs", "/etc/cmdline"))) {
	/* decrease the NFS packet size */
	rsize = 1024;
    }

    /* default: mtftp restore */
    fops.open = tftp_open;
    fops.close = tftp_close;
    fops.get = tftp_get;
    
    if ((ptr = find("revorestorenfs", "/etc/cmdline"))) {
      /* nfs restore */
      fops.open = file_open;
      fops.close = file_close;
      fops.get = file_get;
    }
#ifdef TEST
      fops.open = file_open;
      fops.close = file_close;
      fops.get = file_get;
#endif
}

void setdefault(char *v)
{
  char buf[256];

  sprintf(buf, "/bin/revosetdefault %s", v!=NULL ? v : "0");
  system(buf);
}

/*
 * interprets the conf.txt file
 */
void restoreimage(void)
{
    FILE *f;
    char buf[255], buf2[255], lvm[255];
    int vgscan = 0;

    if ((f = fopen("/revosave/conf.txt", "r")) == NULL) return;    
    while (!feof(f)) {
      fgets(buf, 250, f);
      if (sscanf(buf, "%s", buf2) == 1) {
	/* buf=full line, buf2=1st keyword */
	DEBUG(printf("%s\n", buf2));
	if (!strcmp("ptabs", buf2)) {
	  // ptabs command
	  unsigned int d1;

	  if (sscanf(buf, " ptabs (hd%u) (nd)PATH/%s", &d1, buf2) == 2) {
	    DEBUG(printf("%d,%s\n", d1, buf2));
	    // restore the files to the device
#ifdef TEST
	    //restore_raw("/revoinfo/PTABS", buf2);
#else
	    restore_raw(hdmap[d1], buf2);
#endif
	  }
	  
	} else if (!strcmp("partcopy", buf2)) {
	  // partcopy command
	  unsigned int d1, d2, sect;
#ifdef TEST_PARTONLY 
	  continue;
#endif     
	  if (sscanf(buf, " partcopy (hd%u,%u) %u PATH/%s", 
		     &d1, &d2, &sect, buf2) == 4) {
	    DEBUG(printf("%d,%d,%d,%s\n", d1, d2, sect, buf2));
	    // convert the BIOS hd number to a Linux device	    
	    // and restore the files to the device
	    if (d1 >= 3968 && d2 == -1) {
	      // lvm: no hdmap necessary
	      strncpy(lvm, "/dev/", 5);
	      if (sscanf(buf, " partcopy (hd%*u,%*u) %*u PATH/%*s %s", &lvm[5]) != 1) {
		myprintf("syntax error in conf.txt: %s\n", buf);
		exit(1);
	      }
	      if (vgscan == 0) {
		system("lvm vgscan >/dev/null 2>&1; lvm vgchange -ay >/dev/null 2>&1");
		vgscan = 1;
	      }
	      DEBUG(printf("lvm : %s\n", lvm));
	      restore(lvm, sect, buf2);
	      
	    } else {
#ifdef TEST
	      // restore("/revoinfo/P1", sect, buf2);
#else
	      restore(hdmap[d1], sect, buf2);
#endif	    
	    }
	  }
	} else if (!strcmp("setdefault", buf2)) {
	  strtok(buf, " ");
	  setdefault(strtok(NULL, " "));
	} else if (!strcmp("chainloader", buf2)) {
	  setdefault("0");
	}
      }
    }
    fclose(f);
}


/*
 * load the 'hdmap' file if present
 */
/*
void loadhdmap(void)
{
  FILE *f;
  int i = 0;
  unsigned int d, n;

  for (i = 0; i < 256; i++)
    hdmap[i] = 0xFFFFFFFF;

  f = fopen("/revoinfo/hdmap", "r");
  if (f == NULL) return;

  has_hdmap = 1;
  while (!feof(f)) {
    if (fscanf(f, "%d=%d\n", &d, &n ) == 2) {
      DEBUG (printf("%d %d\n", d, n ));
      hdmap[d] = n;
    }
  }
  fclose(f);
}
*/


/*
 * Build a BIOS number to device map 
 * (should use the 'hdmap' file if present)
 */
void makehdmap(void)
{
  FILE *fp;
  int i = 0;
  unsigned int d, major, minor, sec;
  char line[256], buf[256];

  for (i = 0; i < 256; i++)
    hdmap[i] = NULL;

  d = 0;
  fp = fopen("/proc/partitions", "r");
  if (fp == NULL) return;
  while (!feof(fp)) {
    fgets(line, 255, fp);
    if (sscanf(line, " %u %u %u %s\n", &major, &minor, &sec, buf) == 4) {
      if ((((major == 3) || (major == 22) || (major == 33)
	    || (major == 34)) && !(minor & 0x3F)) || 
	  (((major == 8) || (major == 65) || (major >= 72 && major <= 79) 
	    || (major >= 104 && major <= 111))
	   && !(minor & 0xF))) {
	char *str;

	str = malloc(strlen(buf) + 16);
	strcpy(str, "/dev/");
	strcat(str, buf);
	hdmap[d] = str;
	DEBUG (printf("%d %d %d %s\n", minor, major, d, str ));
	d++;
      }
    }
  }
  fclose(fp);

  return;

}


/* 
 */
int getbytes()
{
  int kb = 0;

  FILE *f = fopen ("/revosave/size.txt", "r");
  if (f == NULL) {
    system("cd /revosave; du -k > /revosave/size.txt");
    f = fopen ("/revosave/size.txt", "r");
  } 
  if (f == NULL) {
    return kb;
  }
  fscanf(f, "%d", &kb);
  fclose(f);
  return kb;
}

/* 
 */
int main(int argc, char *argv[])
{
  /* init */
  BUFFER = malloc(24064);
  Bitmap = malloc(24064 - 2048);
  IN = malloc(INSIZE);

  netinfo();
  commandline();

  if (argc > 1) nonewt = 1;

  // mount nfs dirs
#ifndef TEST
  do {
    sprintf(command,
	    "/bin/autosave.sh \"%s\" \"%s\" \"%s\" %d",
	    servip, servprefix, storagedir, rsize);
    printf("Mounting Storage directory...%s\n", command);
  }
  while (mysystem(command) != 0);
#endif

  // some logging
  system ("rm -f " LOGTXT );
  mysystem1 ("cat /etc/cmdline");
  mysystem1 ("cat /proc/cmdline");
  mysystem1 ("cat /proc/version");
  mysystem1 ("cat /proc/partitions");
  mysystem1 ("cat /proc/bus/pci/devices");
  mysystem1 ("cat /proc/modules");    
  mysystem1 ("cat /var/log/messages");

  // now we can use config files from the nfs server
  makehdmap();

  // debug info
  gethost();
  todo = getbytes();

  if (!nonewt) init_newt(servip, servprefix, storagedir, hostname, todo);
  system("/bin/revosendlog 2");
  system("echo \"\">/revoinfo/progress.txt");
  restoreimage();
  system("/bin/revosendlog 3");
  system("rm /revoinfo/progress.txt");

  mysystem1 ("cat /var/log/messages");

  if (!nonewt) close_newt();
  return 0;
}
