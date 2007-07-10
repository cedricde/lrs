/* ppmtofb - Display P?M graphics on framebuffer devices
 *
 *  © Copyright 1996 by Geert Uytterhoeven
 *  © Copyright 1996-2001 by Chris Lawrence
 *
 *  This file is subject to the terms and conditions of the GNU General Public
 *  License.  See the file COPYING in the main directory of the Linux
 *  distribution for more details.
 */

/*  Known bug:
 *    - ppmtofb must be setuid root to access the ttys it needs.
 *      However, no disk I/O is done as root unless the uid and euid are root. 
 */

/* Enhanced to use Günther Röhrich's more sophisticated HAM8 encoding
 * from his jpegAGA program.
 *
 * Günther's implementation (in 680x0 assembler) is freely redistributable.
 *
 * My modifications (converting it to C and using the P?M interface)
 * are copyrighted by me and subject to the GPL.
 * - Chris Lawrence <lawrencc@debian.org>
 */

#undef RDB_DEBUG /* Define to disable VT lockdown */

/* Change for non-Debian systems */
#define COPYING "/usr/share/common-licenses/GPL"

#include <stdio.h>
#include <stdarg.h>
#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <unistd.h>
#include <linux/fb.h>
#include <linux/kd.h>
#include <linux/vt.h>
#include <signal.h>
#include <ppm.h>
#include "ppmcmap.h"
#include <errno.h>
#include <endian.h>
#include <popt.h>
#include <time.h>
#include <string.h>

#include "version.h"

/* Include other architectures sans-ioperm here */
#if defined(__mc68000) || defined(__powerpc__)
#undef VIDEO_VGA16
#endif

#ifdef VIDEO_VGA16
#include <sys/io.h>
#include "vga16.h"
#endif

#if defined(VIDEO_PLANES) | defined(VIDEO_INTERLEAVED_PLANES)
#define VIDEO_ANY_PLANES
#endif

#ifndef FB_TYPE_VGA_PLANES
#define FB_TYPE_VGA_PLANES 4
#endif

#define COLOR_MODE_TRUE    1
#define COLOR_MODE_NORMAL  2
#define COLOR_MODE_GRAY    3

    /*
     *  Command Line Options
     */

#define DEFAULT_DEPTH 8

static const char *ProgramName;
static int delay = 5, center = 0;
static int grayscale = 0, random_dither = 0;
int depth = 0;
int bytes_per_pixel;
int verbose = 0;
int fbtype = 0;
int no_ham = 0;
int cutoff = 0;

static u_int32_t visual = -1;

#ifdef VIDEO_HAM
#define HAM_NONE 0
#define HAM_HAM6 1
#define HAM_HAM8 2

static int hamallowed = HAM_NONE;
#endif

    /*
     *  Console and Fram Buffer
     */

static int ActiveVT = -1;
static int ConsoleFd = 0;
static char *FrameBufferName = NULL;
static int VC = -1;
static int FrameBufferFD = -1;
static caddr_t FrameBufferBits = (caddr_t) - 1;
static size_t FrameBufferSize;
u_int16_t DisplayWidth, DisplayHeight;
u_int32_t NextLine, LineLength, NextPlane, PixelSkip = 0;

    /*
     *  Color Maps
     */

/* Cache for HAM colors: must have 2^18 entries */
#define CACHESIZE (64*64*64)

static u_int16_t *Gray;
static struct fb_cmap GrayMap;

#ifdef VIDEO_HAM
static u_int16_t HAMRed[64];
static u_int16_t HAMGreen[64];
static u_int16_t HAMBlue[64];
static struct fb_cmap HAMColorMap =
{
  0, -1, HAMRed, HAMGreen, HAMBlue
};
#endif

static u_int16_t PlanarRed[256];
static u_int16_t PlanarGreen[256];
static u_int16_t PlanarBlue[256];
static struct fb_cmap PlanarColorMap =
{
  0, 256, PlanarRed, PlanarGreen, PlanarBlue
};

static u_int32_t PlanarLookup[256];
static u_int16_t PlanarColors;

#undef USE_JPEGAGA_HAM8_TABLE

#ifdef VIDEO_HAM
#ifdef USE_JPEGAGA_HAM8_TABLE
/* The color table from jpegAGA.
 */
u_char FixedHAM8ColorTable[64 * 3] =
{0, 0, 0, 4, 4, 4, 8, 8, 8, 12, 12, 12,
 16, 16, 16, 20, 20, 20, 24, 24, 24, 28, 28, 28,        /* 16 colors */
 32, 32, 32, 36, 36, 36, 41, 41, 41, 46, 46, 46,
 51, 51, 51, 55, 55, 55, 59, 59, 59, 63, 63, 63,


 17, 17, 39, 17, 17, 55,        /* 13 colors */
 17, 29, 17, 17, 29, 39, 17, 29, 55,
 17, 39, 17, 17, 39, 29, 17, 39, 39, 17, 39, 55,
 17, 55, 17, 17, 55, 39, 17, 55, 39, 17, 55, 55,


 29, 17, 29, 29, 17, 39, 29, 17, 55,    /* 11 colors */
 29, 29, 55,
 29, 39, 17, 29, 39, 29, 29, 39, 55,
 29, 55, 17, 29, 55, 29, 29, 55, 39, 29, 55, 55,


 39, 17, 17, 39, 17, 29, 39, 17, 39, 39, 17, 55,        /* 12 colors */
 39, 29, 17, 39, 29, 29, 39, 29, 55,
 39, 39, 17, 39, 39, 29,
 39, 55, 17, 39, 55, 29,


 55, 17, 17, 55, 17, 29, 55, 17, 39, 55, 17, 55,        /* 13 colors */
 55, 29, 27, 55, 29, 29, 55, 29, 39, 55, 29, 55,
 55, 39, 17, 55, 39, 29, 55, 39, 39,
 55, 55, 17, 55, 55, 29
};
#else
u_char FixedHAM8ColorTable[64 * 3];
#endif /* USE_JPEGAGA_HAM8_TABLE */
u_char FixedHAM6ColorTable[16 * 3];
#endif /* VIDEO_HAM */

u_char ColorTable[64 * 3], *ColorCache = NULL;

#define LOOKUP(p) (PPM_GETR(p) << 16) | (PPM_GETG(p) << 8) | PPM_GETB(p)

    /*
     *  Function Prototypes
     */

void Die(const char *fmt,...) __attribute__((noreturn, format (printf,1,2) ));
static void Warn(const char *fmt,...);
static void SigHandler(int signo) __attribute__((noreturn));
static void VTRequest(int signo) __attribute__((noreturn));
static void Usage(void) __attribute__((noreturn));
static void Version(void);
static void OpenFB(void);
static void SetFBMode(int color);
static void CloseFB(void);
static void Chunky2Planar(u_char chunky[32], u_int32_t * fb);
int ReadImage(FILE * fp, u_int32_t *buffer, int do_histogram);
int main(int argc, char *argv[]);

extern void make_ham6_table(void);
extern void make_ham8_table(void);
extern void make_ham_table_from_histogram(colorhist_vector chv, int maxval,
                                          int colors, int palettesize,
                                          int cutoff_point);
