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
/*
 * Program launched to backup all partitions
 */

/* How it works:
 * - open /proc/partitions
 * - for each entry:
 *   - save the 63 first sectors of the partition
 *   - save the 63 sectors BEFORE the partition if the minor nbr is >=5 && major != 58 && major != 109
 *     (because it contains extended DOS part info)
 *   - save recovery info in 'CONF' (for CDs) and 'conf.txt' (for Grub)
 *   - save data except for major devices (whole devices)
 *   - if can't save: get the pratition type with sfdisk and eventually save the partition as raw data.
 */

char *cvsid = "$Id$";

#define _GNU_SOURCE
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdarg.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>
#include <time.h>
#include <dirent.h>
#include <sys/ioctl.h>
#include <linux/hdreg.h>
#include <linux/fs.h>

#include <sys/socket.h>
#include <netinet/in.h>
#include <net/if.h>
#include <linux/sockios.h>

#include "autosave.h"

#define DEBUG(a)
#define PARTONLY 1
//#define TEST 1

#define LOGTXT "/revosave/log.txt"

unsigned long s_min = 0xFFFFFFFF, s_max = 0;

int dnum;

/* save everything in raw mode */
int revoraw = 0;

unsigned char buf[80];
unsigned char command[120];
unsigned char servip[40] = "";
unsigned char servprefix[80] = "";
unsigned char storagedir[80] = "";
char hostname[32] = "";

/* do we have the bios HD map ? */
int has_hdmap=0;
unsigned int hdmap[65536];
unsigned int exclude[65536];

/* partition info */
struct part {
  char device[256];
  int minor;
  int major;
};

/* LDM's privhead */
typedef struct privhead_s {
  __u64     logical_disk_start;                                             
  __u64     logical_disk_size;                                              
  __u64     config_start;                                                   
  __u64     config_size;                                                    
} privhead;

/* proto */
int gethdbios(unsigned int sect);
int isexcluded(int d, int p);

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
}


/*
 * Check if that disk was formatted with the logical disk manager
 */
int ldm_check(int fd, privhead *p)
{
  int isldm = 0;
  char buffer[1024];
    
  lseek64(fd, 6*512, SEEK_SET);
  read(fd, buffer, 512);


  if (strncmp(buffer, "PRIVHEAD", 8) == 0)
    {
      myprintf("LDM Partitioned disk found.\n");
      p->config_start = swab64(*(__u64 *)(buffer + 0x12B));
      p->config_size = swab64(*(__u64 *)(buffer + 0x133));
      DEBUG(printf("%llx %llx\n", p->config_start, p->config_size));
      if (p->config_size != 2048)
	{
	  myprintf("Strange: LDM DB size != 2048 sectors\n");
	}
      isldm = 1;
    }

  return (isldm);
} 

/*
 * Return a prefix given a disk number
 */
char *dnum2pre(int dnum)
{
  static char result[16];

  if (dnum >= 0xFFF) {
    snprintf(result, 15, "Lvm%02X", dnum & 0xFF);
  } else {
    snprintf(result, 15, "%c", 'P' + (dnum - 128));
  }

  return result;
}

/*
 * Save raw sectors of disk number 'dnum' and using already opened 
 * file descriptor 'fdin'
 * The output file is 'PTABS' if dnum = 0, 'QTABS' if dnum = 1, ...
 */
void save_raw(__u32 start, __u32 end, int fdin, int dnum)
{
  char buffer[1024];
  FILE *fP;
  __u32 s;

  sprintf(buffer, "/revosave/%sTABS", dnum2pre(dnum));
  fP = fopen(buffer, "a");

  printf ("Saving partition info from : %u , to : %u\n", start, end);
  for (s = start; s <= end; s++) 
    {
      
      lseek64(fdin, (__u64)512 * (__off64_t) s, SEEK_SET);
      read(fdin, buffer, 512);
      fwrite(&s, 1, 4, fP);
      fwrite(buffer, 1, 512, fP);
      /* if (magic == -1) {
	 magic = *(int *)buffer;
	 DEBUG(printf("magic: %04x\n", magic));
	 } */
      
    }
  fclose(fP);
}

