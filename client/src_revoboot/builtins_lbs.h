/*
 * $Id$
 */


/* functions */
void drive_info (unsigned char *buffer);
void cpuinfo (void);
int cpuspeed (void);

int smbios_init (void);
void smbios_get_sysinfo(char **p1, char **p2, char **p3, char **p4, char **p5);

int inc_func (char *arg, int flags);
int setdefault_func (char *arg, int flags);
int nosecurity_func (char *arg, int flags);
int partcopy_func (char *arg, int flags);
int ptabs_func (char *arg, int flags);
int test_func (char *arg, int flags);

/* variables */

/* grub builtins */

static struct builtin builtin_inc = {
  "inc",
  inc_func,
  BUILTIN_CMDLINE,
#ifdef HELP_ON
  "inc [MESSAGE ...]",
  "increment a LBS backup number."
#endif
};

static struct builtin builtin_setdefault = {
  "setdefault",
  setdefault_func,
  BUILTIN_CMDLINE,
#ifdef HELP_ON
  "setdefault number",
  "set the default grub menu entry for the next reboot."
#endif
};

static struct builtin builtin_nosecurity = {
  "nosecurity",
  nosecurity_func,
  BUILTIN_CMDLINE | BUILTIN_MENU,
#ifdef HELP_ON
  "nosecurity",
  "allow access to grub cmdline."
#endif
};

static struct builtin builtin_partcopy = {
  "partcopy",
  partcopy_func,
  BUILTIN_CMDLINE | BUILTIN_MENU,
#ifdef HELP_ON
  "partcopy START PREFIXNAME [TYPE]",
  "Create a primary partition at the starting address START with the"
    " compressed files beginning with PREFIXNAME. Update partition table "
    "with the partition TYPE type."
#endif
};

static struct builtin builtin_ptabs = {
  "ptabs",
  ptabs_func,
  BUILTIN_CMDLINE,
#ifdef HELP_ON
  "ptabs DISK FILE",
  "Copy uncompressed sectors from FILE (LBA,DATA) to disk DISK."
#endif
};

