#
# Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
# Copyright (C) 2004 Red Hat, Inc. All rights reserved.
#
# This file is part of the LVM2.
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions
# of the GNU General Public License v.2.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software Foundation,
# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

srcdir = .
top_srcdir = ../..


SOURCES = fsadm.c

TARGETS = fsadm

include $(top_srcdir)/make.tmpl

fsadm: $(OBJECTS)
	$(CC) -o $@ $(OBJECTS) -rdynamic

install: fsadm
	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) fsadm \
		$(sbindir)/fsadm