/* return the next partition */
int get_nextpart(struct part *part)
{
  static FILE *fp = NULL;
  static int try = 1;		/* 1: /proc/partition 2: /dev/mapper */
  unsigned char buffer2[256];
  static DIR *dirh = NULL;
  struct dirent *dirp;

  // try = 2;
  // goto try_lvm;

  if (try == 1) {
    if (fp == NULL) {
      fp = fopen("/proc/partitions", "r");
      if (fp == NULL) {
	perror("/proc/partitions");
	exit(1);
      }
    }
    
    while (1) 
      {
	/* iterate on each line found */
	if (feof(fp)) 
	  {
	    try = 2;
	    break;
	  }
	if (fgets(buffer2, 255, fp) == 0) 
	  {
	    try = 2;
	    break;
	  } 
	if (sscanf(buffer2, "%d %d %*d %s", &part->major, &part->minor, part->device) == 3) 
	  {	
	    if (part->major != 254) { /* ignore device mapper entries */
	      return 1;
	    }
	  } 
      }
  } 

  // try_lvm:
    
  if (try == 2) {
    /* list the contents of /dev/mapper/ */
    if (dirh == NULL) {
      if ((dirh = opendir("/dev/mapper/")) == NULL)
	{
	  return 0;
	}
    }

    while ((dirp = readdir(dirh)) != NULL) 
      {
	char path[256];
	struct stat statbuf;
	
	if (strcmp(".",dirp->d_name) == 0 || strcmp("..",dirp->d_name) == 0 || 
	    strcmp("control",dirp->d_name) == 0)
	  {
	    continue;
	  }    
	
	snprintf(path, 255, "/dev/mapper/%s", dirp->d_name);
	
	if (lstat(path,&statbuf) == -1)                /* see man stat */
	  {
	    continue;
	  }
	
	if (S_ISBLK(statbuf.st_mode)) 
	  {
	    snprintf(part->device, 255, "mapper/%s", dirp->d_name);
	    part->major = major(statbuf.st_rdev);
	    part->minor = minor(statbuf.st_rdev);
	    // myprintf("%s %d\n", path, part->minor );
	    return 1;
	  }	
      } 
  }
  return 0;			/* nothing found */
}

