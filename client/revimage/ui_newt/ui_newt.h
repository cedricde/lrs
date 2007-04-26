#include <errno.h>

#define TOSTRING(x) #x
#define UI_READ_ERROR ui_read_error(__FILE__,__LINE__, errno, fi)
#define UI_READ_ERROR2 ui_read_error(__FILE__,__LINE__, errno, 0)

void update_file(int);
int stats(void);
void update_head(char *);
void update_part(char *dev);
void read_update_head(void);

void ui_write_error(void);
void fatal(void);
void waitkey(void);