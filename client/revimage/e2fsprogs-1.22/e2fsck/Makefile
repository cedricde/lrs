# Generated automatically from Makefile.in by configure.
#
# Makefile for e2fsck
#

srcdir = .
top_srcdir = ..
top_builddir = ..
my_dir = e2fsck
INSTALL = /usr/bin/install -c
LDFLAG_STATIC = -static


# Beginning of file MCONFIG

all::

check::

SHELL = /bin/sh

prefix = /usr
root_prefix = 
exec_prefix = ${prefix}
root_bindir = $(root_prefix)/bin
root_sbindir = $(root_prefix)/sbin
root_libdir = $(root_prefix)/lib
bindir = ${exec_prefix}/bin
sbindir = ${exec_prefix}/sbin
libdir = ${exec_prefix}/lib
includedir = ${prefix}/include
mandir = ${prefix}/man
man1dir = $(mandir)/man1
man3dir = $(mandir)/man3
man8dir = $(mandir)/man8
infodir = ${prefix}/info
datadir = ${prefix}/share



INSTALL_PROGRAM = ${INSTALL}
INSTALL_DATA = ${INSTALL} -m 644
CC = cc
BUILD_CC = cc
DEFS =  -DENABLE_SWAPFS=1 -DPACKAGE=\"e2fsprogs\" -DVERSION=\"1.22\" -DSTDC_HEADERS=1 -DHAVE_ALLOCA_H=1 -DHAVE_ALLOCA=1 -DHAVE_UNISTD_H=1 -DHAVE_GETPAGESIZE=1 -DHAVE_MMAP=1 -DHAVE_ARGZ_H=1 -DHAVE_LIMITS_H=1 -DHAVE_LOCALE_H=1 -DHAVE_NL_TYPES_H=1 -DHAVE_MALLOC_H=1 -DHAVE_STRING_H=1 -DHAVE_UNISTD_H=1 -DHAVE_SYS_PARAM_H=1 -DHAVE_GETCWD=1 -DHAVE_MUNMAP=1 -DHAVE_PUTENV=1 -DHAVE_SETENV=1 -DHAVE_SETLOCALE=1 -DHAVE_STRCHR=1 -DHAVE_STRCASECMP=1 -DHAVE_STRDUP=1 -DHAVE___ARGZ_COUNT=1 -DHAVE___ARGZ_STRINGIFY=1 -DHAVE___ARGZ_NEXT=1 -DHAVE_STPCPY=1 -DHAVE_STPCPY=1 -DHAVE_LC_MESSAGES=1 -DHAVE_STDLIB_H=1 -DHAVE_UNISTD_H=1 -DHAVE_STDARG_H=1 -DHAVE_ERRNO_H=1 -DHAVE_MALLOC_H=1 -DHAVE_MNTENT_H=1 -DHAVE_PATHS_H=1 -DHAVE_DIRENT_H=1 -DHAVE_GETOPT_H=1 -DHAVE_SETJMP_H=1 -DHAVE_SIGNAL_H=1 -DHAVE_TERMIOS_H=1 -DHAVE_LINUX_FD_H=1 -DHAVE_LINUX_MAJOR_H=1 -DHAVE_SYS_IOCTL_H=1 -DHAVE_SYS_MOUNT_H=1 -DHAVE_SYS_SYSMACROS_H=1 -DHAVE_SYS_TIME_H=1 -DHAVE_SYS_STAT_H=1 -DHAVE_SYS_TYPES_H=1 -DHAVE_NET_IF_H=1 -DHAVE_NETINET_IN_H=1 -DHAVE_VPRINTF=1 -DHAVE_LSEEK64_PROTOTYPE=1 -DSIZEOF_SHORT=2 -DSIZEOF_INT=4 -DSIZEOF_LONG=4 -DSIZEOF_LONG_LONG=8 -DHAVE_GETRUSAGE=1 -DHAVE_LLSEEK=1 -DHAVE_LSEEK64=1 -DHAVE_OPEN64=1 -DHAVE_STRDUP=1 -DHAVE_STRCASECMP=1 -DHAVE_SRANDOM=1 -DHAVE_FCHOWN=1 -DHAVE_MALLINFO=1 -DHAVE_FDATASYNC=1 -DHAVE_EXT2_IOCTLS=1 
CFLAGS = -g -O2
CPPFLAGS = 
ALL_CFLAGS = $(CPPFLAGS) $(DEFS) $(USE_WFLAGS) $(CFLAGS) $(XTRA_CFLAGS) \
	-I$(top_builddir)/lib -I$(top_srcdir)/lib \
	-I$(top_srcdir)/include $(LINUX_INCLUDE) 