/* main loop */
int save(void)
{
    unsigned char device[512], majorn[256];
    int i=0, s=0, magic, backuped, idx;
    int fi, major, minor, dontsave, fmajor=0;
    FILE *fo;			/* /conf.tmp */
    FILE *fC;			/* /CONF */
    FILE *foerr;		/* log.txt */
    __u32 ttype[32], poff[32];	/* partitions info */
    __u32 tmin[32], tmax[32];
    char command[256], *prefix, destfile[64];
    int isldm = 0, should_backup_lvm = 0, isdm = 0;
    __u32 pi_start=0, pi_end=0; /* partition info offset to save */
    struct hd_geometry geo;
    struct stat st;
    struct part part;
    privhead ph;		/* LDM info */
    char *fslist[] = { "swap", "e2fs", "fat", "ntfs", "xfs", "jfs", "ufs", "lvmreiserfs", NULL};
    char *fs;
    
    /* fixme */
    s_min = 0;

    if (stat("/revosave/CONF", &st) == 0) {
	/* A backup is already here, stop everything ! */
	sprintf(command,
		"/revobin/image_error \"A Backup is already present in the server's directory\nYou may have a problem with getClientResponse on the server!\n\"");
	mysystem(command);
#ifndef TEST
	while(1) sleep(1);
#endif
    }
    fC = fopen("/revosave/CONF", "a");
    fo = fopen("/revosave/conf.tmp", "a");

//  fprintf(fo,"# Comment next line to remove PTABS reconstruction\n");
//  fprintf(fo,"ptabs (hd%d) (nd)PATH/%cTABS\n",dnum-128,'P'+(dnum-128));
    fprintf(fo, "# Partcopy commands...\n");

    /* will be incremented soon */
    dnum = 127;

    backuped = 0;
    /* iterate on each partition found */
    while (get_nextpart(&part)) {
	dontsave = 0;
	isldm = 0;
	magic = -1;

	major = part.major;
	minor = part.minor;

	/* find the major device , REALLY NEEDED ??? */
	/* /dev/hd[a-h]* and /dev/sd[a-z]* supported */
	/* compaq /dev/ida/c[01234567]d0->d15 supported */
	/* compaq /dev/cciss/c[01234567]d0->d15 supported */	
	/* mylex unsupported */
	if ((((major == 3) || (major == 22) || (major == 33)
	      || (major == 34)) && !(minor & 0x3F)) || 
	    (((major == 8) || (major == 65) || (major >= 72 && major <= 79) 
	      || (major >= 104 && major <= 111))
	     && !(minor & 0xF))) {
	    dontsave = 1;
	}
	/* increment the number of parsed lines */
	backuped++;
	/* get part extents */
	sprintf(device, "/dev/%s", part.device);

	/* LVM volumes are saved with a name which begins by 'a' */
	if (major == 254) {
	  dnum = 0x1000+minor; 
	  isdm = 1;
	} else {
	  isdm = 0;
	}
	/* LVM ? Ignore LVM volumes unless it cannot be backuped by image_lvmreiserfs */
	if (isdm && !should_backup_lvm) continue;

	fi = open(device, O_RDONLY | O_LARGEFILE );

	if (fi == -1) {
	    myprintf("ERROR: failed to open %s\n", device);
	    continue;	    
	}

	if (ioctl(fi, HDIO_GETGEO, &geo) && !isdm) {
	  perror(device);
	  continue;
	} else 
	  {
	    s = 0;
	    ioctl(fi, BLKGETSIZE, &s);	/* get size in sectors (at least in 2.5.x) */
	    if (isdm) {
	      poff[0] = 0;
	      geo.start = 0;
	    } else {
	      poff[0] = minor & 0xF;	/* fixme: does not work for IDE */
	    }
	    tmin[0] = geo.start;
	    tmax[0] = geo.start + s - 1;
	    ttype[0] = -1;

	    DEBUG(printf("%s: %ld l:%d\n", part.device, geo.start, s));
	    if (geo.start == 0 && !isdm) {
		DEBUG(printf("major !\n"));
		strcpy(majorn, device);
		dontsave = 1;
	    } else if (!isdm) {
	      /* try now to get part type with sfdisk */
	      sprintf(command, "/sbin/sfdisk --id %s %d", majorn, poff[0]);
	      foerr = popen(command, "r");
	      /* get the last hexadecimal number found */
	      while (!feof(foerr)) { 
	    	fscanf(foerr, "%x" ,&ttype[0]);
		fgetc(foerr);
	      }
	      pclose(foerr);
	    }
	}
	close(fi);

	/* new start of disk */
	if (dontsave) 
	  {
	    dnum = gethdbios(s);
	    DEBUG (printf("BIOSNUM %d\n", dnum));
	    /* open the whole major device to save partitions later */
	    if (fmajor) close(fmajor);
	    fmajor = open(device, O_RDONLY | O_LARGEFILE );

	    /* save recovery info for CDs */
	    fprintf(fC, "D:%d L:%u\n", dnum, s);
	    fprintf(fC, "R\n");

	    /* save recovery info for grub */
	    fprintf(fo,
		    "# Comment next line to remove PTABS reconstruction\n");
	    fprintf(fo, "ptabs (hd%d) (nd)PATH/%sTABS\n", dnum - 128,
		    dnum2pre(dnum));

	    /* check for LDM */
	    isldm = ldm_check(fmajor, &ph);
	    if (isldm) 
	      {
		/* save LDM database sectors */
		save_raw(ph.config_start, ph.config_start + ph.config_size - 1, fmajor, dnum);
		ttype[0] = 0x42;
	      }
	  }

	/* save partition info */
	/* where to start and to stop: */
	if (poff[0] >= 5) {
	  /* maybe an extended dos partition so backup 63 sectors before */
	  if (geo.start <= 63) 
	    pi_start = 0; 
	  else 
	    pi_start = geo.start-63;
	} else {
	    pi_start = geo.start;
	}
	pi_end = geo.start+62;
	if (!isdm) save_raw(pi_start, pi_end, fmajor, dnum);

	if (s <= 63) 
	  {
	    dontsave = 1;
	  }

	/* extended partition ? */
	if ((ttype[0] == 0x05) || (ttype[0] == 0x85) || (ttype[0] == 0x0f) || (ttype[0] == 0xA5)) 
	  {
	    DEBUG(printf("extended !\n"));
	    /* it's an extended partition, don't show an error */
	    /* from left to right: dos, linux, win98 extended, freebsd */
	    dontsave = 1;
	  }

	if (dontsave || isexcluded(dnum-128, poff[i])) 
	  {
	    if (!dontsave) {
		myprintf("excluded %d %d\n", dnum-128, poff[i]);
	    }
	    continue;
	  }

	i = 0;
	prefix = dnum2pre(dnum);
	printf("%s%-2d, S:%u , E:%u , t:%d\n", dnum2pre(dnum) ,
		poff[i], tmin[i], tmax[i], ttype[i]);
	fprintf(fC, "%c%-2d, S:%u , E:%u , t:%d\n", 'P' ,
		poff[i], tmin[i], tmax[i], ttype[i]);
	fflush(fC);

	fprintf(fo, " # (hd%d,%d) %u %u %d\n", (dnum - 128),
		poff[i] - 1, tmin[i], tmax[i], ttype[i]);

	if (isdm) {
	  fprintf(fo, " partcopy (hd%d,%d) %u PATH/%s %s\n",
		  (dnum - 128), poff[i] - 1, tmin[i], dnum2pre(dnum), part.device);
	  snprintf(destfile, 63, "/revosave/%s", dnum2pre(dnum));
	} else {
	  fprintf(fo, " partcopy (hd%d,%d) %u PATH/%s%d\n",
		  (dnum - 128), poff[i] - 1, tmin[i], dnum2pre(dnum), poff[i]);
	  snprintf(destfile, 63, "/revosave/%s%d", dnum2pre(dnum), poff[i]);	  
	}
	fflush(fo);

	/* raw ? */
	if (revoraw) {
	  sprintf(command, "/revobin/image_raw %s ?", device);
	  if (mysystem(command) == 0) 
	    {
	      sprintf(command, "/revobin/image_raw %s %s", device, destfile);
	      mysystem(command);
	      continue;
	    }
	}

	/* all FS */
	idx = 0;
	fs = fslist[idx];
	do  
	  {
	    sprintf(command, "/revobin/image_%s %s ?", fs, device);
	    if (mysystem(command) == 0) 
	      {
		sprintf(command, "/revobin/image_%s %s %s", fs, device, destfile);
		mysystem(command);
		break;
	      }
	    fs = fslist[++idx];
	  } while (fs);
	if (fs) continue;

	/* LVM */
	if (ttype[i] == 0x8e) 
	  {
	    sprintf(command, "/revobin/image_lvm %s ?", device);
	    if (mysystem(command) == 0) {
	      sprintf(command, "/revobin/image_lvm %s %s", device, destfile);
	      mysystem(command);
	      should_backup_lvm = 1;
	      continue;
	    }
	  }

	if (ttype[i] == 0x12)
	  {
	    /* Save as raw: compaq diag */
	    sprintf(command, "/revobin/image_raw %s ?", device);
	    if (mysystem(command) == 0) 
	      {
		sprintf(command, "/revobin/image_raw %s %s", device, destfile);
		mysystem(command);
		continue;
	      }
	  }

	foerr = fopen(LOGTXT, "a");
	fprintf(foerr,
		"\n\nERROR: Unsupported or corrupted FS...(disk %d, part %d, type %x)\n",
		dnum, poff[i], ttype[i]);
	fprintf(fo,
		"# ERROR: Unsupported or corrupted FS...(disk %d, part %d, type %x)\n",
		dnum, poff[i], ttype[i]);
	fclose(foerr);
	/* Show a nice error message */
	sprintf(command,
		"/revobin/image_error \"Unsupported or corrupted file system...\n\n(disk %d, part %d, type %x)\"",
		dnum, poff[i], ttype[i]);
	system(command);
	fatal();
	sleep(180);

    }
 
    fprintf(fC, "E\n");
    fclose(fC);
    fclose(fo);

    if (backuped == 0) {
      /* nothing backuped !!! */
      sprintf(command,
	      "/revobin/image_error \"Nothing was backuped !\nMaybe your disk controller was not recognized...\"");
      mysystem(command);
      fatal();
      sleep(300);
    }
    
    if (fmajor) close(fmajor);

    return 0;
}