extern struct fb_cmap *make_directcolor_cmap(struct fb_var_screeninfo *var);

extern void EncodeHAM(pixel * pixrow, pixval maxval, u_char * yham,
                      u_int16_t xsize, int do_histogram);

    /*
     *  Print an Error Message and Exit
     */

void Die(const char *fmt,...)
{
  va_list ap;

  fflush(stdout);
  va_start(ap, fmt);
  vfprintf(stderr, fmt, ap);
  va_end(ap);

  CloseFB();

  exit(1);
}

    /*
     *  Print a Warning Message
     */

static void Warn(const char *fmt,...)
{
  va_list ap;

  fflush(stdout);
  va_start(ap, fmt);
  vfprintf(stderr, fmt, ap);
  va_end(ap);
}


    /*
     *  Signal Handler
     */

static void SigHandler(int signo)
{
  signal(signo, SIG_IGN);
  Die("Caught signal %d. Exiting\n", signo);
}


    /*
     *  Handler for the Virtual Terminal Request
     */

static void VTRequest(int signo)
{
  Die("\nVTRequest: Exiting\n");
}

#define min(a, b) ((a) < (b) ? (a) : (b))

    /*
     *  Open the Frame Buffer
     */

static void OpenFB(void)
{
  int i, fd, vtno, colors;
  int devfs = 0;
  struct fb_fix_screeninfo fix;
  struct fb_var_screeninfo var;
  char vtname[50];
  struct vt_stat vts;
  struct vt_mode VT;

#if 0
  if (geteuid())
    Die("%s must be suid root\n", ProgramName);
  
  if ((fd = open("/dev/tty0", O_WRONLY, 0)) < 0)
    {
      devfs = 1;
      if ((fd = open("/dev/vc/0", O_WRONLY, 0)) < 0)
	Die("Cannot open /dev/tty0 or /dev/vc/0: %s\n", strerror(errno));
    }
  
  if (VC == -1)
    {
      if (ioctl(fd, VT_OPENQRY, &vtno) < 0 || vtno == -1)
	Die("Cannot find a free VT\n");
    }
  else
    vtno = VC;
  
  close(fd);

  if (devfs == 1)
    sprintf(vtname, "/dev/vc/%d", vtno);
  else
    sprintf(vtname, "/dev/tty%d", vtno);  /* /dev/tty1-64 */
#endif  
  if (!FrameBufferName && !(FrameBufferName = getenv("FRAMEBUFFER")))
    {
      if (devfs == 1)
	FrameBufferName = "/dev/fb/0";
      else
	FrameBufferName = "/dev/fb0";
    }
#if 0
  if ((ConsoleFd = open(vtname, O_RDWR | O_NDELAY, 0)) < 0)
    Die("Cannot open %s: %s\n", vtname, strerror(errno));
  /*
   * Linux doesn't switch to an active vt after the last close of a vt,
   * so we do this ourselves by remembering which is active now.
   */
  if (ioctl(ConsoleFd, VT_GETSTATE, &vts) == 0)
    ActiveVT = vts.v_active;
  /*
   * Detach from the controlling tty to avoid char loss
   */
  if ((i = open("/dev/tty", O_RDWR)) >= 0) {
    ioctl(i, TIOCNOTTY, 0);
    close(i);
  }

  /*
   * now get the VT
   */

#ifndef RDB_DEBUG /* RDB Not needed for debugging */
  if (ioctl(ConsoleFd, VT_ACTIVATE, vtno) != 0)
    Warn("ioctl VT_ACTIVATE: %s\n", strerror(errno));
  if (ioctl(ConsoleFd, VT_WAITACTIVE, vtno) != 0)
    Warn("ioctl VT_WAITACTIVE: %s\n", strerror(errno));

  if (ioctl(ConsoleFd, VT_GETMODE, &VT) < 0)
    Die("ioctl VT_GETMODE: %s\n", strerror(errno));
  signal(SIGUSR1, VTRequest);
  VT.mode = VT_PROCESS;
  VT.relsig = SIGUSR1;
  VT.acqsig = SIGUSR1;
  if (ioctl(ConsoleFd, VT_SETMODE, &VT) < 0)
    Die("ioctl VT_SETMODE: %s\n", strerror(errno));
#endif /* RDB */

  /*
   *  Switch to Graphics Mode and Open the Frame Buffer Device
   */

#ifndef RDB_DEBUG /* RDB Not needed for debugging */
  if (ioctl(ConsoleFd, KDSETMODE, KD_GRAPHICS) < 0)
    Die("ioctl KDSETMODE KD_GRAPHICS: %s\n", strerror(errno));
#endif /* RDB */
#endif
  if ((FrameBufferFD = open(FrameBufferName, O_RDWR)) < 0)
    Die("Cannot open %s: %s\n", FrameBufferName, strerror(errno));
  if (ioctl(FrameBufferFD, FBIOGET_VSCREENINFO, &var))
    Die("ioctl FBIOGET_VSCREENINFO: %s\n", strerror(errno));

#ifdef VIDEO_HAM
#ifndef USE_JPEGAGA_HAM8_TABLE
  make_ham8_table();
#endif
  make_ham6_table();

  ColorCache = malloc(CACHESIZE);
  if (!ColorCache)
    Die("colorcache: %s\n", strerror(errno));
#endif

  var.xres_virtual = var.xres;
  var.yres_virtual = var.yres;
  var.xoffset = 0;
  var.yoffset = 0;
  var.nonstd = 0;
  if(depth)
    var.bits_per_pixel = depth;
  var.vmode &= ~FB_VMODE_YWRAP;
  if (ioctl(FrameBufferFD, FBIOPUT_VSCREENINFO, &var)) {
#ifdef VIDEO_HAM
    var.xres_virtual = var.xres;
    var.yres_virtual = var.yres;
    var.xoffset = 0;
    var.yoffset = 0;
    var.nonstd = FB_NONSTD_HAM;
    if(depth)
      var.bits_per_pixel = depth;
    var.vmode &= ~FB_VMODE_YWRAP;
    if( ioctl(FrameBufferFD, FBIOPUT_VSCREENINFO, &var) ) {
#endif
      if( depth != DEFAULT_DEPTH ) {
        if (ioctl(FrameBufferFD, FBIOGET_VSCREENINFO, &var))
          Die("ioctl FBIOGET_VSCREENINFO: %s\n", strerror(errno));
        
        var.xres_virtual = var.xres;
        var.yres_virtual = var.yres;
        var.xoffset = 0;
        var.yoffset = 0;
        var.nonstd = 0;
        var.bits_per_pixel = depth = DEFAULT_DEPTH;
        var.vmode &= ~FB_VMODE_YWRAP;
        if (ioctl(FrameBufferFD, FBIOPUT_VSCREENINFO, &var))
          Die("ioctl FBIOPUT_VSCREENINFO: %s\n", strerror(errno));
      }
#ifdef VIDEO_HAM
    }
#endif
    else {
      Die("ioctl FBIOPUT_VSCREENINFO: %s\n", strerror(errno));
    }
  }
  if (ioctl(FrameBufferFD, FBIOGET_FSCREENINFO, &fix))
    Die("ioctl FBIOGET_FSCREENINFO: %s\n", strerror(errno));
  DisplayWidth = var.xres;
  DisplayHeight = var.yres;
  depth = var.bits_per_pixel; /* In case it changed */
  visual = fix.visual;

  if( visual != FB_VISUAL_PSEUDOCOLOR &&
      visual != FB_VISUAL_STATIC_PSEUDOCOLOR &&
      visual != FB_VISUAL_TRUECOLOR &&
      visual != FB_VISUAL_DIRECTCOLOR )
    Die("Visual %d not supported (see /usr/include/linux/fb.h).\n", visual);

  if( visual == FB_VISUAL_STATIC_PSEUDOCOLOR ) {
    if( !var.grayscale ) {
      Die("Non-grayscale static pseudocolor visuals not supported.\n");
    }
    grayscale = 1;
    if( verbose ) {
      fprintf(stderr, "Static pseudocolor grayscale display enabled.\n");
    }
  } else if( visual == FB_VISUAL_PSEUDOCOLOR ) {
    colors = 1 << depth; /* 2**depth */
    Gray = malloc(colors * sizeof(*Gray));
    if(!Gray)
      Die("Can't allocate Gray map: %s\n", strerror(errno));
    for (i = 0; i < colors; i++)
      Gray[i] = i * (65535/(colors-1));

    GrayMap.start = 0;
    GrayMap.len = colors;
    GrayMap.red = GrayMap.blue = GrayMap.green = Gray;
    GrayMap.transp = 0;
  }

#ifdef VIDEO_HAM
  hamallowed = HAM_NONE;
  if( !no_ham && !strcmp(fix.id, "Amiga AGA") && (depth == 8) )
    hamallowed = HAM_HAM8;
  else if( !no_ham && !strncmp(fix.id, "Amiga", 5) && (depth == 6) )
    hamallowed = HAM_HAM6;
#endif

  fbtype = fix.type;
  switch (fix.type) {
  case FB_TYPE_VGA_PLANES:
#ifdef VIDEO_VGA16
    if( depth != 4 )
      Die("VGA16 framebuffer is only supported with depth = 4.\n");

    NextLine = LineLength = fix.line_length;
    NextPlane = LineLength * DisplayHeight; /* Actually next color */

    if( ioperm(0x3c0, 0x20, 1) == -1 )
      Die("Can't access VGA registers (ioperm).\n");

    vga16_set_enable_sr (0xf);
    vga16_set_op (0);
    vga16_set_mode (0);
#else
    Die("The vga16 framebuffer organization is not supported by this "
        "binary.\nPlease recompile with VIDEO_VGA16 defined.\n");
#endif
    break;
  case FB_TYPE_PACKED_PIXELS:
#ifdef VIDEO_PACKED_PIXELS
    if (fix.line_length)
      NextLine = LineLength = fix.line_length;
    else
      NextLine = LineLength = (var.xres_virtual * var.bits_per_pixel) / 8;
    NextPlane = 0;
#else
    Die("Packed pixels are not supported by this binary.\n"
        "Please recompile with VIDEO_PACKED_PIXELS defined.\n");
#endif
    break;
  case FB_TYPE_PLANES:
#ifdef VIDEO_PLANES
    if (fix.line_length)
      NextLine = LineLength = fix.line_length;
    else
      NextLine = LineLength = var.xres_virtual >> 3;
    NextPlane = NextLine * var.yres_virtual;
#else
    Die("Non-interleaved planes are not supported by this binary.\n"
        "Please recompile with VIDEO_PLANES defined.\n");
#endif
    break;
  case FB_TYPE_INTERLEAVED_PLANES:
#ifdef VIDEO_INTERLEAVED_PLANES
    if (fix.line_length) {
      NextLine = fix.line_length * var.bits_per_pixel;
      NextPlane = LineLength = fix.line_length;
    } else {
      NextLine = fix.type_aux;
      NextPlane = LineLength = NextLine / var.bits_per_pixel;
    }

    if( NextLine == 2 ) {
#ifndef VIDEO_IPLAN2Px
      Die("Atari interleaved planes are not supported in this binary.\n"
          "Please recompile with VIDEO_IPLAN2Px defined.\n");
#else
      if( depth != 2 && depth != 4 && depth != 8 )
        Die("Atari interleaved planes not supported at depth %d.\n", depth);

      NextLine = LineLength = depth * var.xres_virtual / 8;
      NextPlane = 2;
      PixelSkip = NextPlane * depth;
#endif
    }
    break;
#else
    Die("Interleaved planes are not supported by this binary.\n"
        "Please recompile with VIDEO_INTERLEAVED_PLANES defined.\n");
#endif
#ifdef FB_TYPE_TEXT
  case FB_TYPE_TEXT:
    Die("Text-only framebuffers are not supported.\n");
    break;
#endif
  default:
    Die("Unknown frame buffer type %d\n", fix.type);
    break;
  }
  FrameBufferSize = fix.smem_len;
  FrameBufferBits = (caddr_t) mmap(0, FrameBufferSize, PROT_READ | PROT_WRITE,
                                   MAP_SHARED, FrameBufferFD, 0);
  if (FrameBufferBits == (caddr_t) - 1)
    Die("mmap: %s\n", strerror(errno));

  if (verbose) {
    fprintf(stderr, "Using %s framebuffer mapped at %p (%d)\n", fix.id,
            FrameBufferBits, FrameBufferSize);
    fprintf(stderr, "Depth = %d  LineLength = %d  NextPlane = %d  "
	    "PixelSkip = %d\n", depth, LineLength, NextPlane, PixelSkip);
  }
}


    /*
     *  Set the Color Mode of the Frame Buffer
     */

