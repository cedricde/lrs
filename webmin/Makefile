# 

DISTDIR = ../server/dist

all:	lbs.wbm lbs-cd.wbm lbs-inventory.wbm lbs-vnc.wbm \
	backuppc.wbm lbs_common.wbm lrs-theme.wbm

dist:   all
	(for i in lbs lbs-cd lbs-inventory lbs-vnc backuppc lbs_common lrs-theme ;do \
	    ver="`head -1 $$i/debian/changelog|cut -f 2 -d ' '|tr -d \(\)`" ;\
	    cp -av $$i.wbm $DISTDIR/webmin/$$i-$$ver.wbm ;\
	done)
	./copydeb2dist

lbs.wbm: $(wildcard lbs/**)
	./mkmodule lbs lbs

lbs-cd.wbm: $(wildcard lbs-cd/**)
	./mkmodule lbs-cd lbs-cd

backuppc.wbm: $(wildcard backuppc/**)
	./mkmodule backuppc backuppc

lbs-inventory.wbm: $(wildcard lbs-inventory/**)
	find ./lbs-inventory/reception_agent/ -type d | xargs chmod 777
	chmod 777 ./lbs-inventory/reception_agent/
	./mkmodule lbs-inventory lbs-inventory

lbs-vnc.wbm: $(wildcard lbs-vnc/**)
	./mkmodule lbs-vnc lbs-vnc

lbs_common.wbm: $(wildcard lbs_common/**)
	./mkmodule lbs_common lbs_common

lrs-theme.wbm: $(wildcard lrs-theme/**)
	./mkmodule lrs-theme lrs-theme

clean:
	cd $(DOCDIR) && $(MAKE) clean
	rm -f ./*.wbm

.PHONY:	clean doc module dist all
