ifneq ($(KERNELRELEASE),)
obj-m		:= lufs.o
lufs-objs	:= proc.o inode.o dir.o file.o symlink.o

else
KDIR=/lib/modules/2.6.5/build
PWD=`pwd`

.DEFAULT:
	$(MAKE) -C $(KDIR) SUBDIRS=$(PWD) modules

endif