static void SetFBMode(int color)
{
  struct fb_fix_screeninfo fix;
  struct fb_var_screeninfo var;
  struct fb_cmap *cmap = 0, *acmap = 0;

  if (ioctl(FrameBufferFD, FBIOGET_FSCREENINFO, &fix))
    Die("ioctl FBIOGET_FSCREENINFO: %s\n", strerror(errno));
  if (ioctl(FrameBufferFD, FBIOGET_VSCREENINFO, &var))
    Die("ioctl FBIOGET_VSCREENINFO: %s\n", strerror(errno));

  visual = fix.visual;
  var.nonstd = 0;
  if (visual == FB_VISUAL_DIRECTCOLOR)
    acmap = cmap = make_directcolor_cmap(&var);
  else if (visual == FB_VISUAL_PSEUDOCOLOR) {
    if (color == COLOR_MODE_TRUE) {
#ifdef VIDEO_HAM
      if( hamallowed != HAM_NONE ) {
        var.nonstd = FB_NONSTD_HAM;
        cmap = &HAMColorMap;
      } else {
        Die("You need DIRECTCOLOR or TRUECOLOR support for images with more "
            "than %d colors.\n"
            "If you are using an Amiga, make sure you have set the correct "
            "color depth for\n"
            "viewing (i.e. 6 for HAM or 8 for HAM8).\n", 1 << depth);
      }
#else
      Die("You need DIRECTCOLOR or TRUECOLOR support for images with more "
          "than %d colors.\n", 1 << depth);
#endif
    } else if (color == COLOR_MODE_NORMAL) {
      cmap = &PlanarColorMap;
    } else if (color == COLOR_MODE_GRAY) {
      cmap = &GrayMap;
    } else {
      Die("Invalid color mode: %d\n", color);
    }
  }

  if (ioctl(FrameBufferFD, FBIOPUT_VSCREENINFO, &var))
    Die("ioctl FBIOPUT_VSCREENINFO: %s\n", strerror(errno));
  if( cmap ) {
    if (ioctl(FrameBufferFD, FBIOPUTCMAP, cmap))
      Die("ioctl FBIOPUTCMAP: %s\n", strerror(errno));
  }

  if( acmap ) { /* Allocated colormap */
    if( acmap->red ) free(acmap->red);
    if( acmap->green ) free(acmap->green);
    if( acmap->blue ) free(acmap->blue);
    free(acmap);
  }
}


    /*
     *  Close the Frame Buffer
     */

