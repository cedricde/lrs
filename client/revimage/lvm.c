/* 
 * $Id$
 *
 */

#define _GNU_SOURCE
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
#include <stdint.h>
#include <sys/vfs.h>

#include "ui_newt.h"

#define FMTT_MAGIC "\040\114\126\115\062\040\170\133\065\101\045\162\060\116\052\076"


extern unsigned long lvm_sect;

/* check if it's and LVM partition */
void lvm_check(char *device, long long *offset)
{
    unsigned long buf[256];
    FILE *fi;

    // check for LVM
    fi = fopen(device, "r");
    if (fi == NULL) {
	debug("Open failed\n");
	exit(1);
    }
    fread(&buf[0], 256*4, 1, fi);

    *offset = 0;
    /* lvm1 checks */
     debug("LVM1 signature check: %08lx\n", buf[0]);
     if (buf[0] == 0x00014d48) 
      {
	debug("LVM1 found\n");

	*offset = buf[9] + buf[10];
	debug("LVM: Real part offset: %16llx\n", *offset);
	
	debug("LVM: VG name : '%32s'\n", (char *)&buf[11+32]);
	debug("LVM: PV Num  : %ld\n", buf[108]);    
	debug("LVM: PE Size : %ld\n", buf[113]/2);
	debug("LVM: PE Total: %ld\n", buf[114]);
	debug("LVM: PE Alloc: %ld\n", buf[115]);
	
	lvm_sect = buf[113]*buf[115];
	debug("LVM: Total sectors: %ld\n", lvm_sect);
	

	if (fseek(fi, buf[9], SEEK_SET) != 0) {
	  debug("Seek error\n");
	  return;
	}
      }
    else
      {
	__u64 off;
	int state = 0;
	int pe_count = 0, extent = 0;

	/* lvm2 */
	if (buf[128] != 0x4542414C || buf[129] != 0x454E4F4C) 
	  {
	    debug("LVM2 LABELONE not found\n");
	    return;
	  }
	debug("LVM2 LABELONE found\n");
	if (buf[134] != 0x324D564C || buf[135] != 0x31303020) 
	  {
	    debug("LVM2 001 not found\n");
	    return;
	  }
	fseek(fi, 0x800, SEEK_SET);
	fread(buf, 128*4, 1, fi);
	if (strncmp((char *)&buf[1], (char *)FMTT_MAGIC, 16))
	  {
	    debug("LVM: FMTT_MAGIC not found\n");
	    return;
	  }
	debug("LVM2: FMTT v%ld\n", buf[5]);
	off = buf[10] + ((__u64)buf[11] << 32);
	debug("LVM2: Meta offset: 0x%llX\n", off);
	off += 0x800;
	fseek(fi, off, SEEK_SET);
	*offset = 0;
	while (1) 
	  {
	    char b[128];

	    fgets(b, 127 ,fi);
	    debug("LVM2: %s", b);
	    switch (state) {
	    case 0:
	      sscanf(b, "extent_size = %d", &extent);
	      if (strstr(b, "physical_volumes")) state = 1;
	      break;
	    case 1:
	      if (sscanf(b, "pe_start = %lld", offset) == 1) state = -1;
	      break;
	    }
	    sscanf(b, "pe_count = %d", &pe_count);
	    if (strstr(b, "}")) break;
	  }
	if (state != -1) 
	  {
	    debug("LVM2 pe_start not found!\n");
	    *offset = 0;
	    return;
	  }
	debug("LVM: Saving %lld sectors\n", *offset);
	*offset *= 512;
	lvm_sect = extent * pe_count;
      }
   

    fclose(fi);

}
