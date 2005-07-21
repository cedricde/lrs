CFLAGS=-I../zlib-1.2.1  -Wall -DLBLIMAGEVER=\"1.1\"  -O2 -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 -pedantic
LIBS=-L../zlib-1.2.1/ -lz -lnewt -s


autorestore: autorestore.o ui_newt.o Makefile
	$(CC) $(CFLAGS) -o $@ autorestore.o ui_newt.o $(LIBS) 
