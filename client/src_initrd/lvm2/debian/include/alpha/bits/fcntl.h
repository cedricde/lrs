#include_next <bits/fcntl.h>

#ifdef __USE_GNU
# define O_NOATIME	04000000 /* Do not set atime.  */
#endif
