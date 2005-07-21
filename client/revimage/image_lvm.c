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

typedef struct p {
    unsigned char *bitmap;
    unsigned long bitmap_lg;
    unsigned long nb_sect;
    unsigned long blocks;
    unsigned long long offset;	/* offset to real FS in bytes (LVM overhead) */
} PARAMS;

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

    off = p->offset / 512;

    p->bitmap = (unsigned char *) calloc(bitmap_lg = (off + 7) / 8, 1);
    p->bitmap_lg = bitmap_lg;

    // backup LVM: everything
    for (i = 0; i < off; i++)
	setbit(p->bitmap, i);

    info1 = off;
    info2 = off;

    p->nb_sect = off;

}

void compress_vol(int fi, unsigned char *nameprefix, PARAMS * p)
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

    sprintf(firststring, "SECTORS=%ld|BLOCKS=%d|LVM|", p->nb_sect, nb);

    sprintf(filename, "%sidx", nameprefix);
    index = fopen(filename, "wt");

#include "compress-loop.h"

    fclose(index);
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

    params.offset = offset;
    allocated_sectors(&params);

    if (argv[2][0] == '?')
	exit(0);

    // Compress now
    //

    init_newt(argv[1], argv[2], info1, info2, argv[0]);
    fd = open(argv[1], O_RDONLY);
    compress_vol(fd, argv[2], &params);
    close(fd);
    stats();
    close_newt();

    return 0;
}