static void CloseFB(void)
{
  struct vt_mode VT;

  if (FrameBufferBits != (caddr_t) -1) {
    munmap(FrameBufferBits, FrameBufferSize);
    FrameBufferBits = (caddr_t) -1;
  }
  if (FrameBufferFD != -1) {
    close(FrameBufferFD);
    FrameBufferFD = -1;
  }
  if (ConsoleFd) {
    ioctl(ConsoleFd, KDSETMODE, KD_TEXT);
    if (ioctl(ConsoleFd, VT_GETMODE, &VT) != -1) {
      VT.mode = VT_AUTO;
      ioctl(ConsoleFd, VT_SETMODE, &VT);
    }
    if (ActiveVT >= 0) {
      ioctl(ConsoleFd, VT_ACTIVATE, ActiveVT);
      ActiveVT = -1;
    }
    close(ConsoleFd);
    ConsoleFd = 0;
  }
}

/* Convert a 32 byte chunk to planes if needed */
#define CHUNKYTOPLANAR(ch, fb) {\
    Chunky2Planar(ch, fb); \
    if(NextPlane) fb++; \
    else fb += depth; \
  }

#ifndef VIDEO_ANY_PLANES
#undef CHUNKYTOPLANAR
#define CHUNKYTOPLANAR(ch, fb) { \
    Chunky2Planar(ch, fb); \
    fb += depth; \
  }
#endif

#ifndef VIDEO_PACKED_PIXELS
#undef CHUNKYTOPLANAR
#define CHUNKYTOPLANAR(ch, fb) Chunky2Planar(ch, fb++)
#endif

static inline pixval SillyRand(pixval threshold, pixval max)
{
  pixval x;

  x = rand() / (RAND_MAX/max);

  return (x < threshold) ? 1 : 0;
}

static inline pixval do_random_dither(pixel p, pixval maxval, pixval newmax)
{
  div_t divm;
  
  divm = div((int)(PPM_LUMIN(p)*newmax), maxval);
  return divm.quot + SillyRand(divm.rem, maxval);
}

void ConvertPGMRow(pixel * pixelrow, pixval maxval, int cols, int shift,
                   u_int32_t * fb, int dummy, struct fb_var_screeninfo *d2)
{
  pixel p;
  int i = 0, colors;
  u_char chunky[32], pix;

  bzero(chunky, 32);
  for (; i < 32*(shift/32); i+=32)
    CHUNKYTOPLANAR(chunky, fb);
  
  colors = (1 << depth) - 1;
  if( random_dither && depth <= 8) {
    for (i=shift; i < cols + shift; i++) {
      pix = do_random_dither(pixelrow[i-shift], maxval, colors);

      chunky[i % 32] = pix;
      if (i % 32 == 31)
        CHUNKYTOPLANAR(chunky, fb);
    }
  } else {
    for (i=shift; i < cols + shift; i++) {
      PPM_DEPTH(p, pixelrow[i - shift], maxval, colors);
      chunky[i % 32] = (u_char)PPM_LUMIN(p);

      if (i % 32 == 31)
        CHUNKYTOPLANAR(chunky, fb);
    }
  }

  for(; i < DisplayWidth; i++)
  {
    chunky[i % 32] = 0;
    if (i % 32 == 31)
      CHUNKYTOPLANAR(chunky, fb);
  }
}

#ifdef VIDEO_VGA16
void ConvertVGA16ColorRow(pixel * pixelrow, pixval maxval, int cols, int shift,
                          u_int32_t * fb, int dummy,
                          struct fb_var_screeninfo *d2)
{
  int colors = 1<<depth, i, j = -1;
  int multiplier = DisplayHeight * LineLength;
  pixel p, prevp;
  u_int32_t look_for;
  char *line = (char *)fb, mask;

  memset(line, 255, LineLength);
  for(i=1; i<colors; i++)
    bzero(&line[i*multiplier], LineLength);

  for(i=shift; i<cols+shift; i++) {
    PPM_DEPTH(p, pixelrow[i - shift], maxval, 255);
    if(j < 0 || !PPM_EQUAL(prevp,p)) {
      look_for = LOOKUP(p);
      
      for(j=0; j < PlanarColors; j++)
        if(PlanarLookup[j] == look_for) break;

      if(j == PlanarColors) {
        printf("Weirdness in color lookup.\n");
      }

      prevp = p;
    }

    if(j) {
      mask = (0x80 >> i%8);
      line[j*multiplier + i/8] |= mask;
      line[i/8] &= ~mask;
    }
  }
}

void ConvertVGA16GrayRow(pixel * pixelrow, pixval maxval, int cols, int shift,
                         u_int32_t * fb, int dummy,
                         struct fb_var_screeninfo *d2)
{
  int colors, i;
  int multiplier = NextPlane;
  pixel p;
  char *line=(char *)fb, pix, mask;

  colors = (1<<depth) - 1;

  memset(line, 255, LineLength);
  for(i=1; i<=colors; i++)
    bzero(&line[i*multiplier], LineLength);

  if( random_dither ) {
    for(i=shift; i<cols+shift; i++) {
      pix = do_random_dither(pixelrow[i - shift], maxval, colors);

      if(pix) {
        mask = (0x80 >> i%8);
        line[pix*multiplier + i/8] |= mask;
        line[i/8] &= ~mask;
      }
    }
  } else {
    for(i=shift; i<cols+shift; i++) {
      PPM_DEPTH(p, pixelrow[i - shift], maxval, colors);
      pix = (char)PPM_LUMIN(p);
      
      if(pix) {
        mask = (0x80 >> i%8);
        line[pix*multiplier + i/8] |= mask;
        line[i/8] &= ~mask;
      }
    }
  }
}
#endif

void ConvertPlanarPPMRow(pixel * pixelrow, pixval maxval, int cols, int shift,
                         u_int32_t * fb, int dummy,
                         struct fb_var_screeninfo *d2)
{
  pixel p, prevp;
  int i = 0, j = -1;
  u_int32_t look_for;
  u_char chunky[32];

  bzero(chunky, 32);
  for (; i < 32*(shift/32); i+=32)
    CHUNKYTOPLANAR(chunky, fb);
  
