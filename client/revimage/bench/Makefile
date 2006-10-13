CFLAGS=-O2 -Wall -I../zlib-1.2.1 -DBENCH
LIBS= ../zlib-1.2.1/libz.a
CC=gcc-2.95

bench: main.o compress.o disk.o nfs.o
	$(CC) -s -o $@ $^ $(LIBS)

clean:                                                                          
	rm  -f *.o bench
