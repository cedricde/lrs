#!/bin/bash
#
# Linbox Rescue Server
# Copyright (C) 2005  Linbox FAS
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

#mirror=http://belnet.dl.sourceforge.net/sourceforge/ocsinventory/
#mirror=http://heatnet.dl.sourceforge.net/sourceforge/ocsinventory/
mirror=http://flow.dl.sourceforge.net/sourceforge/ocsinventory/

fichier=`wget -q -O - http://sourceforge.net/project/showfiles.php?group_id=58373 |
grep downloads.sourceforge.net/ocsinventory/OCSInventoryVendors- |
sed 's#.*http://#http://#' |
sed 's#?download.*##' |
sed 's#.*/##' | 
sort -rn | 
head -n 1` 

wget  $mirror/$fichier

# man sed !
unzip -q -c $fichier | grep -n '.*' | sed 's/:/;/' > Apps.csv
rm -f $fichier
