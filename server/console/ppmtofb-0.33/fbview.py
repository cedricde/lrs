#!/usr/bin/python
#
# fbview.py - Views `any' picture using ppmtofb
# by Chris Lawrence <lawrencc@debian.org>
#
# This is free software, subject to the terms of the GNU General
# Public License.  See /usr/share/common-licenses/GPL on a Debian GNU/Linux
# system for your lack of warranty and specific licensing terms.
#
# . No filter is used for PPM and PGM images (duh)
# . 'djpeg' is used for JFIF images
# . You can use 'pngtopnm' if you've compiled it for PNG images
# . NetPBM utils are used for GIF and ILBM images
# . 'convert' (from ImageMagick) is used for everything else
#
# To use this, you must have the NetPBM package.
# To view JFIF images, you'll need 'djpeg' from the Independent JPEG Group
# To view PNG images, you'll need 'pngtoppm' from the PNG developers
# To view odd image formats, you'll need 'convert' from the ImageMagick
#   or you'll need to change identify_file to identify them and convert_file
#   to convert them to pgm or ppm.
#
# More recent changes:
# . Reindented
# . Fix all sorts of stupid bugs.
# . Separate JPEG options for grayscale and color.
# . Added BMP, PCX, TIFF, XPM support via NetPBM.
#
# Changes since third release: (Sep 26)
# . Using file extensions in identify_file (if there's an extension,
#     assume it is valid)
#
# Changes since second release: (Sep 21)
# . Using new stdin pipe in ppmtoagafb for better throughput
# . Doesn't scale if the image will fit on the display without scaling
#
# Changes since first release: (Sep 16)
# . Added automagic scaling of image (via pnmscale)
#   Set WIDTH and HEIGHT equal to the size of your default console
# . Fixed filtering for PPM/PGM images
# . Added filter for pbm->pgm

# Defaults - can be overridden in /etc/fbview.conf or ~/.fbview.conf
VERBOSE   =   1 # Set to 1 for informative messages
NOCLEANUP =   0 # Set to 1 to keep the generated files around

DEPTH     =   8
GRAYSCALE =   0
CENTER    =   1
DELAY     =   5
WIDTH     = 640
HEIGHT    = 480

# Use 0 if you have a TRUECOLOR/DIRECTCOLOR visual or
# an AGA Amiga; other values enable automatic quantizing
MAXCOLORS =   0

# Any options to djpeg go here
# '-fast' might be nice here for faster previews
JPEG_GRAYSCALE_OPTS = '-pnm -fast'
JPEG_COLOR_OPTS     = '-pnm'

# e.g. FRAMEBUFFER = '/dev/fb0'
FRAMEBUFFER  = ''

import sys, os, time, string, popen2, getopt

known_types = ('ILBM', 'PPM', 'PGM', 'PBM', 'PNG', 'GIF', 'JFIF', 'TIFF',
               'BMP', 'PCX', 'XPM')

def debug_message(msg):
    if VERBOSE:
        print msg

def identify_file(filename):
    fields = string.splitfields(filename,'.')
    if len(fields) >= 2:
        # Our filename has at least one extension
        ext = string.lower(fields[-1])

        debug_message('Using extension '+ext+' for identity.')

        if ext in ('jpg', 'jpeg'):
            return 'JFIF'
        elif ext in ('ilbm', 'lbm', 'iff'):
            return 'ILBM'
        elif ext in ('tiff', 'tif'):
            return 'TIFF'

        ext = string.upper(ext)
        if ext in known_types: return ext

    fd = os.popen("file '%s'" % filename)
    typestring = fd.readline()
    fd.close()

    typestring = string.strip(typestring)
    debug_message("file returns: "+typestring)

    for type in known_types:
        if string.find(typestring, type) != -1:
            return type

    # The rest of these, we run 'convert' on so don't bother
    # identifying them
    return 'Unidentified'

def convert_file(filename, grayscale=0):
    type = identify_file(filename)
    debug_message('Detected type: '+type)

    if type == 'PGM' or type == 'PBM':
        return ('', type)

    if (type == 'PPM' or type == 'PNM') and not grayscale:
        return ('', type)

    # The extension tells convert to create a PPM file
    # NB: Python does have a tempfile module, but it doesn't guarantee
    #     any extension.
    tmpnam = '/tmp/fbview.%d.%d.ppm' % (time.time(), os.getpid())

    if grayscale:
        opts = JPEG_GRAYSCALE_OPTS
    else:
        opts = JPEG_COLOR_OPTS

    if (type == 'PPM' or type == 'PNM') and grayscale:
        os.system("ppmtopgm '%s' > %s" % (filename, tmpnam))
    elif type == 'JFIF':
        os.system("djpeg %s '%s' > %s" % (opts, filename, tmpnam))
    elif type in ('GIF', 'PNG', 'TIFF'):
        os.system("%stopnm '%s' > %s" % (string.lower(type), filename,
                                         tmpnam) )
    elif type in ('ILBM', 'BMP', 'PCX', 'XPM'):
        os.system("%stoppm '%s' > %s" % (string.lower(type), filename,
                                         tmpnam) )
    else:
        os.system("convert '%s' %s" % (filename, tmpnam))

    return (tmpnam, type)

def scale_file(oldtmpnam, width, height):
    fp = os.popen('pnmfile %s' % oldtmpnam)
    info = string.split(fp.read())
    fp.close()

    imgwidth, imgheight = int(info[3]), int(info[5])

    if imgwidth <= width and imgheight <= height:
        debug_message('Not scaling %s: %d x %d' % (oldtmpnam, imgwidth,
                                                   imgheight))
        x = open(oldtmpnam)
    else:
        debug_message('Scaling %s (from %d x %d)' % (oldtmpnam, imgwidth,
                                                     imgheight))
        x = os.popen('pnmscale -xysize %d %d %s' % (width, height,
                                                    oldtmpnam))
    return x