LDFLAGS = 
ALL_LDFLAGS = $(LDFLAGS)
RM = /bin/rm
LN = /bin/ln
LN_S = ln -s
MV = /bin/mv
CP = /bin/cp
CHMOD = /bin/chmod
AR = ar
AWK = /usr/bin/awk
SED = /bin/sed
PERL = /usr/bin/perl
RANLIB = ranlib
STRIP = strip
LD = $(PURE) cc
ARUPD = $(AR) r
LDCONFIG = /sbin/ldconfig

#
# Library definitions
#
LIB = $(top_builddir)/lib
LIBSS = $(LIB)/libss.a
LIBCOM_ERR = $(LIB)/libcom_err.a
LIBE2P = $(LIB)/libe2p.a
LIBEXT2FS = $(LIB)/libext2fs.a
LIBUUID = $(LIB)/libuuid.a  
DEPLIBUUID = $(LIB)/libuuid.a

STATIC_LIBSS = $(LIB)/libss.a
STATIC_LIBCOM_ERR = $(LIB)/libcom_err.a
STATIC_LIBE2P = $(LIB)/libe2p.a
STATIC_LIBEXT2FS = $(LIB)/libext2fs.a
STATIC_LIBUUID = $(LIB)/libuuid.a  
DEPSTATIC_LIBUUID = $(LIB)/libuuid.a

PROFILED_LIBSS = $(LIB)/libss
PROFILED_LIBCOM_ERR = $(LIB)/libcom_err
PROFILED_LIBE2P = $(LIB)/libe2p
PROFILED_LIBEXT2FS = $(LIB)/libext2fs
PROFILED_LIBUUID = $(LIB)/libuuid  
DEPPROFILED_LIBUUID = $(LIB)/libuuid

#
# Use these definitions is you use tools 2.x, x < 16
#
#DLL_BIN=/usr/dll/bin
#JUMP_PREFIX=/usr/dll/jump/

#
# Use these definitions if you use tools 2.16 or above
#
DLL_BIN=/usr/bin
JUMP_PREFIX=/usr/bin/jump

# An include directive pointing to a directory holding enough linux-like
# include files to satisfy some programs here
LINUX_INCLUDE=

#
# A fast substitution command for fixing up man pages, shell scripts, etc.
#
SUBST_CONF=$(top_builddir)/util/subst.conf
SUBSTITUTE= $(top_builddir)/util/subst -f $(SUBST_CONF)
DEP_SUBSTITUTE= $(top_builddir)/util/subst $(SUBST_CONF)

$(top_builddir)/util/subst:
	cd $(top_builddir)/util ; $(MAKE) subst

#
# Warning flags
#
# Run make gcc-wall to do a build with warning messages.
#
#
WFLAGS=		-ansi -D_POSIX_SOURCE -pedantic \
			-Wall -Wwrite-strings -Wpointer-arith \
			-Wcast-qual -Wcast-align -Wtraditional \
			-Wstrict-prototypes -Wmissing-prototypes \
			-Wnested-externs -Winline -DNO_INLINE_FUNCS -Wshadow 

gcc-wall-new:
	(make USE_WFLAGS="$(WFLAGS)" > /dev/null) 2>&1 | sed -f $(top_srcdir)/util/gcc-wall-cleanup 

gcc-wall:
	make clean > /dev/null
	make gcc-wall-new

#
# Installation user and groups
#
BINGRP=		bin
BINOWN=		bin
BINMODE=	555
INCGRP=		bin
INCOWN=		bin
INCMODE=	444
LIBOWN=		bin
LIBGRP=		bin
LIBMODE=	444
MANGRP=		bin
MANOWN=		bin
MANMODE=	444

#
# Autoconf magic...
#

DEP_LIB_MAKEFILES = $(top_srcdir)/lib/Makefile.elf-lib  \
	$(top_srcdir)/lib/Makefile.dll-lib $(top_srcdir)/lib/Makefile.bsd-lib \
	$(top_srcdir)/lib/Makefile.checker $(top_srcdir)/lib/Makefile.profile

