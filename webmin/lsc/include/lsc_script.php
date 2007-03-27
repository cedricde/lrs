<?php
/*
 * Linbox Rescue Server - Secure Remote Control Module
 * Copyright (C) 2005	Linbox FAS
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA	02111-1307, USA.
 */

function lsc_script_list_file() 
{
	$result = array();

	$d = dir("./lsc.script/");
	while( false != ($f = $d->read() ) ) {
		if ( 
			( $f != ".." ) &&
			( $f != "." ) &&
			( is_file( "./lsc.script/" . $f ) ) &&
			( ereg ("\.lsc$", $f) )
		) {
			$result[$f] = lsc_script_read_file( $f );
			/*array_push(
				$result,
				lsc_script_read_file( $f )
			);*/
		}
	}

	return $result;
}

function lsc_script_read_file($filename)
{
	$fullfilename = "./lsc.script/" . $filename;
	
	$result = lib_read_file($fullfilename);
	
	$result[ "fullfilename" ] = $fullfilename;
	$result[ "filename" ] = $filename;
	$result[ "titleen" ] = $result[ "title" ];
	$result[ "titleuk" ] = $result[ "title" ];
	
	return $result;
}

?>
