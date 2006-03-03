<?php
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

# Like Strchr but sart the search a the end of hatstack
# different of strrchr
function strrrchr($haystack, $needle)
{
   $pos = strrpos($haystack, $needle);
   if ($pos === false)
       return ($haystack);
   return (substr($haystack, 0, $pos + 1));
}

# like ereg but search it in a tab
function LSC_arrayEreg($pattern, $haystack)
{
  for ($i = 0; $i < count($haystack); $i++)
    if (ereg($pattern, $haystack[$i]))
      return ($i);
  return (false);
} 

# use to calcul the executed time
function LSC_time() 
{
    list($msec, $sec) = explode(' ', microtime());
    return ((float) $sec + (float) $msec) * 1000000;
}

?>
