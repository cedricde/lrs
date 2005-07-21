#
# $Id$
#

VER=$(shell grep VERSION config.h|tr -dc [0-9])

OBJ=asm.o bios.o boot.o pci.o \
    char_io.o builtins.o \
    common.o stage2.o \
    cmdline.o disk_io.o graphics.o console.o \
    fsys_fat.o fsys_ext2fs.o builtins_lbs.o 

OBJNET= pxe.o udp.o 

OBJZLIB=adler32.o inflate.o infblock.o infcodes.o inftrees.o inffast.o infutil.o zfunc.o

DEFINES = -DFRKBD -DNO_DECOMPRESSION -DSUPPORT_NETBOOT -DSUPPORT_DISKLESS -DFSYS_TFTP -DFSYS_EXT2FS -DFSYS_FAT -DNO_INT13_FALLBACK -DSUPPORT_GRAPHICS=1
#-DDEBUG

HELP=-DHELP_ON
#HELP=

ARCH=pentium
ARCH=i386

CFLAGS=-I. -Os -Wall $(HELP) $(DEFINES) -nostdinc -malign-jumps=1 \
-malign-loops=1 -malign-functions=1 -mcpu=$(ARCH) -march=$(ARCH) 

###################################

CC=gcc-3.0
#CC=gcc

###################################

CFLAGSZLIB=-I. -DMAX_WBITS=14 -DMAX_MEM_LEVEL=7 -DMY_ZCALLOC -DNO_ERRNO_H -O9 -mcpu=$(ARCH) -march=$(ARCH)

revoboot.pxe:	$(OBJ) $(OBJZLIB) $(OBJNET) adjust_length
	$(CC) -o revoboot.pxe.exec -nostdlib -Wl,-N -Wl,-Ttext -Wl,7C00 $(OBJ) $(OBJZLIB) $(OBJNET)
	objcopy -O binary revoboot.pxe.exec revoboot.pxe
	./adjust_length
	cp revoboot.pxe revoboot.pxe.$(VER)

adjust_length: adjust_length.c
	$(CC) -o $@ $^

rsync:
	        rsync -e ssh -zrlpv --delete * jjm@172.20.0.123:/tftpboot/revo.pxe/src/

clean:
	rm -r -f $(OBJ) $(OBJZLIB) $(OBJNET) revoboot.pxe revoboot.pxe.exec

char_io.c: config.h
char_io.o: config.h
zfunc.c: zfunc.h
adler32.c: zlib.h
deflate.c: zlib.h deflate.h
trees.c: zlib.h trees.h
zutil.c: zlib.h zutil.h
builtins.c: builtins_lbs.h

adler32.o:
	$(CC) $(CFLAGSZLIB) -c -o $@ $*.c

inflate.o:
	$(CC) $(CFLAGSZLIB) -c -o $@ $*.c

inftrees.o:
	$(CC) $(CFLAGSZLIB) -c -o $@ $*.c

infutil.o:
	$(CC) $(CFLAGSZLIB) -c -o $@ $*.c

infblock.o:
	$(CC) $(CFLAGSZLIB) -c -o $@ $*.c

infcodes.o:
	$(CC) $(CFLAGSZLIB) -c -o $@ $*.c

inffast.o:
	$(CC) $(CFLAGSZLIB) -c -o $@ $*.c

asm.o: asm.S
	$(CC) -c -I. -O9 $(DEFINES) -Wall -fno-builtin -fnostdinc -o asm.o asm.S

