CFLAGS=-DLBLIMAGEVER=\"2.0\" -O2 -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 -Wall -I..
#LIBS=./libnewt.a -lslang
LIBS=-s -lnewt -lslang
CC=gcc

UI_OBJS=../server.o ui_newt.o ../easy_sock.o
#ZLIBOBJ=$(wildcard ../zlib/*.o)

all: uinewt 

uinewt: $(UI_OBJS) Makefile
	$(CC) $(CFLAGS) -o $@ $(UI_OBJS) $(LIBS)

#image_raw: image_raw.o client.o easy_sock.o compress.o $(ZLIBOBJ)
#	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^ -L..-I../zlib 
	
