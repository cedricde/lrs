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

//
// Warning !!! Touch only if you KNOW WHAT YOU DO
// Make a back up !
// Check your PHP syntax
//

// 
// This var is used by the function 'verif_nom_fichier'
// block php file sending, which would interpreted by the web server
//
$GLOBALS['regex_fichier'] = '.csv$';

//
// All directory will have this permissions
//
$GLOBALS['mode_dossier_default'] = 0777;

// 
// List of directoy to create
// Come from documentation
// ADDED: V3  suupport
$GLOBALS['liste_dossierv2'] = 'AccessLogs Application Drivers Graphics LogicalDrives Network Results';
$GLOBALS['liste_dossierv3'] = 'Acces Controllers Drives Icons Inputs Memories Modems Monitors Networks Ports Registry Slots Softwares Sounds Storages Videos';
$GLOBALS['liste_dossier_commun'] = 'BIOS Bios Hardware Printers Info/Garantie Info/Situation_Geo ocs';

//
// Message to display when the page has no data
// and add more informations or advertisments
//
$GLOBALS['message_page_vide'] = "<html><body>La page est bien accessible.</body></html>";
$GLOBALS['error_mac'] = "Two computers with the same name but different MAC Address OR wrong MAC Address in the client's file";
?>