  /*  colors = (1 << depth) - 1; */

  for (i=shift; i < cols + shift; i++) {
    PPM_DEPTH(p, pixelrow[i - shift], maxval, 255);
    if(j < 0 || !PPM_EQUAL(prevp,p)) {
      look_for = LOOKUP(p);
      
      for(j=0; j < PlanarColors; j++) {
        if(PlanarLookup[j] == look_for) break;
      }

      if(j == PlanarColors) {
        fprintf(stderr, "Problem: %x\n", look_for);
        printf("Weirdness in color lookup.\n");
      }

      prevp = p;
    }

    chunky[i%32] = j;

    if (i % 32 == 31)
      CHUNKYTOPLANAR(chunky, fb);
  }

  for(; i < DisplayWidth; i++) {
    chunky[i % 32] = 0;
    if (i % 32 == 31)
      CHUNKYTOPLANAR(chunky, fb);
  }
}

#ifdef VIDEO_HAM
void ConvertHAMPPMRow(pixel * pixelrow, pixval maxval, int cols, int shift,
                      u_int32_t * fb, int do_histogram,
                      struct fb_var_screeninfo *dummy)
{
  int i;
  u_char *chunky;

  chunky = calloc(DisplayWidth, 1);
  if (!chunky)
    Die("chunky: %s\n", strerror(errno));

  EncodeHAM(pixelrow, maxval, &chunky[shift], cols, do_histogram);

  for (i = 0; i < DisplayWidth; i += 32)
    CHUNKYTOPLANAR(&chunky[i], fb);

  free(chunky);
}
#endif

#define PPM_MULTIDEPTH(newp,p,oldmaxval,redmaxval,greenmaxval,bluemaxval) \
    PPM_ASSIGN( (newp), \
        ( (int) PPM_GETR(p) * (redmaxval) + (oldmaxval) / 2 ) / (oldmaxval), \
        ( (int) PPM_GETG(p) * (greenmaxval) + (oldmaxval) / 2 ) / (oldmaxval),\
        ( (int) PPM_GETB(p) * (bluemaxval) + (oldmaxval) / 2 ) / (oldmaxval) )

/* Assumptions: bpp % 8   = 0 (e.g. 8, 16, 24, 32 bpp)
 *              bpp      <= 32
 *              msb_right = 0
 */
void ConvertTruePPMRow(pixel * pixelrow, pixval maxval, int cols, int shift,
                       u_int32_t * fb, int do_histogram,
                       struct fb_var_screeninfo *var)
{
  pixel p;
  int i, bytes_per_pixel, maxred, maxgreen, maxblue;
  u_char *dst;

  bytes_per_pixel = (var->bits_per_pixel + 7)/8;

  maxred = (1 << var->red.length) - 1;
  maxgreen = (1 << var->green.length) - 1;
  maxblue = (1 << var->blue.length) - 1;

  dst = (u_char *)fb;
  bzero(dst, LineLength); /* Clear row */
  dst = &dst[bytes_per_pixel * shift];

  for(i=0; i<cols; i++) {
    u_int32_t pix; /* change to u_int64_t for up to 64 bpp */
    int j;
    
    PPM_MULTIDEPTH(p, pixelrow[i], maxval, maxred, maxgreen, maxblue);
    
    pix = (PPM_GETR(p) << var->red.offset |
           PPM_GETG(p) << var->green.offset |
           PPM_GETB(p) << var->blue.offset);
    
#if __BYTE_ORDER == __LITTLE_ENDIAN
    for( j = 0; j < bytes_per_pixel; ++j )
#else
    for( j = bytes_per_pixel-1; j >= 0; --j )
#endif
      *dst++ = (pix >> (j*8)) & 0xff;
  }
}

void ConvertTrueGrayRow(pixel * pixelrow, pixval maxval, int cols,
                        int shift, u_int32_t * fb, int do_histogram,
                        struct fb_var_screeninfo *var)
{
  pixel p;
  int i, bytes_per_pixel, maxred, maxgreen, maxblue;
  u_char *dst;

  bytes_per_pixel = (var->bits_per_pixel + 7)/8;

  maxred = (1 << var->red.length) - 1;
  maxgreen = (1 << var->green.length) - 1;
  maxblue = (1 << var->blue.length) - 1;

  dst = (u_char *)fb;
  bzero(dst, LineLength); /* Clear row */
  dst = &dst[bytes_per_pixel * shift];

  for(i=0; i<cols; i++) {
    u_int32_t pix; /* change to u_int64_t for up to 64 bpp */
    int j;
    pixval p2;
    pixel tmp;
    
    p2 = (pixval)PPM_LUMIN(pixelrow[i]);
    PPM_ASSIGN(tmp, p2, p2, p2);
    
    if( random_dither ) {
      pixval r, g, b;
      
      r = do_random_dither(tmp, maxval, maxred);
      g = do_random_dither(tmp, maxval, maxgreen);
      b = do_random_dither(tmp, maxval, maxblue);

      pix = (r << var->red.offset |
             g << var->green.offset |
             b << var->blue.offset);
    } else {
      PPM_MULTIDEPTH(p, tmp, maxval, maxred, maxgreen, maxblue);
      pix = (PPM_GETR(p) << var->red.offset |
             PPM_GETG(p) << var->green.offset |
             PPM_GETB(p) << var->blue.offset);
    }
    
#if __BYTE_ORDER == __LITTLE_ENDIAN
    for( j = 0; j < bytes_per_pixel; ++j )
#else
    for( j = bytes_per_pixel-1; j >= 0; --j )
#endif
      *dst++ = (pix >> (j*8)) & 0xff;
  }
}

/* Actually this fills color 0, but who's counting? */
void FillBlackRow(u_int32_t * fb)
{
  int i;

#ifdef VIDEO_VGA16
  if( fbtype == FB_TYPE_VGA_PLANES ) {
    char *line = (char *)fb;

    memset(line, 255, LineLength); /* "Black" is color zero */
    for(i = 1; i < (1<<depth); i++)
      bzero(&line[NextPlane*i], LineLength);
    return;
  }
#endif

#ifdef VIDEO_PACKED_PIXELS
#ifdef VIDEO_ANY_PLANES
  if(!NextPlane)
#endif
    bzero(fb, LineLength);
#endif

#ifdef VIDEO_ANY_PLANES
#ifdef VIDEO_PACKED_PIXELS
  if(NextPlane)
#endif
    for (i = 0; i < depth; i++) {
      bzero(fb, LineLength);
      fb += NextPlane / sizeof(u_int32_t);
    }
#endif
}