$(top_builddir)/config.status: $(top_srcdir)/configure
	cd $(top_builddir); ./config.status --recheck

$(top_builddir)/MCONFIG: $(top_srcdir)/MCONFIG.in $(top_builddir)/config.status
	cd $(top_builddir); CONFIG_FILES=MCONFIG ./config.status

$(top_builddir)/lib/substitute_sh: $(top_srcdir)/lib/substitute_sh.in \
		$(top_builddir)/config.status
	cd $(top_builddir); CONFIG_FILES=lib/substitute_sh ./config.status

$(top_builddir)/util/subst.conf: $(top_srcdir)/util/subst.conf.in \
		$(top_builddir)/config.status
	cd $(top_builddir); CONFIG_FILES=util/subst.conf ./config.status

Makefile: $(srcdir)/Makefile.in $(top_builddir)/MCONFIG \
		$(DEP_MAKEFILE) $(top_builddir)/config.status
	cd $(top_builddir); CONFIG_FILES=$(my_dir)/Makefile ./config.status

$(top_srcdir)/configure: $(top_srcdir)/configure.in
	cd $(top_srcdir) && autoconf

#
# Make depend magic...
#

.depend: Makefile $(SRCS) $(top_srcdir)/depfix.sed $(top_srcdir)/wordwrap.pl
	if test -n "$(SRCS)" ; then \
		$(CC) -M $(ALL_CFLAGS) $(SRCS) | \
			$(SED) -f $(top_srcdir)/depfix.sed \
			    -e 's; $(srcdir)/; $$(srcdir)/;g' \
			    -e 's; $(top_srcdir)/; $$(top_srcdir)/;g' \
			    -e 's; $(top_builddir)/; $$(top_builddir)/;g' \
			    -e 's; \./; ;g' \
			    -e '/^ *\\$$/d' | \
			$(PERL) $(top_srcdir)/wordwrap.pl > .depend; \
	else :; fi

depend:: .depend
	if test -n "$(SRCS)" ; then \
		sed -e '/^# +++ Dependency line eater +++/,$$d' \
			< $(srcdir)/Makefile.in | cat - .depend \
			> $(srcdir)/Makefile.in.new; \
	if cmp -s $(srcdir)/Makefile.in $(srcdir)/Makefile.in.new ; then \
		$(RM) $(srcdir)/Makefile.in.new ; \
	else \
		$(MV) $(srcdir)/Makefile.in $(srcdir)/Makefile.in.old; \
		$(MV) $(srcdir)/Makefile.in.new $(srcdir)/Makefile.in; \
	fi ; else :; fi

# End of file MCONFIG

PROGS=		e2fsck
MANPAGES=	e2fsck.8
XTRA_CFLAGS=	-DRESOURCE_TRACK

LIBS= $(LIBEXT2FS) $(LIBCOM_ERR) $(LIBUUID)
DEPLIBS= $(LIBEXT2FS) $(LIBCOM_ERR) $(DEPLIBUUID)

STATIC_LIBS= $(STATIC_LIBEXT2FS) $(STATIC_LIBCOM_ERR) $(STATIC_LIBUUID)
STATIC_DEPLIBS= $(STATIC_LIBEXT2FS) $(STATIC_LIBCOM_ERR) $(DEPSTATIC_LIBUUID)

PROFILED_LIBS= $(PROFILED_LIBEXT2FS) $(PROFILED_LIBCOM_ERR) $(PROFILED_LIBUUID)
PROFILED_DEPLIBS= $(PROFILED_LIBEXT2FS) $(PROFILED_LIBCOM_ERR) \
	$(DEPPROFILED_LIBUUID)

.c.o:
	$(CC) -c $(ALL_CFLAGS) $< -o $@
#	$(CC) $(ALL_CFLAGS) -g -pg -o profiled/$*.o -c $<

#
# Flags for using Checker
#	Note: The optimization flags must include -g
#
#MCHECK=	-checker
#LIBS= $(LIBCOM_ERR) $(LIB_EXT2FS) $(CHECKLIB)
#DEPLIBS= $(LIBCOM_ERR) $(LIB_EXT2FS) 
#CHECKLIB= /usr/lib/libchecker.o

