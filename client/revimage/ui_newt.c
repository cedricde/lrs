/*
 * $Id$
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

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <signal.h>
#include <newt.h>
#include <time.h>
#include <sys/ioctl.h>
#include <linux/fs.h>
#include <sys/types.h>
#include <unistd.h>
#include <fcntl.h>	      

#include "ui_newt.h"

void suspend(void * d) {
    newtSuspend();
    raise(SIGTSTP);
    newtResume();
}


newtComponent sc1, sc2, f;
newtComponent t, i1,i2,l1,l2,l3,l4,t1 ;
newtComponent time1,time2,bitrate ;

time_t start,now;
int g_old_curr, g_old_nb, g_partnum;

unsigned long olddiff,bps;
unsigned long long olddone;
extern unsigned long long done,todo;

void init_newt(unsigned char *device,
	      unsigned char *savedir,
	      unsigned long tot_sec,
	      unsigned long used_sec,
	      char *argv0)
{
    char name[256];

    newtInit();
    newtCls();
 
    newtSetSuspendCallback(suspend, NULL);
 
    newtDrawRootText(0, 0, "Linbox Rescue Server");
 
    sprintf(name, "LBLImage v%s %s", LBLIMAGEVER, rindex(argv0, '_'));
    newtOpenWindow(2, 2, 72, 20, name);
 
    f = newtForm(NULL, NULL, 0);

    t1=newtTextbox(1,1,70,5, NEWT_FLAG_WRAP);

    sprintf(name, " %s --> %s ", device, savedir);
    l1=newtLabel(3,20,name);

    l3=newtLabel(37,12,"%");
    sc1=newtScale(13,11,54,100);
    newtScaleSet(sc1,0);
    l4=newtLabel(3,11,"Percent : ");
    //sc2=newtScale(13,12,54,100);
    //newtScaleSet(sc2,0);

    i1=newtTextbox(3,7,50,2,0);
    sprintf (name, "- Total sectors : %ld = %d MiB\n", tot_sec, (int)(tot_sec/2048));
    debug(name);
    newtTextboxSetText(i1, name);
    sprintf (name, "- Used sectors  : %ld = %d MiB (%3.2f%%)\n", used_sec, (int)(used_sec/2048),
             100.0 * (float) used_sec / tot_sec);
    debug(name);
    i2=newtTextbox(3,8,50,2,0);
    newtTextboxSetText(i2,name);

    time1=newtLabel(3,15,"Elapsed time   : ..H..M..");
    time2=newtLabel(3,16,"Remaining time : ..H..M..");
    bitrate=newtLabel(3,17,"Bitrate        : ...... KBps");


    newtFormAddComponents(f, sc1, i1, i2, l1, l3,l4,time1,time2,bitrate,t1,NULL);

    read_update_head();
    update_part(device);

    newtRefresh();
    newtDrawForm(f);

    start=time(NULL);
    olddiff=0;
    olddone=0;
    bps=0;

    //sscanf(info2+18,"%lld",&todo);
    todo = used_sec * (unsigned long long)512;
    done = 0;
    
}

void close_newt(void)
{
    newtFormDestroy(f);
    newtFinished();
}

void stats(void)
{
    unsigned long diff;
    
    now=time(NULL); 
    diff=(unsigned long)difftime(now,start);    
    fprintf(stderr, "- saved in %ld seconds\n", diff);
}

/* update the bitrate, times */
void update_misc(void)
{
    char buf[80];
    unsigned long diff,remain;
    int h,m,s;

    now=time(NULL); diff=(unsigned long)difftime(now,start);
    if (diff==olddiff) return;

    h=diff/3600;
    m=(diff/60)%60;
    s=diff%60;
    sprintf(buf,"Elapsed time   : %02dh%02dm%02d",h,m,s);
    newtLabelSetText(time1,buf);

    bps=((9*bps)/10)+(done-olddone)/(10*(diff-olddiff));

    sprintf(buf,"Bitrate        : %ld KBps",bps/1024);
    newtLabelSetText(bitrate,buf);

    if (bps>0) remain=(todo-done)/bps;
          else remain=99*60*60+59*60+59;
    if (remain < 0) remain = 0;
    h=remain/3600;
    m=(remain/60)%60;
    s=remain%60;
    sprintf(buf,"Remaining time : %02dh%02dm%02d",h,m,s);
    newtLabelSetText(time2,buf);

    olddone=done;
    olddiff=diff;
}

