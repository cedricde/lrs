#include <errno.h>

#define TOSTRING(x) #x
#define debug(...) fprintf(stderr, __VA_ARGS__)
#define UI_READ_ERROR ui_read_error(__FILE__,__LINE__, errno, fi)
#define UI_READ_ERROR2 ui_read_error(__FILE__,__LINE__, errno, 0)

void init_newt(unsigned char *,unsigned char *, unsigned long tot_sec,unsigned long used_sec, char *);
void close_newt(void);

void update_block(int,int);
void update_progress(int);
void update_file(int);
void stats(void);
void update_head(char *);
void update_part(char *dev);
void read_update_head(void);

void ui_write_error(void);
void ui_read_error(char *s, int l, int err, int fd);
void fatal(void);