#
# Flags for doing mtrace --- uncomment to produce mtracing e2fsck
# 	Note:  The optimization flags must include -g
#
#MTRACE=	-DMTRACE
#MTRACE_OBJ= mtrace.o
#MTRACE_SRC= $(srcdir)/mtrace.c
#OPT= -g

#
# Flags for doing mcheck --- uncomment to produce mchecking e2fsck
# 	Note:  The optimization flags must include -g
#
#MCHECK= -DMCHECK

OBJS= unix.o e2fsck.o super.o pass1.o pass1b.o pass2.o pass3.o pass4.o \
	pass5.o journal.o swapfs.o badblocks.o util.o dirinfo.o ehandler.o \
	problem.o message.o recovery.o revoke.o $(MTRACE_OBJ)

PROFILED_OBJS= profiled/unix.o profiled/e2fsck.o profiled/super.o \
	profiled/pass1.o profiled/pass1b.o \
	profiled/pass2.o profiled/pass3.o profiled/pass4.o profiled/pass5.o \
	profiled/journal.o profiled/badblocks.o profiled/util.o \
	profiled/dirinfo.o profiled/ehandler.o profiled/message.o \
	profiled/problem.o profiled/swapfs.o profiled/recovery.o \
	profiled/revoke.o

SRCS= $(srcdir)/e2fsck.c \
	$(srcdir)/super.c \
	$(srcdir)/pass1.c \
	$(srcdir)/pass1b.c \
	$(srcdir)/pass2.c \
	$(srcdir)/pass3.c \
	$(srcdir)/pass4.c \
	$(srcdir)/pass5.c \
	$(srcdir)/journal.c \
	$(srcdir)/recovery.c \
	$(srcdir)/revoke.c \
	$(srcdir)/badblocks.c \
	$(srcdir)/util.c \
	$(srcdir)/unix.c \
	$(srcdir)/dirinfo.c \
	$(srcdir)/ehandler.c \
	$(srcdir)/problem.c \
	$(srcdir)/message.c \
	$(srcdir)/swapfs.c \
	$(MTRACE_SRC)

all:: profiled $(PROGS) e2fsck.static e2fsck.shared $(MANPAGES)
	@sync

#all:: e2fsck.profiled

e2fsck: e2fsck.static
	$(CP) e2fsck.static e2fsck

e2fsck.static: $(OBJS)  $(STATIC_DEPLIBS)
	$(LD) $(ALL_LDFLAGS) $(LDFLAG_STATIC) -o e2fsck.static $(OBJS) \
		$(STATIC_LIBS) 

e2fsck.shared: $(OBJS)  $(DEPLIBS)
	$(LD) $(ALL_LDFLAGS) -o e2fsck.shared $(OBJS) $(LIBS) 

e2fsck.profiled: $(PROFILED_OBJS)  $(PROFILED_DEPLIBS)
	$(LD) $(ALL_LDFLAGS) -g -pg -o e2fsck.profiled $(PROFILED_OBJS) \
		$(PROFILED_LIBS) 

extend: extend.o
	$(LD) $(ALL_LDFLAGS) -o extend extend.o $(CHECKLIB)

flushb: flushb.o
	$(LD) $(ALL_LDFLAGS) -o flushb flushb.o $(CHECKLIB)

iscan: iscan.o util.o
	$(LD) $(ALL_LDFLAGS) -o iscan iscan.o util.o ehandler.o $(LIBS)

profiled:
	mkdir profiled

e2fsck.8: $(DEP_SUBSTITUTE) $(srcdir)/e2fsck.8.in
	$(SUBSTITUTE) $(srcdir)/e2fsck.8.in e2fsck.8

installdirs:
	$(top_srcdir)/mkinstalldirs $(DESTDIR)$(root_sbindir) \
		$(DESTDIR)$(man8dir)

install: $(PROGS) $(MANPAGES) installdirs
	for i in $(PROGS); do \
		$(INSTALL_PROGRAM) $$i $(DESTDIR)$(root_sbindir)/$$i; \
		$(STRIP) $(DESTDIR)$(root_sbindir)/$$i; \
	done
	$(LN) -f $(DESTDIR)$(root_sbindir)/e2fsck \
			$(DESTDIR)$(root_sbindir)/fsck.ext2
	$(LN) -f $(DESTDIR)$(root_sbindir)/e2fsck \
			$(DESTDIR)$(root_sbindir)/fsck.ext3
	for i in $(MANPAGES); do \
		$(INSTALL_DATA) $$i $(DESTDIR)$(man8dir)/$$i; \
	done

