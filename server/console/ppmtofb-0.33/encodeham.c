/* HAM8 encoding, based on the jpegAGA HAM8 encoding
 * Originally by Günther Röhrich
 * Converted to C by Chris Lawrence <lawrencc@debian.org>
 * 
 * © Copyright 1996-99 by Chris Lawrence
 *
 * This file is subject to the terms and conditions of the GNU General Public
 * License.  See the file COPYING in the main directory of the Linux
 * distribution for more details.
 */

#ifndef VIDEO_HAM
int encodeham8; /* Declare something so things don't act too weird */
#else
#undef HISTOGRAM_WEIRDNESS

#include <sys/types.h>
#include <stdlib.h>
#include <string.h>
#include <ppm.h>

extern void Die(const char *fmt,...) __attribute__((noreturn));
extern u_char ColorTable[64 * 3];
extern u_char *ColorCache;
extern int depth;

static u_int16_t compute_error(u_char orig[3], u_char chosen[3]);
void EncodeHAM(pixel * pixrow, pixval maxval, u_char * yham, u_int16_t xsize,
               int do_histogram);

static inline u_int16_t square(u_int16_t x)
{
  return x*x;
}

static u_int16_t compute_error(u_char orig[3], u_char chosen[3])
{
  u_int16_t ret, x;

  x = orig[0] - chosen[0];
  ret = square(x);
  x = orig[1] - chosen[1];
  ret += square(x);
  x = orig[2] - chosen[2];
  ret += square(x);

  return ret;
}

#define HAM_ENTRIES (1 << (depth-2))  /* 2^(depth-2) */
#define HAM_COLORS  (HAM_ENTRIES - 1) /* 2^(depth-2) - 1 */

static inline char map_ham(char ham, char value)
{
  if( depth == 8 ) {
    return (value << 2) | ham;
  } else {
    return (ham << (depth-2)) | value;
  }
}

void EncodeHAM(pixel *pixrow, pixval maxval, u_char *pos, u_int16_t xsize,
               int do_histogram)
{
  u_char orig_cols[3], left[3], cache, *finham;
  u_char best_color = 0, colcount = 0, ham_offset, tmp, tmp2, change_val;
  u_int32_t CacheOffset, offset;
  u_int16_t err, min_error;
  int i;

  /* Force choosing a color for the first pixel */
  left[0] = left[1] = left[2] = 255;

  finham = (pos + xsize);
  while( pos < finham ) {
    pixel p;

    PPM_DEPTH(p, (*pixrow), maxval, HAM_COLORS);
    pixrow++;

    orig_cols[0] = PPM_GETB(p);
    orig_cols[1] = PPM_GETR(p);
    orig_cols[2] = PPM_GETG(p);

    if( left[0] == orig_cols[0] &&
        left[1] == orig_cols[1] &&
        left[2] == orig_cols[2] ) {
      /* This pixel is identical to the previous one */
      ham_offset = colcount;
      colcount = (colcount + 1) % 3;

      left[ham_offset] = orig_cols[ham_offset];
      *(pos++) = map_ham(ham_offset+1, orig_cols[ham_offset]);
    } else {
      offset = (orig_cols[1] << 12) | (orig_cols[2] << 6) | orig_cols[0];
      cache = ColorCache[offset];
      if (!cache) { /* No cached color: find index of best color in palette */
        CacheOffset = offset;
        best_color = offset = 0;
        min_error = 3*square(HAM_ENTRIES);

        do {
          err = compute_error(orig_cols, &ColorTable[offset]);

          if (err < min_error) {
            min_error = err;
            best_color = offset;
          }

          offset += 3;
        } while (err > 0 && offset < (3 * HAM_ENTRIES));

        ColorCache[CacheOffset] = best_color;
      } else { /* There is a cached color */
#ifdef HISTOGRAM_WEIRDNESS
        if (!do_histogram) {
          *(pos++) = map_ham(0, cache/3);
          left[0] = ColorTable[cache];
          left[1] = ColorTable[cache+1];
          left[2] = ColorTable[cache+2];
          continue;
        }
#endif
        best_color = cache;
        min_error = compute_error(orig_cols, &ColorTable[best_color]);
      }

      tmp2 = abs(orig_cols[0] - left[0]);
      change_val = orig_cols[0];
      ham_offset = 0;

      for(i=1; i<3; i++) {
        tmp = abs(orig_cols[i] - left[i]);
        if( tmp > tmp2 ) {
          change_val = orig_cols[i];
          ham_offset = i;
          tmp2 = tmp;
        }
      }

      left[ham_offset] = change_val;
      err = compute_error(orig_cols, left);

      if (min_error >= err) {
        /* Hold-and-Modify pixel to the left */
        *(pos++) = map_ham(ham_offset+1, change_val);
      } else { /* Use palette entry */
        *(pos++) = map_ham(0, best_color/3);

        left[0] = ColorTable[best_color];
        left[1] = ColorTable[best_color+1];
        left[2] = ColorTable[best_color+2];
      }
    }
  }

  return;
}
#endif
