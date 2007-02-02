#
# $Id$
#

SRCDIR = ./revoboot
DESTDIR = $(shell pwd)/../dist
LRSCD = /tmp/lrscd
SHELL = /bin/bash
BUILD = $(shell cat BUILD)
BUILDRB = $(shell grep VERSION ../../client/src_revoboot/config.h|tr -dc [0-9])
RELEASE = /home/weex/lrsorg/

TMPBASE = base.tgz
REVOBOOT_FILES = $(shell find $(SRCDIR) -type f)
TODAY = $(shell date '+%Y%m%d')

BASE=../base/revoboot/bin

all:	dist

release: dist deb
	cp -f $(DESTDIR)/base-update_$(TODAY).tgz $(RELEASE)/bin
	cp -f $(DESTDIR)/base_$(TODAY).tgz $(RELEASE)/bin
	cp -f $(DESTDIR)/lbs_$(TODAY)*i386.deb $(RELEASE)/bin

mini: update_build
	(cd revoboot/bin;tar -czvf ../../bin-miniupdate_$(TODAY).tgz initrd* bzI*)

$(TMPBASE):	$(REVOBOOT_FILES)

update_build:
	rm -f $(BASE)/revoboot.pxe*
	rm -f $(BASE)/initrd*
	rm -f $(BASE)/bzImage*
	rm -f $(BASE)/lbl.cdrom*
	# get the last kernel compile
	for i in ../../client/src_kernel/bzImage ../../client/src_initrd/initrd.gz ;do \
	    [ ! -f $$i.$(BUILD) ] && cp $$i $$i.$(BUILD); \
	    cp -f $$i.$(BUILD) $(BASE); \
	done
	cp -f ../../client/src_revoboot/revoboot.pxe.$(BUILDRB) $(BASE)
	cp -f ../../client/src_initrd/initrdcd.gz $(BASE)
	(cd $(BASE);\
	ln -sf bzImage.$(BUILD) bzImage.initrd;\
	ln -sf initrd.gz.$(BUILD) initrd.gz;\
	ln -sf revoboot.pxe.$(BUILDRB) revoboot.pxe)
	rdev $(BASE)/bzImage.initrd /dev/ram0

dist: update_build
	# latest utilities
	./copy
	#rsync -v --exclude .svn /home/weex/ftp/base/winutils/* revoboot/lib/util/winutils/
	#rsync -v --exclude .svn ../postinst/templates/* revoboot/images/templates/
	(cd revoboot/imgskel;./symlinks)
	chown nobody revoboot/images/data
	tar cvzf $(TMPBASE) --exclude ./revoboot/debian --exclude CVS --exclude .svn $(SRCDIR)
	cp $(TMPBASE)  $(DESTDIR)/base_$(TODAY).tgz
	(cd revoboot;tar -czvf $(DESTDIR)/base-update_$(TODAY).tgz --exclude .svn --exclude BASENUM --exclude CVS bin lib images/data images/templates imgbase)
	rm $(TMPBASE)

deb:
	sed 1s/[0-9]*.1gpl/$(TODAY).1gpl/ < $(SRCDIR)/debian/changelog > $(SRCDIR)/debian/changelog.new
	mv -f $(SRCDIR)/debian/changelog.new $(SRCDIR)/debian/changelog
	(cd $(SRCDIR); dpkg-buildpackage -tc)
	mv lbs_$(TODAY)* $(DESTDIR)

clean:
	rm -f $(TMPBASE)
	
.PHONY:	clean all dist
