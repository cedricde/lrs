#
# $Id$
#

VERSION=2610_5

TREE=./tree
LOOP=/mnt/loop
INITRD=initrd.$(VERSION)
MKDEV=$(shell pwd)/MAKEDEV
IMAGES=image_error image_lvmreiserfs image_raw image_swap image_e2fs image_fat image_ntfs image_reiserfs image_xfs image_jfs image_ufs
SRCLIN=/usr/src/linux/

AUTOSAVE_DIR=../../revimage/revimage/autosave
IMAGE_DIR=../../revimage/revimage
POSTINST_DIR=../../postinst

all: initrd

initrd: Makefile MAKEDEV pump/pump
	-umount $(LOOP)
	(cd $(TREE);./symlinks)
	dd if=/dev/zero of=$(INITRD) bs=1k count=8192
	mke2fs -i 4096 -F $(INITRD)
	mount $(INITRD) $(LOOP) -o loop
	tar cvf - --exclude .svn -C $(TREE) . | tar xf - -C $(LOOP)
	(cd $(LOOP)/dev; $(MKDEV) console ptyp std hda hdb hdc hdd hde hdf hdg hdh sda sdb sdc sdd fd0 cciss.0 cciss.1 ida.0 ida.1; mknod -m 600 initctl p; mknod -m 600 log p)
	# get the latest pump
	strip pump/pump
	cp -f pump/pump $(LOOP)/bin
	cp -f $(IMAGE_DIR)/../atftp-0.7/atftp $(LOOP)/bin
	# get the latest autosave/autorestore
	for n in autorestore revorestore revosendlog revowait revogetname revosetdefault ;do \
	    cp -f $(IMAGE_DIR)/autorestore/$$n $(LOOP)/bin ;\
	done 
	for n in bench bench.ping ;do \
	    cp -f $(IMAGE_DIR)/bench/$$n $(LOOP)/bin ;\
	done 
	cp -f $(AUTOSAVE_DIR)/autosave $(LOOP)/bin
	cp -f $(AUTOSAVE_DIR)/autosave.sh $(LOOP)/bin
	cp -f $(AUTOSAVE_DIR)/floppysave $(LOOP)/bin
	if [ -d $(POSTINST_DIR) ] ; then \
	    for n in postmount dopostinst mountwin doinitinst ;do \
		cp -f $(POSTINST_DIR)/client/$$n $(LOOP)/bin ;\
	    done ;\
	fi
	# drivers
	-find $(SRCLIN)/drivers/net $(SRCLIN)/lib  -name "*.ko" -exec cp -av {} $(LOOP)/lib/modules \;
	# latest imagers
	for i in $(IMAGES); do cp -f $(IMAGE_DIR)/$$i $(LOOP)/revobin/ ;done
	# clean
	rm -f $(LOOP)/symlinks
	rm -rvf $(LOOP)/*/CVS/
	umount $(LOOP)
	gzip -6c $(INITRD) > $(INITRD).gz

pump/pump: pump/Makefile
	-ln -sf pump-0.8.11 pump
	(cd pump; make; strip pump)