/* update when a new block is written */
void update_block(int current, int nb)
{
  int per = (100*current)/nb;

  g_old_curr=current;
  g_old_nb=nb;
    
  newtScaleSet(sc1, per);
    
  update_file(per);
  update_misc();

  newtRefresh();
}

/* update  */
void update_progress(int percent)
{
    char buf[80];
    float p = (100.0 * g_old_curr + percent) / g_old_nb;
    if (p > 100) p = 100;

    newtScaleSet(sc1, p);

    sprintf(buf,"%3.2f%%", p);    
    newtLabelSetText(l3,buf);
    update_misc();
    newtRefresh();
}

/* update the partition number */
void update_part(char *dev)
{
  struct stat st;

  if (stat(dev, &st) == 0) {
    g_partnum = (minor(st.st_rdev) & 15)-1;
  } else {
    g_partnum = -1;
  }
}

/* write the progress to a file */
void update_file(int perc)
{
  int f;
  char *path = "/revosave/progress.txt";
  /* only update if the file exists */
  
  if ((f = open(path, O_TRUNC|O_WRONLY)) != -1)
    {
      char buf[256];

      snprintf(buf, 255, "%d: %d%%", g_partnum, perc);
      write(f, buf, strlen(buf));
      close(f);
    }
}

/* show the backup/restore message */
void update_head(char *msg)
{
    newtTextboxSetText(t1, msg);
    newtRefresh();
}

void read_update_head(void)
{
    char *path = "/etc/warning.txt";
    char msg[512];
    int f;
    
    msg[0] = 0;
    if ((f = open(path, O_RDONLY)) != -1) {
	int sz = read(f, msg, 511);
	close(f);
	
	msg[sz] = 0;
	update_head(msg);
    }
}

/* fatal write error */
void ui_write_error(void)
{
    newtComponent myForm, l;

    newtCenteredWindow(60, 3, "Server Write Error");
    
    myForm = newtForm(NULL, NULL, 0);
    l = newtLabel(1, 1, "Write error ! Server's disk might be full.");
    fprintf(stderr, "ERROR: Write error ! Server's disk might be full.\n");

    newtFormAddComponents(myForm, l, NULL);
    newtDrawForm(myForm);
    newtRefresh();
    fatal();
}

/* fatal read error */
void ui_read_error(char *s, int l, int err, int fd)
{
    char tmp[256];
    int bs=0;
    off64_t offset;
    newtComponent myForm, t1;

    /* get device block size */
    ioctl(fd, BLKBSZGET, &bs);
    /* get current offset */
    offset = lseek64(fd, 0, SEEK_CUR);

    newtCenteredWindow(60, 4, "HD Read Error");
    
    myForm = newtForm(NULL, NULL, 0);
    t1 = newtTextbox(1, 0, 55, 4, 0);
    
    snprintf(tmp, 255, "Hard Disk Read Error ! Bad hard disk or filesystem !\n"
	"errno %d, file %s, line %d \n"
	"bs=%d offset=%08lx%08lx ", err, s, l, bs, (long)((long long)offset>>32), (long)offset);
    fprintf(stderr, "ERROR: %s\n", tmp);

    newtTextboxSetText(t1, tmp);
    newtFormAddComponents(myForm, t1, NULL);
    newtDrawForm(myForm);
    newtRefresh();

    /* fatal error : wait forever */
    fatal();
    getchar();
    //while (1) sleep(1);
}

/* Fatal error, notify the server about it */
void fatal(void)
{
  system("/bin/revosendlog 8");
}
