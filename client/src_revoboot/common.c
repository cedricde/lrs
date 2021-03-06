/* common.c - miscellaneous shared variables and routines */
/*
 *  GRUB  --  GRand Unified Bootloader
 *  Copyright (C) 1996  Erich Boleyn  <erich@uruk.org>
 *  Copyright (C) 1999, 2000  Free Software Foundation, Inc.
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
#include "pci.h"
#include "builtins_lbs.h"

#ifdef SUPPORT_DISKLESS
# include <etherboot.h>
extern char imgname[32];
#endif

/*
 *  Shared BIOS/boot data.
 */

struct multiboot_info mbi;
unsigned long saved_drive;
unsigned long saved_partition;

unsigned long saved_mem_upper;
/* This saves the maximum size of extended memory (in KB).  */
unsigned long extended_memory;
/* */
int done_inventory = 0;

/*
 *  Error code stuff.
 */

grub_error_t errnum = ERR_NONE;

#ifdef HELP_ON
char *err_list[] =
{
  [ERR_NONE] = 0,
  [ERR_BAD_ARGUMENT] = "Invalid argument",
  [ERR_BAD_FILENAME] =
  "Filename must be either an absolute pathname or blocklist",
  [ERR_BAD_FILETYPE] = "Bad file or directory type",
  [ERR_BAD_GZIP_DATA] = "Bad or corrupt data while decompressing file",
  [ERR_BAD_GZIP_HEADER] = "Bad or incompatible header in compressed file",
  [ERR_BAD_PART_TABLE] = "Partition table invalid or corrupt",
  [ERR_BAD_VERSION] = "Mismatched or corrupt version of stage1/stage2",
  [ERR_BELOW_1MB] = "Loading below 1MB is not supported",
  [ERR_BOOT_COMMAND] = "Kernel must be loaded before booting",
  [ERR_BOOT_FAILURE] = "Unknown boot failure",
  [ERR_BOOT_FEATURES] = "Unsupported Multiboot features requested",
  [ERR_DEV_FORMAT] = "Unrecognized device string",
  [ERR_DEV_VALUES] = "Invalid device requested",
  [ERR_EXEC_FORMAT] = "Invalid or unsupported executable format",
  [ERR_FILELENGTH] =
  "Filesystem compatibility error, cannot read whole file",
  [ERR_FILE_NOT_FOUND] = "File not found",
  [ERR_FSYS_CORRUPT] = "Inconsistent filesystem structure",
  [ERR_FSYS_MOUNT] = "Cannot mount selected partition",
  [ERR_GEOM] = "Selected cylinder exceeds maximum supported by BIOS",
  [ERR_NEED_LX_KERNEL] = "Linux kernel must be loaded before initrd",
  [ERR_NEED_MB_KERNEL] = "Multiboot kernel must be loaded before modules",
  [ERR_NO_DISK] = "Selected disk does not exist",
  [ERR_NO_PART] = "No such partition",
  [ERR_NUMBER_PARSING] = "Error while parsing number",
  [ERR_OUTSIDE_PART] = "Attempt to access block outside partition",
  [ERR_PRIVILEGED] = "Must be authenticated",
  [ERR_READ] = "Disk read error",
  [ERR_SYMLINK_LOOP] = "Too many symbolic links",
  [ERR_UNALIGNED] = "File is not sector aligned",
  [ERR_UNRECOGNIZED] = "Unrecognized command",
  [ERR_WONT_FIT] = "Selected item cannot fit into memory",
  [ERR_WRITE] = "Disk write error",
};
#endif

/* static for BIOS memory map fakery */
static struct AddrRangeDesc fakemap[3] =
{
  {20, 0, 0, MB_ARD_MEMORY},
  {20, 0x100000, 0, MB_ARD_MEMORY},
  {20, 0x1000000, 0, MB_ARD_MEMORY}
};

/* A big problem is that the memory areas aren't guaranteed to be:
   (1) contiguous, (2) sorted in ascending order, or (3) non-overlapping.
   Thus this kludge.  */
static unsigned long
mmap_avail_at (unsigned long bottom)
{
  unsigned long long top;
  unsigned long addr;
  int cont;
  
  top = bottom;
  do
    {
      for (cont = 0, addr = mbi.mmap_addr;
	   addr < mbi.mmap_addr + mbi.mmap_length;
	   addr += *((unsigned long *) addr) + 4)
	{
	  struct AddrRangeDesc *desc = (struct AddrRangeDesc *) addr;
	  
	  if (desc->Type == MB_ARD_MEMORY
	      && desc->BaseAddr <= top
	      && desc->BaseAddr + desc->Length > top)
	    {
	      top = desc->BaseAddr + desc->Length;
	      cont++;
	    }
	}
    }
  while (cont);

  /* For now, GRUB assumes 32bits addresses, so...  */
  if (top > 0xFFFFFFFF)
    top = 0xFFFFFFFF;
  
  return (unsigned long) top - bottom;
}

#ifdef SUPPORT_DISKLESS
/* Set up the diskless environment so that GRUB can get a configuration
   file from a network.  */