void DisplayImage(u_char * buffer, int color)
{
  u_char *fb = (u_char *)FrameBufferBits;
  u_int i, j;

  SetFBMode(color);

#ifdef VIDEO_VGA16
  if( fbtype == FB_TYPE_VGA_PLANES ) {
    int color, r, c;
    int colors = 1<<depth;
    char *b, *brow, mask;

    for(r=0; r < DisplayHeight; r++) {
      brow = buffer + r*LineLength;
      for(color=0; color < colors; color++) {
        b = brow + color*NextPlane;
        vga16_set_color(color);
        for(c=0; c < LineLength; c++) {
          mask = *(b++);
          if(mask) {
            vga16_select_mask();
            vga16_set_mask(mask);
            vga16_rmw(fb + r*LineLength + c);
          }
        }
      }
    }

    return;
  }
#endif

  if( NextPlane < NextLine ) {
    /* Interleaved planes or Packed pixels: Spam away! */
    if(NextPlane)
      memcpy(fb, buffer, depth * DisplayHeight * LineLength);
    else
      memcpy(fb, buffer, DisplayHeight * LineLength);
  } else {
    /* Avoid color flashing on normal planes */
    for (i = 0; i < DisplayHeight; i++) {
      u_char *src = buffer;
      u_char *dst = fb;
      
      for (j = 0; j < depth; j++) {
        memcpy(dst, src, LineLength);
        src += NextPlane;
        dst += NextPlane;
      }
      
      buffer += NextLine;
      fb += NextLine;
    }
  }
}

void Chunky2Planar(u_char chunky[32], u_int32_t * fb)
{
#ifdef VIDEO_PACKED_PIXELS
#ifdef VIDEO_ANY_PLANES
  if(!NextPlane)
#endif
  {
    char *fb2 = (char *)fb;
    int i;

    switch(depth) {
    case 8:
      memcpy(fb, chunky, 32);
      return;
    case 4: /* Are these endianness things correct? */
      for(i=0; i<32; i+=2) {
#if __BYTE_ORDER == __BIG_ENDIAN
        *fb2++ = (chunky[i] << 4) | chunky[i+1];
#else
        *fb2++ = (chunky[i+1] << 4) | chunky[i];
#endif
      }
      return;
    case 2:
      for(i=0; i<32; i+=4) {
#if __BYTE_ORDER == __BIG_ENDIAN
        *fb2++ = ((chunky[i] << 6) | (chunky[i+1] << 4) |
                  (chunky[i+2] << 2) | chunky[i+3]);
#elif __BYTE_ORDER == __LITTLE_ENDIAN
        *fb2++ = ((chunky[i+3] << 6) | (chunky[i+2] << 4) |
                  (chunky[i+1] << 2) | chunky[i]);
#else
# error No support for PDP-endianness
#endif
      }
      return;
    case 1:
      for(i=0; i<32; i+=8) {
#if __BYTE_ORDER == __BIG_ENDIAN
        *fb2++ = ((chunky[i] << 7) | (chunky[i+1] << 6) |
                  (chunky[i+2] << 5) | (chunky[i+3] << 4) |
                  (chunky[i+4] << 3) | (chunky[i+5] << 2) |
                  (chunky[i+6] << 1) | chunky[i+7]);
#elif __BYTE_ORDER == __LITTLE_ENDIAN
        *fb2++ = ((chunky[i+7] << 7) | (chunky[i+6] << 6) |
                  (chunky[i+5] << 5) | (chunky[i+4] << 4) |
                  (chunky[i+3] << 3) | (chunky[i+2] << 2) |
                  (chunky[i+1] << 1) | chunky[i]);
#else
# error No support for PDP-endianness
#endif
      }
      return;
    default:
      Die("Chunky pixels with depth other than 1, 2, 4, 8 not supported.\n");
    }
  }
#endif /* VIDEO_PACKED_PIXELS */
#ifdef VIDEO_ANY_PLANES
#ifdef VIDEO_IPLAN2Px
  if(PixelSkip) {
    /* Implement iplan2pX modes here */
    u_int16_t *fb2 = (u_int16_t *)fb;
    int i, j;
    u_char mask;
    u_int16_t val, planemask;

    for (j = 0, mask = 1; j < depth; mask <<= 1, j++) {
      val = 0;
      for (i = 0, 
#if __BYTE_ORDER == __BIG_ENDIAN
             planemask = 0x8000; planemask; planemask >>= 1,
#else /* Little/PDP-endian? */
             planemask = 1; planemask; planemask <<= 1,
#endif
             i++) {
        if (chunky[i] & mask)
          val |= planemask;
      }
      *fb2 = val;
      fb2 += NextPlane / sizeof(u_int16_t);
    }
  }
  else
#endif /* VIDEO_IPLAN2pX */
  {
    int i, j;
    u_char mask;
    u_int32_t val, planemask;

    for (j = 0, mask = 1; j < depth; mask <<= 1, j++) {
      val = 0;
      for (i = 0, 
#if __BYTE_ORDER == __BIG_ENDIAN
             planemask = 0x80000000; planemask; planemask >>= 1,
#elif __BYTE_ORDER == __LITTLE_ENDIAN
             planemask = 1; planemask; planemask <<= 1,
#else
#error PDP-endianness not supported.
#endif
             i++) {
        if (chunky[i] & mask)
          val |= planemask;
      }
      *fb = val;
      fb += NextPlane / sizeof(u_int32_t);
    }
  }
#endif
}

static int lumincompare(const void *x, const void *y)
{
  colorhist_vector ch1 = (colorhist_vector) x, ch2 = (colorhist_vector) y;

  return (int)(PPM_LUMIN(ch1->color) - PPM_LUMIN(ch2->color));
}

    /*
     *  Read an Image
     */