uninstall:
	for i in $(PROGS); do \
		$(RM) -f $(DESTDIR)$(root_sbindir)/$$i; \
	done
	$(RM) -f $(DESTDIR)$(root_sbindir)/fsck.ext2 \
		$(DESTDIR)$(root_sbindir)/fsck.ext3
	for i in $(MANPAGES); do \
		$(RM) -f $(DESTDIR)$(man8dir)/$$i; \
	done

clean:
	$(RM) -f $(PROGS) \#* *\# *.s *.o *.a *~ core e2fsck.static \
		e2fsck.shared e2fsck.profiled flushb e2fsck.8
	$(RM) -rf profiled

mostlyclean: clean
distclean: clean
	$(RM) -f .depend Makefile $(srcdir)/TAGS $(srcdir)/Makefile.in.old

# +++ Dependency line eater +++
# 
# Makefile dependencies follow.  This must be the last section in
# the Makefile.in file
#
e2fsck.o: $(srcdir)/e2fsck.c $(srcdir)/e2fsck.h \
 $(top_srcdir)/lib/ext2fs/ext2_fs.h $(top_builddir)/lib/ext2fs/ext2_types.h \
 $(top_srcdir)/lib/ext2fs/ext2fs.h $(top_srcdir)/lib/et/com_err.h \
 $(top_srcdir)/lib/ext2fs/ext2_io.h $(top_builddir)/lib/ext2fs/ext2_err.h \
 $(top_srcdir)/lib/ext2fs/bitops.h $(srcdir)/problem.h
super.o: $(srcdir)/super.c $(top_srcdir)/lib/uuid/uuid.h $(srcdir)/e2fsck.h \
 $(top_srcdir)/lib/ext2fs/ext2_fs.h $(top_builddir)/lib/ext2fs/ext2_types.h \
 $(top_srcdir)/lib/ext2fs/ext2fs.h $(top_srcdir)/lib/et/com_err.h \
 $(top_srcdir)/lib/ext2fs/ext2_io.h $(top_builddir)/lib/ext2fs/ext2_err.h \
 $(top_srcdir)/lib/ext2fs/bitops.h $(srcdir)/problem.h
pass1.o: $(srcdir)/pass1.c $(srcdir)/e2fsck.h \
 $(top_srcdir)/lib/ext2fs/ext2_fs.h $(top_builddir)/lib/ext2fs/ext2_types.h \
 $(top_srcdir)/lib/ext2fs/ext2fs.h $(top_srcdir)/lib/et/com_err.h \
 $(top_srcdir)/lib/ext2fs/ext2_io.h $(top_builddir)/lib/ext2fs/ext2_err.h \
 $(top_srcdir)/lib/ext2fs/bitops.h $(srcdir)/problem.h
pass1b.o: $(srcdir)/pass1b.c $(top_srcdir)/lib/et/com_err.h \
 $(srcdir)/e2fsck.h $(top_srcdir)/lib/ext2fs/ext2_fs.h \
 $(top_builddir)/lib/ext2fs/ext2_types.h $(top_srcdir)/lib/ext2fs/ext2fs.h \
 $(top_srcdir)/lib/ext2fs/ext2_io.h $(top_builddir)/lib/ext2fs/ext2_err.h \
 $(top_srcdir)/lib/ext2fs/bitops.h $(srcdir)/problem.h
pass2.o: $(srcdir)/pass2.c $(srcdir)/e2fsck.h \
 $(top_srcdir)/lib/ext2fs/ext2_fs.h $(top_builddir)/lib/ext2fs/ext2_types.h \
 $(top_srcdir)/lib/ext2fs/ext2fs.h $(top_srcdir)/lib/et/com_err.h \
 $(top_srcdir)/lib/ext2fs/ext2_io.h $(top_builddir)/lib/ext2fs/ext2_err.h \
 $(top_srcdir)/lib/ext2fs/bitops.h $(srcdir)/problem.h
