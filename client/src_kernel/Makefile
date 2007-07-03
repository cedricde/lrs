#
# $Id$
#
# The kernel source should be decompressed in /usr/src, with a 'linux' link
# pointing to the right directory.
#

SRC=/usr/src
HERE=`pwd`
CC=gcc-3.3

all: kernel

kernel:	
	@echo -e "\n\nCurrent linux is:\n"
	@ls -l /usr/src/linux
	@echo -e "\nContinue ?(y/n)"
	@(read ANS; [ "$$ANS" != "n" ])
# kernel compile
	[ -f $(SRC)/linux/.config ]
	cp -f logo_linux_vga16.ppm $(SRC)/linux/drivers/video/logo/
	(cd $(SRC)/linux/;make all CC=$(CC))
# bcm5700 compile
#	(cd 3rd_party/bcm/bcm5700-8.2.18/src; make; cp bcm5700.ko $(SRC)/linux/drivers/net/)
# copy the kernel
	cp -f $(SRC)/linux/arch/i386/boot/bzImage .
	rdev bzImage /dev/ram0

clean: cleanlufs
	(cd $$SRC;make clean)

cleanlufs:
	(cd lufs; rm *.o *.ko; rm .*.cmd)
