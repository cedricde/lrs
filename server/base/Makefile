#
# $Id$
#

SRCDIR = ./revoboot
DESTDIR = ../dist

TMPBASE = base.tgz
REVOBOOT_FILES = $(shell find $(SRCDIR) -type f)
TODAY = $(shell date '+%Y%m%d')

FILES=`cat ../lbl/Version | awk '{print $$1}'`
LINKS=`cat ../lbl/Version | awk '{print $$2}'`
BASE=../base/revoboot/bin

all:	dist

mini:
	(cd revoboot/bin;tar -czvf ../../bin-miniupdate_$(TODAY).tgz initrd* bzI*)

$(TMPBASE):	$(REVOBOOT_FILES)

dist:	
	# get the last kernel compile
	rm -f $(BASE)/revoboot.pxe*
	rm -f $(BASE)/initrd*
	rm -f $(BASE)/bzImage*
	rm -f $(BASE)/lbl.cdrom*
	(cd ../lbl;rm -f $(LINKS))
	(cd ../lbl;while read f l; do if test $$l; then ln -s $$f $$l; fi; done) <../lbl/Version
	rdev ../lbl/bzImage.initrd /dev/ram0
	(cd ../lbl/; tar -cf - $(FILES) $(LINKS) ) | (cd $(BASE) ; tar -xf -)
	# latest utilities
	./copy
	#rsync -v --exclude .svn /home/weex/ftp/base/winutils/* revoboot/lib/util/winutils/
	rsync -v --exclude .svn ../postinst/templates/* revoboot/images/templates/
	(cd revoboot/imgskel;./symlinks)
	chown nobody revoboot/images/data
	tar cvzf $(TMPBASE) --exclude CVS --exclude .svn $(SRCDIR)
	cp $(TMPBASE)  $(DESTDIR)/base_$(TODAY).tgz
	(cd revoboot;tar -czvf ../$(DESTDIR)/bin-update_$(TODAY).tgz --exclude .svn --exclude BASENUM --exclude CVS bin lib images/data images/templates imgbase)
	rm $(TMPBASE)

clean:
	rm -f $(TMPBASE)
	
.PHONY:	clean all dist
