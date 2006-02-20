#
# $Id$
#
# The kernel source should be decompressed in /usr/src, with a 'linux' link
# pointing to the right directory.
#

SRC=/usr/src
HERE=`pwd`

all: kernel

kernel:	
	@echo -e "\n\nCurrent linux is:\n"
	@ls -l /usr/src/linux
	@echo -e "\nContinue ?(y/n)"
	@(read ANS; [ "$$ANS" != "n" ])
# kernel compile
	[ -f $(SRC)/linux/.config ]
	cp -f logo_linux_vga16.ppm $(SRC)/linux/drivers/video/logo/
	(cd $(SRC)/linux/;make all)
# bcm5700 compile
	(cd ./bcm/bcm5700-8.2.18/src; make; cp bcm5700.ko $(SRC)/linux/drivers/net/)
	cp -f $(SRC)/linux/arch/i386/boot/bzImage .
	rdev bzImage /dev/ram0
	# lufs
	(cd lufs;make -C /usr/src/linux SUBDIRS=`pwd` modules)
	cp -f lufs/lufs.ko .

clean: cleanlufs
	(cd $$SRC;make clean)

cleanlufs:
	(cd lufs; rm *.o *.ko; rm .*.cmd)
