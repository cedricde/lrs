#
# $Id$
#

CFLAGS=-O2 -Wall
CC=gcc

all: lrsd 

lrsd: lrsd.o dictionary.o iniparser.o  strlib.o
	gcc -s -o $@ $^ --static 

clean:
	rm -f *.o lrsd
	