unsigned char *find(const char *str, const char *fname)
{
    FILE *f;

    f = fopen(fname, "r");
    if (f == NULL)
	return NULL;
    while (fgets(buf, 80, f)) {
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

    if ((ptr = find("revoraw", "/etc/cmdline"))) {
	revoraw = 1;
    }
}

void saveimage(void)
{
    FILE *fo;
    int boot = 0;
    unsigned char date[80];
    struct tm *t;
    time_t curtime;
    int fh;
    struct ifreq iface;

    curtime = time(NULL);
    t = localtime(&curtime);
    strncpy(date, asctime(t), 70);
    date[strlen(date) - 1] = 0;	/* remove the newline */

    /* get eth0's MAC addr */
    fh=socket(PF_INET,SOCK_DGRAM,IPPROTO_IP);
    strcpy(iface.ifr_name,"eth0");
    ioctl(fh,SIOCGIFHWADDR,&iface);

    /* if.ifr_hwaddr is hardware address 
       printf("Hardware address of eth0 is ");
       for (count = 0; count < 6 ; ++count)
       printf("%02.2x",iface.ifr_hwaddr.sa_data[count] & 0xff );
       printf("\n"); */

    fo = fopen("/revosave/conf.tmp", "w");
    fprintf(fo, "title COPY %s\n", hostname);
    fprintf(fo, "desc (%s)\n", date);
    fclose(fo);

    save();

    fo = fopen("/revosave/conf.tmp", "a");
    if (boot >= 0) {
	fprintf(fo, "# Boot on 1st disk %d\n", boot);
	fprintf(fo, " root (hd0)\n");
	fprintf(fo, " chainloader +1\n");
    }
    fprintf(fo, "\n");
    fclose(fo);
    system("mv -f /revosave/conf.tmp /revosave/conf.txt");
}

/*
 * load the 'hdmap' file if present
 */
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

/*
 * load the 'exclude' file if present
 */
void loadexcludemap(void)
{
  FILE *f;
  int i = 0;
  unsigned int d, n;

  // exclude is a bitmap of excluded partitions => up to 32 partitions per disk
  for (i = 0; i < 256; i++)
    exclude[i] = 0x0;

  f = fopen("/revoinfo/exclude", "r");
  if (f == NULL) return;

  while (!feof(f)) {
    if (fscanf(f, "%d:%d\n", &d, &n ) == 2) {
      if (n == 0) {
	// exclude everything
	exclude[d] = 0xFFFFFFFF;
      } else {
	exclude[d] |= 1<<(n-1);
      }
      DEBUG (printf("%d %x\n", d, exclude[d] ));
    }
  }
  fclose(f);
}

/*
 * Check if a disk is not backuped
 */
int isexcluded(int disk, int part)
{
  if ((exclude[disk] & (1<<(part-1))) != 0) {
    return 1;
  }
  DEBUG(printf("Not excluded\n"));
  return 0;
}

/*
 * Get the HD bios number using the number of sectors as hint
 */
int gethdbios(unsigned int sect)
{
  static int lastnum = -1;
  int i, notfound = 1;

  lastnum++;
  if (!has_hdmap) {
    /* no hdmap, let's increment */
    return (lastnum+128);
  }
  for (i = 0; i<256 ; i++) {
    if ((sect == hdmap[i]) || (sect+1 == hdmap[i])) {
      lastnum = i;
      notfound = 0;
      break;
    }
  }
  if (notfound) {
    printf("BIOS NUMBER not found ! Doing a simple increment\n");    
  }
  /* mark as already used */
  hdmap[i] = 0xFFFFFFFF;

  return (lastnum+128);  
}

int main(int argc, char *argv[])
{
  netinfo();
  commandline();

  // mount nfs dirs
#ifndef TEST
  do {
    sprintf(command,
	    "/bin/autosave.sh \"%s\" \"%s\" \"%s\" %d",
	    servip, servprefix, storagedir, 8192);
    printf("Mounting Storage directory...%s\n", command);
  }
  while (mysystem(command) != 0);
#endif

  // now we can use config files from the nfs server
  loadhdmap();
  loadexcludemap();

  // debug info
  gethost();
  mysystem1("date");
  mysystem1("cat /etc/cmdline");
  mysystem1("cat /proc/cmdline");
  mysystem1("cat /proc/version");
  mysystem1("cat /proc/partitions");
  mysystem1("cat /proc/bus/pci/devices");
  mysystem1("cat /proc/modules");    
  
  system("/bin/revosendlog 4");
  system("echo \"\">/revosave/progress.txt");
  saveimage();
  system("/bin/revosetdefault 0");
  system("/bin/revosendlog 5");

  mysystem1("cat /var/log/messages");    
  return 0;
}