#include "zfunc.h"

extern struct arptable_t arptable[];
//extern unsigned char nic_macaddr[];
#define nic_macaddr arptable[ARP_CLIENT].node

static int
setup_diskless_environment (void)
{
  char ip[13];
  char hex[]="0123456789ABCDEF";

  void iphex(unsigned char *ptr)
  { 
	ip[0]=hex[((*ptr)&0xF0)>>4]; ip[1]=hex[(*ptr++)&0x0F];
	ip[2]=hex[((*ptr)&0xF0)>>4]; ip[3]=hex[(*ptr++)&0x0F];
	ip[4]=hex[((*ptr)&0xF0)>>4]; ip[5]=hex[(*ptr++)&0x0F];
	ip[6]=hex[((*ptr)&0xF0)>>4]; ip[7]=hex[(*ptr++)&0x0F];
	ip[8]=0;
  }

  void machex(unsigned char *ptr)
  { 
	ip[ 0]=hex[((*ptr)&0xF0)>>4]; ip[ 1]=hex[(*ptr++)&0x0F];
	ip[ 2]=hex[((*ptr)&0xF0)>>4]; ip[ 3]=hex[(*ptr++)&0x0F];
	ip[ 4]=hex[((*ptr)&0xF0)>>4]; ip[ 5]=hex[(*ptr++)&0x0F];
	ip[ 6]=hex[((*ptr)&0xF0)>>4]; ip[ 7]=hex[(*ptr++)&0x0F];
	ip[ 8]=hex[((*ptr)&0xF0)>>4]; ip[ 9]=hex[(*ptr++)&0x0F];
	ip[10]=hex[((*ptr)&0xF0)>>4]; ip[11]=hex[(*ptr++)&0x0F];
	ip[12]=0;
  }

  /* For now, there is no difference between BOOTP and DHCP in GRUB.  */
  if (! bootp ())
    {
      grub_printf ("BOOTP/DHCP fails.\n");
      return 0;
    }

  /* This will be erased soon, though...  */

  print_network_configuration ();
  
  imgname[0] = '\0';
  grub_printf("Base Dir : %s\n",basedir);
 
  machex((char *)nic_macaddr);
  grub_sprintf(config_file,"%s/cfg/%s",basedir,ip);
  grub_printf("Testing : %s\n",config_file);
  if (new_tftpdir(config_file) < 0)
  {
	iphex((char *)&arptable[ARP_CLIENT].ipaddr);
  	grub_sprintf(config_file,"%s/cfg/%s",basedir,ip);
  	grub_printf("Testing : %s\n",config_file);
  	if (new_tftpdir(config_file) < 0)
	{
  		grub_sprintf(config_file,"%s/cfg/default",basedir);
	}
  }

  printf("Using : %s as configfile\n",config_file);

  zcinit();

  return 1;
}
#endif /* SUPPORT_DISKLESS */

