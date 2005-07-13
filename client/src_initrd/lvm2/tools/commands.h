/*
 * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
 * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
 *
 * This file is part of LVM2.
 *
 * This copyrighted material is made available to anyone wishing to use,
 * modify, copy, or redistribute it subject to the terms and conditions
 * of the GNU General Public License v.2.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

/***********  Replace with script?
xx(e2fsadm,
   "Resize logical volume and ext2 filesystem",
   "e2fsadm "
   "[-d|--debug] " "[-h|--help] " "[-n|--nofsck]" "\n"
   "\t{[-l|--extents] [+|-]LogicalExtentsNumber |" "\n"
   "\t [-L|--size] [+|-]LogicalVolumeSize[kKmMgGtT]}" "\n"
   "\t[-t|--test] "  "\n"
   "\t[-v|--verbose] "  "\n"
   "\t[--version] " "\n"
   "\tLogicalVolumePath" "\n",

    extents_ARG, size_ARG, nofsck_ARG, test_ARG)
*********/


xx(vgscan,
   "Search for all volume groups",
   "vgscan "
   "\t[-d|--debug]\n"
   "\t[-h|--help]\n"
   "\t[--ignorelockingfailure]\n"
   "\t[--mknodes]\n"
   "\t[-P|--partial] " "\n"
   "\t[-v|--verbose]\n" 
   "\t[--version]" "\n",

   ignorelockingfailure_ARG, mknodes_ARG, partial_ARG)

xx(vgchange,
   "Change volume group attributes",
   "vgchange" "\n"
   "\t[-A|--autobackup {y|n}] " "\n"
   "\t[--alloc AllocationPolicy] " "\n"
   "\t[-P|--partial] " "\n"
   "\t[-d|--debug] " "\n"
   "\t[-h|--help] " "\n"
   "\t[--ignorelockingfailure]\n"
   "\t[-t|--test]" "\n"
   "\t[-u|--uuid] " "\n"
   "\t[-v|--verbose] " "\n"
   "\t[--version]" "\n"
   "\t{-a|--available [e|l]{y|n}  |" "\n"
   "\t -x|--resizeable {y|n} |" "\n"
   "\t -l|--logicalvolume MaxLogicalVolumes |" "\n"
   "\t --addtag Tag |\n"
   "\t --deltag Tag}\n"
   "\t[VolumeGroupName...]\n",

   addtag_ARG, alloc_ARG, allocation_ARG, autobackup_ARG, available_ARG,
   deltag_ARG, ignorelockingfailure_ARG, logicalvolume_ARG, partial_ARG,
   resizeable_ARG, resizable_ARG, test_ARG, uuid_ARG)


xx(version,
   "Display software and driver version information",
   "version\n" )