pass3.o: $(srcdir)/pass3.c $(srcdir)/e2fsck.h \
 $(top_srcdir)/lib/ext2fs/ext2_fs.h $(top_builddir)/lib/ext2fs/ext2_types.h \
 $(top_srcdir)/lib/ext2fs/ext2fs.h $(top_srcdir)/lib/et/com_err.h \
 $(top_srcdir)/lib/ext2fs/ext2_io.h $(top_builddir)/lib/ext2fs/ext2_err.h \
 $(top_srcdir)/lib/ext2fs/bitops.h $(srcdir)/problem.h
pass4.o: $(srcdir)/pass4.c $(srcdir)/e2fsck.h \
 $(top_srcdir)/lib/ext2fs/ext2_fs.h $(top_builddir)/lib/ext2fs/ext2_types.h \
 $(top_srcdir)/lib/ext2fs/ext2fs.h $(top_srcdir)/lib/et/com_err.h \
 $(top_srcdir)/lib/ext2fs/ext2_io.h $(top_builddir)/lib/ext2fs/ext2_err.h \
 $(top_srcdir)/lib/ext2fs/bitops.h $(srcdir)/problem.h
pass5.o: $(srcdir)/pass5.c $(srcdir)/e2fsck.h \
 $(top_srcdir)/lib/ext2fs/ext2_fs.h $(top_builddir)/lib/ext2fs/ext2_types.h \
 $(top_srcdir)/lib/ext2fs/ext2fs.h $(top_srcdir)/lib/et/com_err.h \
 $(top_srcdir)/lib/ext2fs/ext2_io.h $(top_builddir)/lib/ext2fs/ext2_err.h \
 $(top_srcdir)/lib/ext2fs/bitops.h $(srcdir)/problem.h
journal.o: $(srcdir)/journal.c $(srcdir)/jfs_user.h $(srcdir)/e2fsck.h \
 $(top_srcdir)/lib/ext2fs/ext2_fs.h $(top_builddir)/lib/ext2fs/ext2_types.h \
 $(top_srcdir)/lib/ext2fs/ext2fs.h $(top_srcdir)/lib/et/com_err.h \
 $(top_srcdir)/lib/ext2fs/ext2_io.h $(top_builddir)/lib/ext2fs/ext2_err.h \
 $(top_srcdir)/lib/ext2fs/bitops.h $(top_srcdir)/include/linux/jfs.h \
 $(top_srcdir)/include/linux/jfs_compat.h $(top_srcdir)/include/linux/list.h \
 $(srcdir)/problem.h $(top_srcdir)/lib/uuid/uuid.h
recovery.o: $(srcdir)/recovery.c $(srcdir)/jfs_user.h $(srcdir)/e2fsck.h \
 $(top_srcdir)/lib/ext2fs/ext2_fs.h $(top_builddir)/lib/ext2fs/ext2_types.h \
 $(top_srcdir)/lib/ext2fs/ext2fs.h $(top_srcdir)/lib/et/com_err.h \
 $(top_srcdir)/lib/ext2fs/ext2_io.h $(top_builddir)/lib/ext2fs/ext2_err.h \
 $(top_srcdir)/lib/ext2fs/bitops.h $(top_srcdir)/include/linux/jfs.h \
 $(top_srcdir)/include/linux/jfs_compat.h $(top_srcdir)/include/linux/list.h
revoke.o: $(srcdir)/revoke.c $(srcdir)/jfs_user.h $(srcdir)/e2fsck.h \
 $(top_srcdir)/lib/ext2fs/ext2_fs.h $(top_builddir)/lib/ext2fs/ext2_types.h \
 $(top_srcdir)/lib/ext2fs/ext2fs.h $(top_srcdir)/lib/et/com_err.h \
 $(top_srcdir)/lib/ext2fs/ext2_io.h $(top_builddir)/lib/ext2fs/ext2_err.h \
 $(top_srcdir)/lib/ext2fs/bitops.h $(top_srcdir)/include/linux/jfs.h \
 $(top_srcdir)/include/linux/jfs_compat.h $(top_srcdir)/include/linux/list.h
badblocks.o: $(srcdir)/badblocks.c $(top_srcdir)/lib/et/com_err.h \
 $(srcdir)/e2fsck.h $(top_srcdir)/lib/ext2fs/ext2_fs.h \
 $(top_builddir)/lib/ext2fs/ext2_types.h $(top_srcdir)/lib/ext2fs/ext2fs.h \
 $(top_srcdir)/lib/ext2fs/ext2_io.h $(top_builddir)/lib/ext2fs/ext2_err.h \
 $(top_srcdir)/lib/ext2fs/bitops.h
