/* HAM color table support
 * © Copyright 1999 by Chris Lawrence
 *
 *  This file is subject to the terms and conditions of the GNU General Public
 *  License.  See the file COPYING in the main directory of the Linux
 *  distribution for more details.
 *
 * The algorithms are basically swiped from:
 *
 * ppmtoilbm.c - read a portable pixmap and produce an IFF ILBM file
 *
 * Copyright (C) 1989 by Jef Poskanzer.
 * Modified by Ingo Wilken (Ingo.Wilken@informatik.uni-oldenburg.de)
 */

#include <sys/types.h>
#include <linux/fb.h>
#include <ppm.h>
#include <ppmcmap.h>
#include <string.h>

extern void Die(const char *fmt,...) __attribute__((noreturn));
extern int verbose;

#ifdef VIDEO_HAM
extern u_char FixedHAM6ColorTable[16 * 3];
extern u_char FixedHAM8ColorTable[64 * 3];
extern u_char ColorTable[64 * 3];

/* So we can set these things in RGB order
 * (why the HAM palette controls are bass-ackwards is beyond me)
 */
static inline void set_entry(u_char *table, int i, u_char r, u_char g,
                             u_char b)
{
  table[(i*3)+0] = b;
  table[(i*3)+1] = r;
  table[(i*3)+2] = g;
}

static void make_table(u_char *table, int hamcolors)
{
  int entries, val, colors, i, maxval;
  double step;
  
  maxval = hamcolors - 1;

  /* generate a colormap of 7 "rays" in an RGB color cube:
     r, g, b, r+g, r+b, g+b, r+g+b
     we need one colormap entry for black, so the number of
     entries per ray is (maxcolors-1)/7 */
  
  entries = (hamcolors-1)/7;
  colors = 7*entries+1;
  step = (double)maxval / (double)entries;

  set_entry(table, 0, 0, 0, 0);
  for( i = 1; i <= entries; i++ ) {
    val = (int)((double)i * step);

    set_entry(table,             i, val,   0,   0); /* r */
    set_entry(table, entries   + i,   0, val,   0); /* g */
    set_entry(table, 2*entries + i,   0,   0, val); /* b */
    set_entry(table, 3*entries + i, val, val,   0); /* r+g */
    set_entry(table, 4*entries + i, val,   0, val); /* r+b */
    set_entry(table, 5*entries + i,   0, val, val); /* g+b */
    set_entry(table, 6*entries + i, val, val, val); /* rgb */
  }
}

void make_ham6_table(void)
{
  make_table(FixedHAM6ColorTable, 16);
}

void make_ham8_table(void)
{
  make_table(FixedHAM8ColorTable, 64);
}

static int countcompare(const void *x, const void *y)
{
  colorhist_vector ch1 = (colorhist_vector) x,
    ch2 = (colorhist_vector) y;

  return ch2->value - ch1->value;
}

static int colorcompare(const void *x, const void *y)
{
  u_char *block1 = (u_char *)x, *block2 = (u_char *)y;
  int sum1, sum2;

  sum1 = block1[0]*block1[0] + block1[1]*block1[1] + block1[2]*block1[2];
  sum2 = block2[0]*block2[0] + block2[1]*block2[1] + block2[2]*block2[2];

  return sum1 - sum2;
}