int ReadImage(FILE *fp, u_int32_t *buffer, int do_histogram)
{
  int cols, rows, format, imcols, imrows, i, has_color;
  int vertshift, horizshift, use_planar_color = 0;
  int color_mode;
  pixel **pixels;
  pixval maxval;
  void (*func) (pixel *, pixval, int, int, u_int32_t *, int,
                struct fb_var_screeninfo *);
  struct fb_var_screeninfo var;

#ifdef VIDEO_HAM
  int palettesize = (hamallowed == HAM_HAM8 ? 64 : 16);
#endif

  ppm_readppminit(fp, &cols, &rows, &maxval, &format);

  if (verbose)
    fprintf(stderr, "Image size: %d x %d\n", cols, rows);

  pixels = ppm_allocarray( cols, rows );

  if(!pixels)
    Die("ppm_allocarray: %s\n", strerror(errno));
    
  for (i = 0; i < rows; i++) {
    ppm_readppmrow(fp, pixels[i], cols, maxval, format);
  }

  has_color = (PPM_FORMAT_TYPE(format) != PGM_TYPE);

#ifdef VIDEO_HAM
  if(!do_histogram && !grayscale && has_color) {
    if(hamallowed == HAM_HAM8)
      memcpy(ColorTable, FixedHAM8ColorTable, 64 * 3 * sizeof(ColorTable[0]));
    else if(hamallowed == HAM_HAM6)
      memcpy(ColorTable, FixedHAM6ColorTable, 16 * 3 * sizeof(ColorTable[0]));
  }

  HAMColorMap.len = palettesize;
#endif

  if( (visual == FB_VISUAL_PSEUDOCOLOR ||
       visual == FB_VISUAL_STATIC_PSEUDOCOLOR) && depth > 8 ) {
    Die("PSEUDOCOLOR with depth > 8 is not supported.\n");
  }

  if (do_histogram && has_color && !grayscale &&
      (visual == FB_VISUAL_PSEUDOCOLOR) ) {
    colorhist_vector chv = NULL;
    int colors, maxcolors = (1 << depth), chsize;

    for(chsize = 65536; !chv && chsize < 16777216; chsize <<= 1) {
      if( verbose ) {
	fprintf(stderr, "Allocating histogram with %d entries.\n", chsize);
      }
      chv = ppm_computecolorhist(pixels, cols, rows, chsize, &colors);
    }

    if (chv && verbose)
      fprintf(stderr, "Image contains %d colors.\n", colors);

    if (!chv) {
      Warn("Unable to histogram: too many colors (%d)\n", colors);
    } else if (colors <= maxcolors) {
      int offset_color = (colors < maxcolors) ? 1 : 0;
      //int vgacolor[] = { 0, 0x80, 0x8000, 0x8080, 0x800000, 0x800080, 0x808000, 0x808080,
	//		0xC0C0C0, 0xFF, 0xFF00, 0xFFFF, 0xFF0000, 0xFF00FF, 0xFFFF00, 0xFFFFFF };
      int vgacolor[] = { 0, 0xaa, 0xaa00, 0xaaaa, 0xaa0000, 0xaa00aa, 0xaaaa00, 0xaaaaaa,
			0xC0C0C0, 0xFF, 0xFF00, 0xFFFF, 0xFF0000, 0xFF00FF, 0xFFFF00, 0xFFFFFF };
      pixel x;
      
      use_planar_color = 1;

      bzero(PlanarLookup, 256 * sizeof(PlanarLookup[0]));

      /* Sort to put darkest colors at beginning of palette */
      qsort(chv, colors, sizeof(struct colorhist_item), lumincompare);

#if 0
      /* Black background for < maxcolors colors */
      if(offset_color) {
        PlanarRed[0] = PlanarGreen[0] = PlanarBlue[0] = 0;
        PPM_ASSIGN(x, 0, 0, 0);
        PlanarLookup[0] = LOOKUP(x);
      }
#endif
      /* force a vga palette */
      offset_color = 16;
      for (i = 0; i < 16; i++) {
        PlanarRed[i]   = (vgacolor[i] >> 16) * 256;
        PlanarGreen[i] = ((vgacolor[i] >> 8) & 255) *256;
        PlanarBlue[i]  = (vgacolor[i] & 255) * 256;
        PPM_ASSIGN(x, PlanarRed[i], PlanarGreen[i], PlanarBlue[i]);
        PlanarLookup[i] = LOOKUP(x);
        
      }

      PlanarColors = colors + offset_color;
      for (i = offset_color; i < PlanarColors; i++) {
        PPM_DEPTH(x, chv[i-offset_color].color, maxval, 255);

        PlanarRed[i]   = PPM_GETR(x) * (65535/255);
        PlanarGreen[i] = PPM_GETG(x) * (65535/255);
        PlanarBlue[i]  = PPM_GETB(x) * (65535/255);

        PlanarLookup[i] = LOOKUP(x);
      }
    }
#ifdef VIDEO_HAM
    else if( hamallowed != HAM_NONE ) {
      int using_cutoff = cutoff;
      
      if(!using_cutoff) {
        using_cutoff = (cols * rows)/10000;

        if(verbose) {
          fprintf(stderr, "Using cutoff %d\n", using_cutoff);
        }
      }

      make_ham_table_from_histogram(chv, maxval, colors, palettesize,
                                    using_cutoff);
    }
#endif
    else {
      Die("Too many colors in image: %d\n", colors);
    }

    if(chv) ppm_freecolorhist(chv);
  }

  imcols = min(cols, DisplayWidth);
  imrows = min(rows, DisplayHeight);

#ifdef VIDEO_HAM
  if( hamallowed != HAM_NONE && has_color && !grayscale ) {
    int ps, j;
    
    bzero(ColorCache, CACHESIZE);

    ps = HAMColorMap.len - 1;
    for (i = 0, j = 0; j < HAMColorMap.len; i += 3, j++) {
      u_int32_t offset;
      u_int32_t r, g, b;
      
      b = (int)ColorTable[i] * (65535 / ps);
      r = (int)ColorTable[i + 1] * (65535 / ps);
      g = (int)ColorTable[i + 2] * (65535 / ps);
      
#ifdef DEBUG
      if(verbose) {
	fprintf(stderr, "%2d: r: %04x g: %04x b: %04x\n", j, r, g, b);
      }
#endif

      HAMRed[j]   = r;
      HAMGreen[j] = g;
      HAMBlue[j]  = b;

      /* Pre-cache colors in the color table
       * Note that the table is always in 6 bits per gun mode.
       */
      offset = ((ColorTable[i] << 12) | (ColorTable[i+1] << 6) |
		(ColorTable[i+2]));
      ColorCache[offset] = j;
    }
  }
#endif

#ifdef VIDEO_VGA16
  if( fbtype == FB_TYPE_VGA_PLANES ) {
    func = ((grayscale || !has_color) ? ConvertVGA16GrayRow :
                                        ConvertVGA16ColorRow);
  } else {
#endif
    if( grayscale || !has_color )
      func = ( (visual == FB_VISUAL_PSEUDOCOLOR ||
                visual == FB_VISUAL_STATIC_PSEUDOCOLOR) ?
               ConvertPGMRow : ConvertTrueGrayRow );
    else if( use_planar_color )
    func = ConvertPlanarPPMRow;
#ifdef VIDEO_HAM
    else if( hamallowed )
      func = ConvertHAMPPMRow;
#endif
    else
      func = ConvertTruePPMRow;
#ifdef VIDEO_VGA16
  }
#endif

  if (center) {
    horizshift = (DisplayWidth - imcols) / 2;
    vertshift = (DisplayHeight - imrows) / 2;
  } else {
    horizshift = vertshift = 0;
  }

  if (ioctl(FrameBufferFD, FBIOGET_VSCREENINFO, &var))
    Die("ioctl FBIOGET_VSCREENINFO: %s\n", strerror(errno));

  for (i = 0; i < vertshift; i++) {
    FillBlackRow(buffer);
    buffer += NextLine / sizeof(u_int32_t);
  }
  
  for (i = 0; i < imrows; i++) {
    func(pixels[i], maxval, imcols, horizshift, buffer, do_histogram, &var);
    buffer += NextLine / sizeof(u_int32_t);
  }

  for (i = imrows + vertshift; i < DisplayHeight; i++) {
    FillBlackRow(buffer);
    buffer += NextLine / sizeof(u_int32_t);
  }

#ifdef DEBUG
  if(verbose)
    fprintf(stderr, "Final buffer location: %p\n", buffer);
#endif

  ppm_freearray(pixels, rows);

  if( use_planar_color )
    color_mode = COLOR_MODE_NORMAL;
  else if( has_color && !grayscale )
    color_mode = COLOR_MODE_TRUE;
  else
    color_mode = COLOR_MODE_GRAY;

  return color_mode;
}


    /*
     *  Print the Usage Template and Exit
     */

