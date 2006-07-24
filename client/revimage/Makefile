#
# $Id$
#

OBJ=compress.o ui_newt.o
LIBOBJ=compress.o ui_newt.o

CFLAGS=-Wall -O2 -DLBLIMAGEVER=\"1.2\" -I./zlib-1.2.1 -I./e2fsprogs-1.22/lib/ -fPIC
LDFLAGS=-s
LIBS= -L./zlib-1.2.1/ -lz -lnewt -L. -llrs
RFSLIBS=-L./reiserfsprogs/lib/ -lcore -lmisc

all: $(OBJ) $(LIBOBJ) liblrs.so.1 image_swap image_lvmreiserfs \
 image_e2fs image_xfs image_jfs image_lvm \
 decompress decompress-test\
 image_error image_raw decompress-bitmap

depend:
	gcc -M $(CFLAGS) *.c >.depend

#image_fat: image_fat.o 
#	cc $(CFLAGS) $(LDFLAGS) -o $@ $^ $(LIBS)

image_swap: image_swap.o 
	cc $(CFLAGS) $(LDFLAGS) -o $@ $^ $(LIBS)

image_raw: image_raw.o
	cc $(CFLAGS) $(LDFLAGS) -o $@ $^ $(LIBS)

#image_ntfs: image_ntfs.o
#	cc $(CFLAGS) $(LDFLAGS) -o $@ $^ $(LIBS)

image_e2fs: image_e2fs.o
	cc $(CFLAGS) $(LDFLAGS) -o $@ $^ $(LIBS) -L./e2fsprogs-1.22/lib -lext2fs -le2p -luuid -lcom_err

image_xfs: image_xfs.o 
	cc $(CFLAGS) $(LDFLAGS) -o $@ $^ $(LIBS) 

image_jfs: image_jfs.o 
	cc $(CFLAGS) $(LDFLAGS) -o $@ $^ $(LIBS) 

image_lvm: image_lvm.o lvm.o 
	cc $(CFLAGS) $(LDFLAGS) -o $@ $^ $(LIBS) 

image_lvmreiserfs: lvm.o image_lvmreiserfs.o
	cc $(CFLAGS) $(LDFLAGS) -o $@ $^ $(LIBS) $(RFSLIBS)

decompress: decompress.o $(OBJ)
	cc $(CFLAGS) $(LDFLAGS) -o $@ $^ -lz -lnewt

decompress-test: decompress-test.o $(OBJ)
	cc $(CFLAGS) $(LDFLAGS) -o $@ $< --static -L./zlib-1.2.1 -lz

decompress-bitmap: decompress-bitmap.o $(OBJ)
	cc $(CFLAGS) $(LDFLAGS) -o $@ $< -L./zlib-1.2.1 -lz

#image_reiserfs: image_reiserfs.o lvm.o 
#	cc $(CFLAGS) -o $@ $(OBJ) $< $(LIBS) $(RFSLIBS)

image_error: image_error.o
	cc $(CFLAGS) -s -o $@ $< $(LIBS) 

image_e2fs.o: image_e2fs.c compress.h compress-loop.h config.h
	cc $(CFLAGS) -o image_e2fs.o -c image_e2fs.c -I./e2fsprogs-1.22/lib

liblrs.so.1: $(OBJ)
	gcc -shared -Wl,-soname,liblrs.so.1 -o liblrs.so.1 $^ -lnewt
	strip $@
	ln -sf $@ liblrs.so

include .depend