/* This queries for BIOS information.  */
void
init_bios_info (void)
{
  unsigned long cont, memtmp, addr;

  /*
   *  Get information from BIOS on installed RAM.
   */

  mbi.mem_lower = get_memsize (0);
  mbi.mem_upper = get_memsize (1);

  /*
   *  We need to call this somewhere before trying to put data
   *  above 1 MB, since without calling it, address line 20 will be wired
   *  to 0.  Not too desirable.
   */

  gateA20 (1);

  /* Store the size of extended memory in EXTENDED_MEMORY, in order to
     tell it to non-Multiboot OSes.  */
  extended_memory = mbi.mem_upper;
  
  /*
   *  The "mbi.mem_upper" variable only recognizes upper memory in the
   *  first memory region.  If there are multiple memory regions,
   *  the rest are reported to a Multiboot-compliant OS, but otherwise
   *  unused by GRUB.
   */

  addr = get_code_end ();
  mbi.mmap_addr = addr;
  mbi.mmap_length = 0;
  cont = 0;

  do
    {
      cont = get_mmap_entry ((void *) addr, cont);

      /* If the returned buffer's length is zero, quit. */
      if (! *((unsigned long *) addr))
	break;

      mbi.mmap_length += *((unsigned long *) addr) + 4;
      addr += *((unsigned long *) addr) + 4;
    }
  while (cont);

  if (mbi.mmap_length)
    {
      unsigned long long max_addr;
      
      /*
       *  This is to get the lower memory, and upper memory (up to the
       *  first memory hole), into the "mbi.mem_{lower,upper}"
       *  elements.  This is for OS's that don't care about the memory
       *  map, but might care about total RAM available.
       */
      mbi.mem_lower = mmap_avail_at (0) >> 10;
      mbi.mem_upper = mmap_avail_at (0x100000) >> 10;

      /* Find the maximum available address. Ignore any memory holes.  */
      for (max_addr = 0, addr = mbi.mmap_addr;
	   addr < mbi.mmap_addr + mbi.mmap_length;
	   addr += *((unsigned long *) addr) + 4)
	{
	  struct AddrRangeDesc *desc = (struct AddrRangeDesc *) addr;
	  
	  if (desc->Type == MB_ARD_MEMORY
	      && desc->BaseAddr + desc->Length > max_addr)
	    max_addr = desc->BaseAddr + desc->Length;
	}

      extended_memory = (max_addr - 0x100000) >> 10;
    }
  else if ((memtmp = get_eisamemsize ()) != -1)
    {
      cont = memtmp & ~0xFFFF;
      memtmp = memtmp & 0xFFFF;

      if (cont != 0)
	extended_memory = (cont >> 10) + 0x3c00;
      else
	extended_memory = memtmp;
      
      if (!cont || (memtmp == 0x3c00))
	memtmp += (cont >> 10);
      else
	{
	  /* XXX should I do this at all ??? */

	  mbi.mmap_addr = (unsigned long) fakemap;
	  mbi.mmap_length = sizeof (fakemap);
	  fakemap[0].Length = (mbi.mem_lower << 10);
	  fakemap[1].Length = (memtmp << 10);
	  fakemap[2].Length = cont;
	}

      mbi.mem_upper = memtmp;
    }

  saved_mem_upper = mbi.mem_upper;

  /*
   *  Initialize other Multiboot Info flags.
   */

  mbi.flags = MB_INFO_MEMORY | MB_INFO_CMDLINE | MB_INFO_BOOTDEV;

  /* Set boot drive and partition.  */
  saved_drive = boot_drive;
  saved_partition = install_partition;
  current_drive = saved_drive;

#ifdef SUPPORT_DISKLESS
  /* If SUPPORT_DISKLESS is defined, initialize the network here.  */
  if (! setup_diskless_environment ())
    return;
#endif

  /* INFO AT STARTUP to PORT 1001 */
  if (!done_inventory)
  {
	char *buffer; unsigned int i;
	extern unsigned char X86;
	unsigned char *ptr=&X86;
	extern unsigned char *udp_packet_r;
	extern char lbsname[];
	int sz=0, port;

	udp_init();

	/* tell the LBS that we have booted */
	udp_send_lbs("L0", 2);

	/* begin */
	buffer=(char *)PASSWORD_BUF;
	*buffer++=0xAA;
	buffer += grub_sprintf(buffer,"M:%x,U:%x\n",mbi.mem_lower,mbi.mem_upper);
	eth_pci_init(buffer); while (*buffer) buffer++;

	drive_info(buffer);
	while (*buffer) buffer++;

	/* smbios infos */
	if ( smbios_init() )
	    {
	      unsigned char *p1, *p2, *p3, *p4, *p;
	      int i, i1, i2, i3, i4;
	      char hex[]="0123456789ABCDEF";

	      smbios_get_biosinfo(&p1, &p2, &p3);
	      buffer += grub_sprintf(buffer, "S0:%s|%s|%s\n",p1, p2, p3);

	      smbios_get_sysinfo(&p1, &p2, &p3, &p4, &p);
	      buffer += grub_sprintf(buffer, "S1:%s|%s|%s|%s|",p1, p2, p3, p4);

	      /* while (*buffer) buffer++; */
	      for (i = 0; i<16; i++)	/* UUID */
		{
		  *buffer++ = hex[p[i]>>4];
		  *buffer++ = hex[p[i]&15];
		}

	      smbios_get_enclosure(&p1, &p2);
	      buffer += grub_sprintf(buffer, "\nS3:%s|%d\n",p1, *p2 & 0x7F);

	      while (smbios_get_memory(&i1, &i2, &p1, &i3, &i4)) {
		 buffer += grub_sprintf(buffer, "SM:%d:%x:%s:%x:%d\n", i1, i2, p1, i3, i4);
	      }
     	      buffer += grub_sprintf(buffer, "S4:%d\n", smbios_get_numcpu());
	}

	buffer += grub_sprintf(buffer,"C:");
	cpuinfo(); 
	for (i=0;i<24;i++) {
		buffer += grub_sprintf(buffer,"%x,",ptr[i]);
	}
	buffer--;
	buffer += grub_sprintf(buffer,"\nF:%d\n",cpuspeed()); 

	/* send inventory */
	buffer=(char *)PASSWORD_BUF;
	udp_send_withmac((char *)PASSWORD_BUF,strlen(buffer)+1,1001,1001);

	/* I want my name */
	/* Some buggy PXE bioses need a read before sending... (SMC cards) */ 
	udp_get(NULL, &sz, 1001, &port);
	udp_send_lbs("\x1A", 1);
	i = currticks();
	/* wait one sec */
	while (i+15 > currticks()) {
	    sz = 0;
	    udp_get(NULL, &sz, 1001, &port);
	    if (sz) break;
	};

	if (sz) {
		/* grub_strcpy does not work here ?!? */
		for (i = 0; i < 32; i++) {
		    lbsname[i] = udp_packet_r[i];
		}
        	lbsname[MIN(sz,31)] = 0;
	}
	udp_close();
	done_inventory = 1;
  }
  

  current_drive = saved_drive;
  errnum=ERR_NONE;

  /* Start main routine here.  */
  cmain ();
}
