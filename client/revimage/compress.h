/*
 * $Id$
 */
 
#include <unistd.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>

#include "./zlib/zlib.h"

#define OUTBUFF 8192

#define HEADERLG 2048L
#define TOTALLG 24064L
#define ALLOCLG (TOTALLG-HEADERLG)

#define BLKGETSIZE _IO(0x12,96) /* return device size /512 (long *arg) */

#define debug(...) fprintf(stderr, __VA_ARGS__)

typedef struct {
  unsigned char *bitmap;
  unsigned long bitmaplg;
  unsigned long long nb_sect;
} PARAMS;

typedef struct i
{
    unsigned char header[HEADERLG] __attribute__((packed));
    unsigned char bitmap[ALLOCLG]  __attribute__((packed));
} IMAGE_HEADER;

typedef struct c
{
	z_streamp zptr;
	unsigned char outbuff[OUTBUFF];
	int end,state,header;
	unsigned long crc;
	unsigned int compressed_blocks,block;
	unsigned long offset;
	unsigned long long cbytes;
	FILE *f;
} COMPRESS;

void compress_volume (int fi, unsigned char *nameprefix, PARAMS * p, char *info);
void compress_init(COMPRESS **c,int block,unsigned long long bytes,FILE *index);
void compress_data(COMPRESS *c,unsigned char *data,int lg,FILE *out,char end);
unsigned long long compress_end(COMPRESS *c,FILE *out);
void compress_write_error (void);
//void setblocksize(FILE *f);
void setblocksize(int f);
void print_sect_info(long long unsigned tot_sec, long long unsigned used_sec);
