#
# $Id$
#

SRCDIR = ./revoboot
DESTDIR = ../dist
LBLDIR = ../dist

TMPBASE = base.tgz
REVOBOOT_FILES = $(shell find $(SRCDIR) -type f)
TODAY = $(shell date '+%Y%m%d')

VERSION=../dist/Version

FILES=`cat $(VERSION) | awk '{print $$1}'`
LINKS=`cat $(VERSION) | awk '{print $$2}'`
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
	(cd $(LBLDIR);rm -f $(LINKS))
	(cd $(LBLDIR);while read f l; do if test $$l; then ln -s $$f $$l; fi; done) < $(VERSION)
	rdev $(LBLDIR)/bzImage.initrd /dev/ram0
	(cd $(LBLDIR)/; tar -cf - $(FILES) $(LINKS) ) | (cd $(BASE) ; tar -xf -)
	# latest utilities
	./copy
	#rsync -v --exclude .svn /home/weex/ftp/base/winutils/* revoboot/lib/util/winutils/
	#rsync -v --exclude .svn ../postinst/templates/* revoboot/images/templates/
	(cd revoboot/imgskel;./symlinks)
	chown nobody revoboot/images/data
	tar cvzf $(TMPBASE) --exclude CVS --exclude .svn $(SRCDIR)
	cp $(TMPBASE)  $(DESTDIR)/base_$(TODAY).tgz
	(cd revoboot;tar -czvf ../$(DESTDIR)/bin-update_$(TODAY).tgz --exclude .svn --exclude BASENUM --exclude CVS bin lib images/data images/templates imgbase)
	rm $(TMPBASE)

deb:
	sed 1s/[0-9]*.1gpl/$(TODAY).1gpl/ < $(SRCDIR)/debian/changelog > $(SRCDIR)/debian/changelog.new
	mv -f $(SRCDIR)/debian/changelog.new $(SRCDIR)/debian/changelog
	(cd $(SRCDIR); dpkg-buildpackage -tc)
	mv lbs_$(TODAY)* $(DESTDIR)

clean:
	rm -f $(TMPBASE)
	
.PHONY:	clean all dist
