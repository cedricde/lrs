/*
 * $Id$
 */

#include "config.h"

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

//#include <linux/lvm.h>

#include "compress.h"
#include "ui_newt.h"
#include "lvm.h"

unsigned long info1, info2;
unsigned long lvm_sect;

void allocated_sectors(PARAMS * p)
{
    unsigned long i;
    unsigned long bitmap_lg;
    int off = 0;

    void setbit(unsigned char *base, unsigned long bit) {
	unsigned char mask[8] =
	    { 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80 };

	base[bit >> 3] |= mask[bit & 7];
    }

    off = p->nb_sect;

    p->bitmap = (unsigned char *) calloc(bitmap_lg = (off + 7) / 8, 1);
    p->bitmaplg = bitmap_lg;

    // backup LVM: everything
    for (i = 0; i < off; i++)
	setbit(p->bitmap, i);

    info1 = off;
    info2 = off;
}

/* main */
int main(int argc, char *argv[])
{
    PARAMS params;
    long long offset;
    int fd;

    if (argc != 3) {
	fprintf(stderr,
		"Usage : image_lvm [device] [image prefix name]\n");
	exit(1);
    }
    // check for LVM
    lvm_check(argv[1], &offset);
    if (offset == 0) exit(1);

    params.nb_sect = offset/512;
    allocated_sectors(&params);

    if (argv[2][0] == '?')
	exit(0);

    // Compress now

    init_newt(argv[1], argv[2], info1, info2, argv[0]);
    fd = open(argv[1], O_RDONLY);

    compress_volume(fd, argv[2], &params, "LVM");
    close(fd);
    stats();
    close_newt();

    return 0;
}