void make_ham_table_from_histogram(colorhist_vector chv, int maxval,
                                   int colors, int palettesize,
				   int cutoff_point)
{
  int col, maxdist, i, dist;
  
  if(verbose)
    fprintf(stderr, "Scaling and sorting histogram...\n");
  
  /* Scale the colors to the color depth
   * (we use 4-bit color for HAM6 and 6-bit color for HAM8)
   */
#if 1
  for(i=0; i<colors; i++) {
    pixel x;

    PPM_DEPTH(x, chv[i].color, maxval, palettesize - 1);
    PPM_ASSIGN(chv[i].color, PPM_GETR(x), PPM_GETG(x), PPM_GETB(x));
  }
#endif

  qsort(chv, colors, sizeof(struct colorhist_item), countcompare);

  if(verbose)
    fprintf(stderr, "Looking for cutoff point...\n");

  if(colors > 1024) {
    for(i=1025; i<colors; i++) {
      if( chv[i].value < cutoff_point )
	colors = i-1;
    }
  }
  
  if( colors > palettesize ) { /* Consolidate colors */
    if(verbose)
      fprintf(stderr, "Selecting HAM colormap with %d entries from "
              "%d colors...\n", palettesize, colors);

    for( maxdist = 1; ; maxdist++ ) {
      for( col = colors-1; col > 0; col-- ) {
        pixval r, g, b;

        r = PPM_GETR(chv[col].color);
        g = PPM_GETG(chv[col].color);
        b = PPM_GETB(chv[col].color);

        /* try to consolidate with an earlier entry */
        for( i = 0; i < col; i++ )
        {
          int tmp;
          pixval ir, ig, ib;

          ir = PPM_GETR(chv[i].color);
          ig = PPM_GETG(chv[i].color);
          ib = PPM_GETB(chv[i].color);

          tmp = ir - r;
          dist = tmp * tmp;
          tmp = ig - g;
          dist += tmp * tmp;
          tmp = ib - b;
          dist += tmp * tmp;

          /* We have a close one... weigh them together and axe this one */
          if( dist <= maxdist ) {
            int sum = chv[i].value + chv[col].value;
            
#ifdef DEBUG
	    fprintf(stderr, "%5d %5d\r", i, col);
#endif

            PPM_ASSIGN(chv[i].color,
                       (ir*chv[i].value + r*chv[col].value + sum/2) / sum,
                       (ig*chv[i].value + g*chv[col].value + sum/2) / sum,
                       (ib*chv[i].value + b*chv[col].value + sum/2) / sum);
            
            /* Bubble this entry up if necessary */
            chv[col] = chv[i];    /* temp store */
            for( tmp = i-1; tmp >= 0 && chv[tmp].value < chv[col].value;
                 tmp-- )
              chv[tmp+1] = chv[tmp];
            chv[tmp+1] = chv[col];

	    colors--;

            /* Shift lower entries up */
	    if( col < colors)
	      memmove(&chv[col], &chv[col+1], (colors-col)*sizeof(chv[0]));

            if( colors <= palettesize )
              goto out;
            break;
          }
        }
      }

#ifdef DEBUG
      if(verbose)
        fprintf(stderr, "\tmaxdist=%d: %d colors left\n", maxdist, colors);
#endif
    }
  }

 out:
  /* Stick them into our color table */
  for(i=0; i < palettesize; i++) {
    pixel x;
    pixval r, g, b;

#if 1
    x = chv[i].color;
#else
    PPM_DEPTH(x, chv[i].color, maxval, (palettesize-1));
#endif

    r = PPM_GETR(x);
    g = PPM_GETG(x);
    b = PPM_GETB(x);

#ifdef DEBUG
    fprintf(stderr, "%2d %02x %02x %02x\n", i, r, g, b);
#endif

    set_entry(ColorTable, i, r, g, b);
  }

  /* Sort the colors so hopefully we get black (or something dark) at 0 */
  qsort(ColorTable, palettesize, 3*sizeof(ColorTable[0]), colorcompare);
}
#endif

struct fb_cmap *make_directcolor_cmap(struct fb_var_screeninfo *var)
{
  /* Hopefully any DIRECTCOLOR device will have a big enough palette
   * to handle mapping the full color depth.
   * e.g. 8 bpp -> 256 entry palette
   *
   * We could handle some sort of gamma here
   */
  int i, cols, rcols, gcols, bcols;
  u_int16_t *red, *green, *blue;
  struct fb_cmap *cmap;
        
  rcols = 1 << var->red.length;
  gcols = 1 << var->green.length;
  bcols = 1 << var->blue.length;
  
  /* Make our palette the length of the deepest color */
  cols = (rcols > gcols ? rcols : gcols);
  cols = (cols > bcols ? cols : bcols);
  
  red = malloc(cols * sizeof(red[0]));
  if(!red) Die("Can't allocate red palette with %d entries.\n", cols);
  for(i=0; i< rcols; i++)
    red[i] = (65535/(rcols-1)) * i;
  
  green = malloc(cols * sizeof(green[0]));
  if(!green) Die("Can't allocate green palette with %d entries.\n", cols);
  for(i=0; i< gcols; i++)
    green[i] = (65535/(gcols-1)) * i;
  
  blue = malloc(cols * sizeof(blue[0]));
  if(!blue) Die("Can't allocate blue palette with %d entries.\n", cols);
  for(i=0; i< bcols; i++)
    blue[i] = (65535/(bcols-1)) * i;
  
  cmap = malloc(sizeof(struct fb_cmap));
  if(!cmap)
    Die("Can't allocate color map\n");
  cmap->start = 0;
  cmap->transp = 0;
  cmap->len = cols;
  cmap->red = red;
  cmap->blue = blue;
  cmap->green = green;
  cmap->transp = NULL;
  
  return cmap;
}
