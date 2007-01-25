CFLAGS=-I../zlib  -Wall -DLBLIMAGEVER=\"1.4\"  -Os -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 -Wall
LIBS=-L.. -llrs -s
CC=gcc

autorestore: autorestore.o Makefile
	$(CC) $(CFLAGS) -o $@ autorestore.o $(LIBS) 