def clean_up_converted_file(tmpnam):
    debug_message('Removing '+tmpnam)

    if not NOCLEANUP:
        os.unlink(tmpnam)

def show_file(filename, fp, grayscale=0, width=640, height=480,
              maxcolors=None):
    (tmpfile, type) = convert_file(filename, grayscale)

    if tmpfile:
        x = scale_file(tmpfile, width, height)
    else:
        x = scale_file(filename, width, height)

    if maxcolors and not grayscale:
        debug_message("Quantizing to %d colors..." % maxcolors)
        r, w = popen2.popen2("ppmquant -floyd %d" % maxcolors)
        w.write(x.read())
        w.close()
        x = r

    txt = x.read()
    if txt:
        debug_message("Displaying image")
        fp.write(txt)
        fp.flush()
    x.close()

    if tmpfile:
        clean_up_converted_file(tmpfile)

def help():
    print 'fbview - (C) 1997-2000 Chris Lawrence'
    print 'Usage: fbview [-g] [-c] [-C] [-d depth] [-w delay] [-v] [-q] files'
    print
    print 'See the man page for long forms of these options.'
    sys.exit(1)

def rcfile_parser(file):
    if not os.path.exists(file): return

    fp = open(file)
    for line in fp.readlines():
        line = string.strip(line)
        if not line or line[0] == '#':
            continue

        bits = string.split(line, ' ', 1)
        if len(bits) < 2:
            print 'Invalid configuration line (must have at least two parts):'
            print line
            continue

        cmd = string.upper(bits[0])
        if not cmd in globals().keys():
            print 'Can\'t set '+cmd+'.'
            continue

        arg = eval(bits[1])
        cmdtype = eval("type("+cmd+")")
        if type(arg) != cmdtype:
            print 'Argument to '+cmd+' must be of '+str(cmdtype)
            continue

        exec 'global '+cmd+'; '+cmd+' = '+repr(arg)

    fp.close()

def main():
    rcfile_parser('/etc/fbview.conf')
    rcfile_parser(os.path.expanduser("~/.fbview.conf"))

    grayscale = GRAYSCALE
    delay = DELAY
    depth = DEPTH
    center = CENTER
    width, height = WIDTH, HEIGHT
    maxcolors = MAXCOLORS
    framebuffer = FRAMEBUFFER
    ret = ppmtofb_verbose = 0

    if not framebuffer and os.environ.has_key('FRAMEBUFFER'):
        framebuffer = os.environ['FRAMEBUFFER']

    try:
        optlist, args = getopt.getopt(sys.argv[1:], 'hgd:w:CcvqW:H:m:Vf:',
                                      ['help', 'grayscale', 'greyscale',
                                       'depth=', 'bpp=',
                                       'delay=', 'pause=',
                                       'colour', 'color',
                                       'center', 'centre',
                                       'no-center', 'no-centre',
                                       'verbose', 'quiet',
                                       'width=', 'height=',
                                       'ppmtofb-verbose', 'framebuffer=',
                                       'maxcolors=', 'maxcolours='])
    except getopt.error, x:
        print x
        print 'Use "fbview --help" for assistance.'
        return 1

    for option in optlist:
        if option[0] in ('-h', '--help'):
            help()
        elif option[0] in ('-d', '--depth', '--bpp'):
            depth = int(option[1])
        elif option[0] in ('-m', '--maxcolors', '--maxcolours'):
            maxcolors = int(option[1])
        elif option[0] in ('-w', '--delay', '--pause'):
            delay = int(option[1])
        elif option[0] in ('-g', '--grayscale', '--greyscale'):
            grayscale = 1
        elif option[0] in ('-C', '--color', '--colour'):
            grayscale = 0
        elif option[0] in ('-c', '--center', '--centre'):
            center = 1
        elif option[0] == '--no-center':
            center = 0
        elif option[0] in ('-v', '--verbose'):
            global VERBOSE
            VERBOSE = 1
        elif option[0] in ('-q', '--quiet'):
            global VERBOSE
            VERBOSE = 0
        elif option[0] in ('-V', '--ppmtofb-verbose'):
            ppmtofb_verbose = 1
        elif option[0] in ('-W', '--width'):
            width = int(option[1])
        elif option[0] in ('-H', '--height'):
            height = int(option[1])
        elif option[0] in ('-f', '--framebuffer'):
            framebuffer = option[1]
        else:
            pass

    if not args:
        print 'No images to display.'
        return 1

    cmdline = '--delay=%d --depth=%d ' % (delay, depth)
    if grayscale: cmdline = cmdline + '--grayscale --random-dither '
    if center: cmdline = cmdline + '--center '
    if ppmtofb_verbose: cmdline = cmdline + '--verbose '
    if framebuffer: cmdline = cmdline + '--framebuffer='+framebuffer+' '

    fp = None
    for x in args:
        if os.path.exists(x):
            if not fp:
                fp = os.popen('ppmtofb '+cmdline+' --stdin', 'w')
                if not fp:
                    print 'fbview: unable to open a pipe to ppmtofb.'
                    return 1
            
            show_file(x, fp, grayscale, width, height, maxcolors)
        else:
            print 'File does not exist:', x
            ret = 1

    if fp:
        fp.flush()
        fp.close()

    if ret:
        print 'fbview: not completely successful'

    return ret

if __name__ == '__main__':
    sys.exit(main())
