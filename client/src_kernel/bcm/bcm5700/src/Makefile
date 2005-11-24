#!/usr/bin/make
# Makefile for building Linux Broadcom Gigabit ethernet driver as a module.
# $id$

# PREFIX may be set by the RPM build to set the effective root.
PREFIX=
ifeq ($(shell ls /lib/modules/$(shell uname -r)/build > /dev/null 2>&1 && echo build),)
  ifeq ($(shell ls /usr/src/linux > /dev/null 2>&1 && echo linux),)
    LINUX=
  else
    LINUX=/usr/src/linux
  endif
else
  LINUX=/lib/modules/$(shell uname -r)/build
endif

LINUX=/usr/src/linux


# check if 2.4 kernel or 2.5+ kernel
BCM_KVER:=$(shell uname -r | cut -c1-3 | sed 's/2\.[56]/2\.6/')
BCM_KVER=2.6

ifeq ($(BCM_KVER), 2.6)
# Makefile for 2.5+ kernel

BCM_DRV = bcm5700.ko

ifneq ($(KERNELRELEASE),)

obj-m += bcm5700.o

bcm5700-objs    := b57um.o b57proc.o tigon3.o autoneg.o 5701rls.o tcp_seg.o b57diag.o

EXTRA_CFLAGS = -DDBG=0 -DT3_JUMBO_RCV_RCB_ENTRY_COUNT=256 -DNICE_SUPPORT -DPCIX_TARGET_WORKAROUND=1 -DINCLUDE_TBI_SUPPORT -DINCLUDE_5701_AX_FIX=1

else

default:
	make -C $(LINUX) SUBDIRS=$(shell pwd) modules

endif

else # ifeq ($(BCM_KVER),2.6)
# Makefile for 2.4 kernel

BCM_DRV = bcm5700.o

ifeq ($(LINUX),)
  $(error Linux kernel source tree not found)
endif

ifeq ($(shell which kgcc > /dev/null 2>&1 && echo kgcc),)
  CC = gcc
else
  ifneq ($(findstring gcc version egcs-2.91.66, $(shell cat /proc/version 2>&1)),)
    CC = kgcc
  else
    CC = gcc
  endif
endif

LD = ld
CFLAGS=-DMODULE -D__KERNEL__ -DDBG=0 -DT3_JUMBO_RCV_RCB_ENTRY_COUNT=256 -DNICE_SUPPORT -DPCIX_TARGET_WORKAROUND=1 -DINCLUDE_TBI_SUPPORT -DINCLUDE_5701_AX_FIX=1 -Wall -Wstrict-prototypes -I$(LINUX)/include -I/usr/src/linux-2.6.10/include/asm-i386/mach-default/

ifeq ($(wildcard ~/rpmdir),)
  rpmdir = /usr/src/redhat
else
  rpmdir = $(wildcard ~/rpmdir)
endif

ARCH:=$(shell uname -m)

ifeq ($(ARCH),x86_64)
  CFLAGS+=-mno-red-zone -mcmodel=kernel -pipe -finline-limit=2000
endif

ifeq ($(ARCH),ia64)
  CFLAGS+=-pipe -ffixed-r13 -mfixed-range=f10-f15,f32-f127 -falign-functions=32
endif

ifeq ($(ARCH),ppc64)
  ifneq ($(shell ls /opt/cross/bin/powerpc64-linux-gcc > /dev/null 2>&1 && echo ppcgcc),)
    CC=/opt/cross/bin/powerpc64-linux-gcc
  endif

  ifneq ($(shell ls /opt/cross/bin/powerpc64-linux-ld > /dev/null 2>&1 && echo ppcld),)
    LD=/opt/cross/bin/powerpc64-linux-ld
  endif

  CFLAGS+=-fno-strict-aliasing -fno-common -fomit-frame-pointer -msoft-float -pipe -mminimal-toc -fno-builtin
endif

ifdef DBG
  CFLAGS += -DTIGON3_DEBUG=1
endif

ifdef SMALL
  CFLAGS += -Os -DBCM_SMALL_DRV=1
else
  CFLAGS += -O2
endif

all: bcm5700.o
tar: bcm5700.tgz

bcm5700.o: b57um.o b57proc.o tigon3.o autoneg.o 5701rls.o tcp_seg.o b57diag.o
	$(LD) -i $^ -o $@

endif # ifeq ($(BCM_KVER),2.6)

bcm5700.4.gz:
	gzip -c bcm5700.4 > bcm5700.4.gz

ifeq ($(BCM_KVER), 2.6)
install: default bcm5700.4.gz
else
install: $(BCM_DRV) bcm5700.4.gz
endif
	@if [ -d $(PREFIX)/lib/modules/$(shell uname -r)/kernel/3rdparty/bcm5700 ];\
	then rm -f $(PREFIX)/lib/modules/$(shell uname -r)/kernel/3rdparty/bcm5700/$(BCM_DRV).gz;\
	install -m 444 $(BCM_DRV) $(PREFIX)/lib/modules/$(shell uname -r)/kernel/3rdparty/bcm5700;\
	elif [ -d $(PREFIX)/lib/modules/$(shell uname -r)/kernel/drivers/addon/bcm5700 ];\
	then install -m 444 $(BCM_DRV) $(PREFIX)/lib/modules/$(shell uname -r)/kernel/drivers/addon/bcm5700;\
	elif [ -d $(PREFIX)/lib/modules/$(shell uname -r)/kernel/drivers/net/bcm ];\
	then install -m 444 $(BCM_DRV) $(PREFIX)/lib/modules/$(shell uname -r)/kernel/drivers/net/bcm;\
	elif [ -d $(PREFIX)/lib/modules/$(shell uname -r)/kernel ];\
	then mkdir -p $(PREFIX)/lib/modules/$(shell uname -r)/kernel/drivers/net;\
	install -m 444 $(BCM_DRV) $(PREFIX)/lib/modules/`uname -r`/kernel/drivers/net;\
	else mkdir -p $(PREFIX)/lib/modules/$(shell uname -r)/net;\
	install -m 444 $(BCM_DRV) $(PREFIX)/lib/modules/$(shell uname -r)/net/;\
	fi
	@if [ "$(PREFIX)" = "" ]; then /sbin/depmod -a ;\
	else echo " *** Run '/sbin/depmod -a' to update the module database.";\
	fi
	@if [ -d $(PREFIX)/usr/share/man ];\
	then install -m 444 bcm5700.4.gz $(PREFIX)/usr/share/man/man4;\
	elif [ -d $(PREFIX)/usr/man ];\
	then install -m 444 bcm5700.4.gz $(PREFIX)/usr/man/man4;\
	fi

bcm5700.tgz: Makefile *.[cho] LICENSE RELEASE.TXT
	tar cfvz $@ $^

rpm: bcm5700.tgz bcm5700.spec
	cp -p $< ${rpmdir}/SOURCES/
	rpm -ba bcm5700.spec

.PHONEY: all clean install tar

debug:
	@make DBG=1

small:
	@make SMALL=1

clean:
	-rm -f bcm5700.o bcm5700.ko b57um.o b57proc.o tigon3.o autoneg.o 5701rls.o tcp_seg.o b57diag.o bcm5700.mod.c bcm5700.mod.o

