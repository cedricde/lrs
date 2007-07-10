/* VGA16 support
 * (C) 1999 Ben Pfaff and Chris Lawrence
 * Subject to the terms of the GNU General Public License
 *
 * Actually included by ppmtofb.c
 */

#ifdef VIDEO_VGA16
#include <sys/io.h>

/* Program the Set/Reset Register for drawing in color COLOR for write
   mode 0. */
static inline void vga16_set_color (int c)
{
  outb (0, 0x3ce);
  outb (c, 0x3cf);
}

/* Set the Enable Set/Reset Register. */
static inline void vga16_set_enable_sr (int mask)
{
  outb (1, 0x3ce);
  outb (mask, 0x3cf);
}

/* Select the Bit Mask Register on the Graphics Controller. */
static inline void vga16_select_mask (void)
{
  outb (8, 0x3ce);
}

/* Program the Bit Mask Register to affect only the pixels selected in
   MASK.  The Bit Mask Register must already have been selected with
   select_mask (). */
static inline void vga16_set_mask (int mask)
{
  outb (mask, 0x3cf);
}

/* Set the Data Rotate Register.  Bits 0-2 are rotate count, bits 3-4
   are logical operation (0=NOP, 1=AND, 2=OR, 3=XOR). */
static inline void vga16_set_op (int op)
{
  outb (3, 0x3ce);
  outb (op, 0x3cf);
}

/* Set the Memory Plane Write Enable register. */
static inline void vga16_set_write_planes (int mask)
{
  outb (2, 0x3c4);
  outb (mask, 0x3c5);
}

/* Set the Read Map Select register. */
static inline void vga16_set_read_plane (int plane)
{
  outb (4, 0x3ce);
  outb (plane, 0x3cf);
}

/* Set the Graphics Mode Register.  The write mode is in bits 0-1, the
   read mode is in bit 3. */
static inline void vga16_set_mode (int mode)
{
  outb (5, 0x3ce);
  outb (mode, 0x3cf);
}

/* Read-modify-write the specified memory byte. */
static inline void vga16_rmw (volatile char *p)
{
  *p |= 1;
}
#endif
