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

/**
 * @file file.inc.php
 * This file content misc function
 */
 
/**
 * This function convert a size in octet to size in KB, MB, or GB
 *
 * @param $size is input size in octet
 * @return size in KB, MB or GB
 */
function LSC_convert_size_to_humain_readable($size)
{
	if ($size >= 1073741824)	{
		$size = round($size / 1073741824 * 100) / 100 . " GB";
	} elseif ($sz >= 1048576) {
		$size = round($size / 1048576 * 100) / 100 . " MB";
	} elseif ($size >= 1024) {
		$size = round($size / 1024 * 100) / 100 . " KB";
	} else	{
		$size = $size . " Bytes";
	}

	return $size;
}



