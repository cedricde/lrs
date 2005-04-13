<?php
# one of the module config files
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


$FILE = "/etc/webmin/backuppc/config";
$assocTable = lib_read_file($FILE);

# environnement variable for the directory which contain templates
$chemin_templates="./templates";

# where is the menu ?
$chemin_menu="./Menus";

# some color
$mauve_fonce="#9999ff";
$mauve_clair="#e2d1f9";
$gris_clair="#e2e2e2";
$vert="#35b4c3";
$vert_clair="#97bcc9";

?>
