CC =		gcc
LOBS = 		-lpnm -lppm -lpgm -lpbm -lpopt

TREE = $(DESTDIR)/usr
# FHS/FSSTND; or /usr/local
MANTREE = $(TREE)/share/man
# FHS; for FSSTND or local, use $(TREE)/man

# Support these framebuffer formats:
#
# VIDEO_PLANES:             Noninterleaved bitplanes
# VIDEO_INTERLEAVED_PLANES: Amiga interleaved bitplanes (ilbm)
# VIDEO_PACKED_PIXELS:      Packed pixels (mfb, cfb[248])
# VIDEO_HAM:                Amiga HAM6/HAM8 video
# VIDEO_IPLAN2Px:           Atari interleaved bitplanes (iplan2p[248])
# VIDEO_VGA16:              IBM VGA 16 colors (vga_planes)
#
# Compile everything by default.

FORMATS = -DVIDEO_PLANES -DVIDEO_INTERLEAVED_PLANES -DVIDEO_HAM \
	  -DVIDEO_PACKED_PIXELS -DVIDEO_IPLAN2Px -DVIDEO_VGA16

CFLAGS = -O2 -g -Wall -I.
#CFLAGS = -DDEBUG -g -Wall
INSTALL = install -o root -g root
SUIDBIN = -m4755

%.o: %.c
	$(CC) $(CFLAGS) $(FORMATS) -o $@ -c $<

all: ppmtofb

ppmtofb: ppmtofb.o encodeham.o colortables.o
	$(CC) -o $@ $^ $(LOBS)

ppmtofb.o: ppmtofb.c vga16.h version.h

version.h: debian/changelog
	@echo "#define VERSION \"`head -1 debian/changelog | sed -e 's/[^(]*(\([^)]*\).*/\1/'`\"" > version.h

root: ppmtofb
	chown root.root ppmtofb
	chmod u+s ppmtofb

install: 
	$(INSTALL) $(SUIDBIN) -s ppmtofb $(TREE)/bin/ppmtofb
	$(INSTALL) -m755 fbview.py $(TREE)/bin/fbview
	$(INSTALL) -m644 ppmtofb.1 $(MANTREE)/man1/ppmtofb.1
	$(INSTALL) -m644 fbview.1 $(MANTREE)/man1/fbview.1

clean:
	rm -f *.o ppmtofb version.h *~

distclean:
	rm -f *.o *~

.PHONY: root install clean distclean all