static void Usage(void)
{
  Version();
  Die("\nUsage: %s [options] <filenames | --stdin>\n\n"
      "Valid options are:\n"
      "    -h, --help             : Display this usage information and exit\n"
      "    -V, --version          : Display the version and exit\n"
      "    -v, --verbose          : Display information about the image(s)\n"
      "    -c, --center, --centre : Center image within display\n"
      "    -w, --delay=N          : Set how long to wait after each image\n"
      "    -d, --depth=N          : Color depth (bits per pixel)\n"
      "    -g, --grayscale,       : Force grayscale\n"
      "        --greyscale\n"
      "    -r, --random-dither    : Use random dithering for grayscale\n"
      "    -s, --stdin            : Use standard input instead of files\n"
      "    -f, --framebuffer=X    : Specify framebuffer device to use\n"
      "    -C, --virtual-console  : Specify virtual console to use\n\n"
      "Advanced Options (only relevant for Amiga HAM modes):\n"
      "    -n, --no-histogram     : Use the default palette instead of\n"
      "                             calculating one.\n"
      "    -H, --no-ham           : Don't use HAM, even if available.\n"
      "    -x, --cutoff=N         : Ignore colors that appear less than N "
      "times\n",
      ProgramName);
}

static void Version(void)
{
  fprintf(stderr, "ppmtofb "VERSION" - "
          "(C) 1996 Geert Uytterhoeven and (C) 1996-2000 Chris Lawrence\n"
          "Maintained by Chris Lawrence <lawrencc@debian.org>\n"
          "Read "COPYING" for your license and lack of warranty.\n");
}

int main(int argc, char *argv[])
{
  FILE *fp = 0;
  int res, first = 1, do_histogram = 1, use_stdin = 0, allocwidth, allocsize;
  time_t start = 0;
  char *buffer, **Files;
  int c = 0;

  poptContext optCon;
  struct poptOption options[] = {
    { "help", 'h', 0, NULL, 'h' },
    { "version", 'V', 0, NULL, 'V' },
    { "verbose", 'v', 0, NULL, 'v' },
    { "center", 'c', 0, NULL, 'c' },
    { "centre", 'c', 0, NULL, 'c' },
    { "delay", 'w', POPT_ARG_INT, &delay, 0 },
    { "depth", 'd', POPT_ARG_INT, &depth, 0 },
    { "bpp", 'd', POPT_ARG_INT, &depth, 0 },
    { "cutoff", 'x', POPT_ARG_INT, &cutoff, 0 },
    { "grayscale", 'g', 0, NULL, 'g' },
    { "greyscale", 'g', 0, NULL, 'g' },
    { "random-dither", 'r', 0, NULL, 'r' },
    { "frame-buffer", 'f', POPT_ARG_STRING, &FrameBufferName, 0 },
    { "framebuffer", 'f', POPT_ARG_STRING, &FrameBufferName, 0 },
    { "virtual-console", 'C', POPT_ARG_INT, &VC, 0},
    { "no-histogram", 'n', 0, NULL, 'n' },
    { "no-ham", 'H', 0, NULL, 'H' },
    { "stdin", 's', 0, NULL, 's' },
    { NULL, 0, 0, NULL, 0 }
  };

  ProgramName = argv[0];

  optCon = poptGetContext("ppmtofb", argc, (const char **)argv, options, 0);
  poptReadDefaultConfig(optCon, 0);

  while ((c = poptGetNextOpt(optCon)) >= 0) {
    switch (c) {
    case 'h':
      Usage();
      return 0;
    case 'V':
      Version();
      return 0;
    case 'n':
      do_histogram = 0;
      break;
    case 'v':
      verbose = 1;
      break;
    case 'c':
      center = 1;
      break;
    case 'g':
      grayscale = 1;
      break;
    case 's':
      use_stdin = 1;
      break;
    case 'H':
      no_ham = 1;
      break;
    case 'r':
      random_dither = 1;
      break;
    }
  }
  
  if( c < -1 ) {
    Die("%s: %s\n", poptBadOption(optCon, POPT_BADOPTION_NOALIAS),
        poptStrerror(c));
  }

  Files = (char **)poptGetArgs(optCon);

  if ((!Files || !Files[0]) && !use_stdin) {
    Die("You must specify at least one file to view or the --stdin switch.\n"
        "For help, use %s --help\n", ProgramName);
  }

#ifndef RDB_DEBUG /* RDB Not needed for debugging */
  signal(SIGSEGV, SigHandler);
  signal(SIGILL, SigHandler);
  signal(SIGFPE, SigHandler);
  signal(SIGBUS, SigHandler);
  signal(SIGXCPU, SigHandler);
  signal(SIGXFSZ, SigHandler);
  signal(SIGALRM, SigHandler);
#endif /* RDB */

  /* Seed random number generator */
  srand(time(NULL));

  OpenFB();

  if (use_stdin)
    fp = stdin;

#ifdef VIDEO_VGA16
  if( fbtype == FB_TYPE_VGA_PLANES ) {
    allocsize = LineLength * DisplayHeight * (1<<depth);
  } else {
#endif
    /* Allocate memory in 64-byte chunks.  This seems to be Important for
     * some reason.
     */
    allocwidth = DisplayWidth * ((depth+7) / 8);
    allocwidth += (64 - allocwidth) % 64;
    
    allocsize = allocwidth * DisplayHeight;
#ifdef VIDEO_VGA16
  }
#endif

  buffer = malloc(allocsize);
  if(!buffer)
    Die("buffer: %s\n", strerror(errno));
  
#ifdef DEBUG
  if(verbose)
    fprintf(stderr, "Allocated %d byte buffer at %p\n", allocsize, buffer);
#endif

  if (use_stdin)
    c = getc(fp);

  for(; (use_stdin ? (c != EOF) : (int)*Files); Files += (use_stdin ? 0 : 1)) {
    if (use_stdin) {
      ungetc(c, fp);
    } else {
      /* This setreuid business supposedly restricts non-superusers from
       * accessing files not their own. [see setreuid(3)]
       */
      setreuid(geteuid(), getuid());
      fp = fopen(*Files, "rb");
      setreuid(geteuid(), getuid());
      
      if(!fp) {
        Warn("Can't open file `%s'\n", *Files);
        continue;
      }
    }

    if(verbose && !use_stdin)
      fprintf(stderr, "Reading '%s'\n", *Files);

    res = ReadImage(fp, (u_int32_t *) buffer, do_histogram);
    if (res) {
      if (first) {
        first = 0;
      } else {
        /* Wait any remaining number of seconds in our delay period */
        time_t tmp;

        if(start) {
          int remainder = (int)(difftime(time(0), start)+0.5);
          
          tmp = (remainder < delay ? delay - remainder : 0);
        } else {
          tmp = delay;
        }

        if (tmp) {
          if(verbose)
            fprintf(stderr, "Sleeping %ld seconds (for previous image).\n",
                    tmp);
          sleep(tmp);
        } else {
          if (verbose)
            fprintf(stderr, "Not sleeping.\n");
        }
      }

      DisplayImage(buffer, res);
      start = time(0);
    }

    if (use_stdin) {
      c = getc(fp);
    } else {
      fclose(fp);
      fp = 0;
    }
  }

  if(verbose)
    fprintf(stderr, "Sleeping %d seconds for final image.\n", delay);

//  sleep(delay);
  CloseFB();

  return (0);
}
