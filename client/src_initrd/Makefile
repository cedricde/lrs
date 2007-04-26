#
# $Id$
#

#VERSION=2610_6

TREE=./tree
LOOP=/mnt/build
INITRD=initrd
MKDEV=$(shell pwd)/MAKEDEV
IMAGES=image_lvmreiserfs image_raw image_swap image_e2fs image_fat image_ntfs image_xfs image_jfs image_ufs image_lvm
SRCLIN=/usr/src/linux/

AUTOSAVE_DIR=../revimage/autosave
IMAGE_DIR=../revimage
POSTINST_DIR=../../postinst

DEVMAP=$(shell pwd)/devmapper/

all: initrd initrdcd

initrd: Makefile MAKEDEV pump/pump $(IMAGE_DIR)/autorestore/revoboot
	#-umount $(LOOP)
	(cd $(TREE);./symlinks)
	mkdir $(LOOP)
	#dd if=/dev/zero of=$(INITRD) bs=1k count=8192
	#mke2fs -i $$((4096+512)) -m 0 -F $(INITRD)
	#mount $(INITRD) $(LOOP) -o loop
	tar cvf - --exclude .svn -C $(TREE) . | tar xf - -C $(LOOP)
	(cd $(LOOP)/dev; $(MKDEV) console ptyp std hda hdb hdc hdd hde hdf hdg hdh sda sdb sdc sdd sde sdf sdg sdh fd0 cciss.0 cciss.1 ida.0 scd0 scd1 input; mknod -m 600 initctl p; mknod -m 600 log p)
	# get the latest pump
	strip pump/pump
	cp -f pump/pump $(LOOP)/bin
	# cp -f $(IMAGE_DIR)/../atftp-0.7/atftp $(LOOP)/bin
	cp -f lvm2/tools/lvm $(LOOP)/bin
	# sysvinit
	for n in halt init killall5 runlevel shutdown ;do \
	    cp -f ./sysvinit/src/$$n $(LOOP)/sbin || exit 1; \
	done
	# get the latest autorestore/revo*
	for n in autorestore revosendlog revowait revogetname revosetdefault revoinc revoinv ;do \
	    cp -f $(IMAGE_DIR)/autorestore/$$n $(LOOP)/bin || exit 1;\
	done 
	for n in autosave/autosave mount/mount.sh mount/mount-nfs.sh autosave/floppysave ui_newt/uinewt ;do \
	    cp -f $(IMAGE_DIR)/$$n $(LOOP)/bin || exit 1;\
	done 
	cp -f $(IMAGE_DIR)/autorestore/revoboot $(LOOP)/etc/init.d ;\
	for n in bench bench.ping ;do \
	    cp -f $(IMAGE_DIR)/bench/$$n $(LOOP)/bin || exit 1;\
	done 
	if [ -d $(POSTINST_DIR) ] ; then \
	    for n in postmount dopostinst mountwin doinitinst ;do \
		cp -f $(POSTINST_DIR)/client/$$n $(LOOP)/bin ;\
	    done ;\
	fi
	# drivers
	-find $(SRCLIN)/drivers/net $(SRCLIN)/lib  -name "*.ko" -exec cp -av {} $(LOOP)/lib/modules \;
	-find $(SRCLIN)/drivers/pcmcia -name "*.ko" -exec cp -av {} $(LOOP)/lib/modules \;
	# latest imagers
	for i in $(IMAGES); do cp -f $(IMAGE_DIR)/$$i $(LOOP)/revobin/ || exit 1 ;done
	cp -f $(IMAGE_DIR)/liblrs.so.1 $(LOOP)/lib
	# clean
	rm -f $(LOOP)/symlinks
	rm -rvf $(LOOP)/*/CVS/
	(cd $(LOOP); ln -s sbin/init; find . | cpio -o -H newc ) >$(INITRD)
	rm -rf $(LOOP)
	gzip -6c $(INITRD) > $(INITRD).gz

initrdcd:
	mkdir -p $(LOOP)/lib/modules/cd
	for i in ide/ide-cd.ko cdrom/cdrom.ko ../fs/isofs/isofs.ko usb/storage/usb-storage.ko scsi/sr_mod.ko ;do \
	    cp -v $(SRCLIN)/drivers/$$i $(LOOP)/lib/modules/cd ;\
	done
	(cd $(LOOP); find . | cpio -o -H newc ) >$(INITRD)cd
	gzip -f $(INITRD)cd
	rm -rf $(LOOP)

pump/pump: pump/Makefile
	(cd pump; make pump; strip pump)


lvm2:
	(cd $(DEVMAP); ./configure; make)
	-rm -f $(DEVMAP)/lib/ioctl/*.so
	(cd lvm2;\
	export CFLAGS="-I$(DEVMAP)/include -I`pwd`/debian/include/i386" LDFLAGS="-L$(DEVMAP)/lib/ioctl" ;\
	./configure --with-optimisation=-Os --with-pool=none --with-cluster=none --disable-selinux --with-snapshots=none ;make)
	cd lvm2/tools; gcc -o lvm archiver.o toollib.o reporter.o segtypes.o vgscan.o lvm.o dumpconfig.o formats.o vgmknodes.o lvmcmdline.o vgchange.o pvmove.o polldaemon.o -L/home/svn/lbl/src_initrd/devmapper/lib/ioctl -Wl,--export-dynamic -L../lib -L/lib -llvm -ldevmapper -rdynamic
	strip lvm2/tools/lvm

.PHONY: lvm2 initrdcd
