#include <errno.h>

#define TOSTRING(x) #x
#define debug(...) fprintf(stderr, __VA_ARGS__)
#define UI_READ_ERROR ui_read_error(__FILE__,__LINE__, errno, fi)
#define UI_READ_ERROR2 ui_read_error(__FILE__,__LINE__, errno, 0)

void init_newt(char *, char *, char *, char *, int);
void close_newt(void);

void update_progress(int);
void update_file(char *f, int, int, char *dev, int);
void stats(void);
void update_head(char *msg);
void read_update_head(void);

void ui_write_error(char *s, int l, int err, int fd);
void ui_zlib_error(int err);