util.o: $(srcdir)/util.c $(srcdir)/e2fsck.h \
 $(top_srcdir)/lib/ext2fs/ext2_fs.h $(top_builddir)/lib/ext2fs/ext2_types.h \
 $(top_srcdir)/lib/ext2fs/ext2fs.h $(top_srcdir)/lib/et/com_err.h \
 $(top_srcdir)/lib/ext2fs/ext2_io.h $(top_builddir)/lib/ext2fs/ext2_err.h \
 $(top_srcdir)/lib/ext2fs/bitops.h
unix.o: $(srcdir)/unix.c $(top_srcdir)/lib/et/com_err.h $(srcdir)/e2fsck.h \
 $(top_srcdir)/lib/ext2fs/ext2_fs.h $(top_builddir)/lib/ext2fs/ext2_types.h \
 $(top_srcdir)/lib/ext2fs/ext2fs.h $(top_srcdir)/lib/ext2fs/ext2_io.h \
 $(top_builddir)/lib/ext2fs/ext2_err.h $(top_srcdir)/lib/ext2fs/bitops.h \
 $(srcdir)/problem.h $(top_srcdir)/version.h
dirinfo.o: $(srcdir)/dirinfo.c $(srcdir)/e2fsck.h \
 $(top_srcdir)/lib/ext2fs/ext2_fs.h $(top_builddir)/lib/ext2fs/ext2_types.h \
 $(top_srcdir)/lib/ext2fs/ext2fs.h $(top_srcdir)/lib/et/com_err.h \
 $(top_srcdir)/lib/ext2fs/ext2_io.h $(top_builddir)/lib/ext2fs/ext2_err.h \
 $(top_srcdir)/lib/ext2fs/bitops.h
ehandler.o: $(srcdir)/ehandler.c $(srcdir)/e2fsck.h \
 $(top_srcdir)/lib/ext2fs/ext2_fs.h $(top_builddir)/lib/ext2fs/ext2_types.h \
 $(top_srcdir)/lib/ext2fs/ext2fs.h $(top_srcdir)/lib/et/com_err.h \
 $(top_srcdir)/lib/ext2fs/ext2_io.h $(top_builddir)/lib/ext2fs/ext2_err.h \
 $(top_srcdir)/lib/ext2fs/bitops.h
problem.o: $(srcdir)/problem.c $(srcdir)/e2fsck.h \
 $(top_srcdir)/lib/ext2fs/ext2_fs.h $(top_builddir)/lib/ext2fs/ext2_types.h \
 $(top_srcdir)/lib/ext2fs/ext2fs.h $(top_srcdir)/lib/et/com_err.h \
 $(top_srcdir)/lib/ext2fs/ext2_io.h $(top_builddir)/lib/ext2fs/ext2_err.h \
 $(top_srcdir)/lib/ext2fs/bitops.h $(srcdir)/problem.h $(srcdir)/problemP.h
message.o: $(srcdir)/message.c $(srcdir)/e2fsck.h \
 $(top_srcdir)/lib/ext2fs/ext2_fs.h $(top_builddir)/lib/ext2fs/ext2_types.h \
 $(top_srcdir)/lib/ext2fs/ext2fs.h $(top_srcdir)/lib/et/com_err.h \
 $(top_srcdir)/lib/ext2fs/ext2_io.h $(top_builddir)/lib/ext2fs/ext2_err.h \
 $(top_srcdir)/lib/ext2fs/bitops.h $(srcdir)/problem.h
swapfs.o: $(srcdir)/swapfs.c $(top_srcdir)/lib/et/com_err.h \
 $(srcdir)/e2fsck.h $(top_srcdir)/lib/ext2fs/ext2_fs.h \
 $(top_builddir)/lib/ext2fs/ext2_types.h $(top_srcdir)/lib/ext2fs/ext2fs.h \
 $(top_srcdir)/lib/ext2fs/ext2_io.h $(top_builddir)/lib/ext2fs/ext2_err.h \
 $(top_srcdir)/lib/ext2fs/bitops.h
