#
# $Id$
#

OBJ=compress.o ui_newt.o

CFLAGS=-Wall -O2 -s -DLBLIMAGEVER=\"1.2\" -I./zlib-1.2.1 -I./e2fsprogs-1.22/lib/ 
LIBS= -L./zlib-1.2.1/ -lz -lnewt 
RFSLIBS=-L./reiserfsprogs/lib/ -lcore -lmisc

all: $(OBJ) image_swap image_reiserfs image_lvmreiserfs \
 image_e2fs image_xfs image_jfs image_lvm\
 decompress decompress-test\
 image_error image_raw decompress-bitmap

depend:
	gcc -M $(CFLAGS) *.c >.depend

image_swap: image_swap.o $(OBJ)
	cc $(CFLAGS) -o image_swap $(OBJ) image_swap.o $(LIBS)

image_raw: image_raw.o $(OBJ)
	cc $(CFLAGS) -o image_raw $(OBJ) image_raw.o $(LIBS)

image_e2fs: image_e2fs.o $(OBJ)
	cc $(CFLAGS) -o image_e2fs $(OBJ) image_e2fs.o $(LIBS) -L./e2fsprogs-1.22/lib -lext2fs -le2p -luuid -lcom_err

image_xfs: image_xfs.o $(OBJ)
	cc $(CFLAGS) -o $@ $^ $(LIBS) 

image_jfs: image_jfs.o $(OBJ)
	cc $(CFLAGS) -o $@ $^ $(LIBS) 

image_lvm: image_lvm.o lvm.o $(OBJ)
	cc $(CFLAGS) -o $@ $^ $(LIBS) 

decompress: decompress.o $(OBJ)
	cc $(CFLAGS) -o $@ $<  -lz

decompress-test: decompress-test.o $(OBJ)
	cc $(CFLAGS) -o $@ $< --static -L./zlib-1.2.1 -lz

decompress-bitmap: decompress-bitmap.o $(OBJ)
	cc $(CFLAGS) -o $@ $< -L./zlib-1.2.1 -lz

image_reiserfs: image_reiserfs.o lvm.o $(OBJ)
	cc $(CFLAGS) -o $@ $(OBJ) $< $(LIBS) $(RFSLIBS)

image_lvmreiserfs: lvm.o image_lvmreiserfs.o $(OBJ)
	cc $(CFLAGS) -o $@ $^ $(LIBS) $(RFSLIBS)

image_error: image_error.o
	cc $(CFLAGS) -s -o $@ $< $(LIBS) 

image_e2fs.o: image_e2fs.c compress.h compress-loop.h config.h
	cc $(CFLAGS) -o image_e2fs.o -c image_e2fs.c -I./e2fsprogs-1.22/lib


include .depend
