<?php
/*
 *
 * Linbox Rescue Server
 * Copyright (C) 2005  Linbox FAS
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 */

require_once(dirname(__FILE__) . "/debug.inc.php"); /* Load debug display function */
require_once(dirname(__FILE__) . "/../../lbs_common/lbs_common.php");
require_once(dirname(__FILE__) . "/path.inc.php");

/**
 * This function return mac adress of host
 *
 * @param full_hostname complete hostname path (string)
 * @return mac adress (string)\n
 * return "" if mac adress is not found.
 *
 * <strong>Full_hostname argument example :</strong>
 * 
 * <ul>
 *	<li>profil1:group1/group2/host1</li>
 *	<li>host2</li>
 *	<li>profil2:host2</li>
 * </ul>
 *
 * This function user ether file
 */
function get_mac_address_from_full_hostname($full_hostname)
{
	$path = new LSC_Path($full_hostname);
	
	$hosts_list = $path->get_hosts_list();
	
	if (count($hosts_list)>0) {
		return $hosts_list[0]["mac"];
	} else {
		return "";
	}
}


?>
