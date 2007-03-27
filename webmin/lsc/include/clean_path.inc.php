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
 * @file clean_path
 *
 * This script content only clean_path function
 */

/**
 * This function resolves references to '/./', '/../' and extra '/' characters 
 * in the input path and returns the canonicalized pathname.
 * Security feature: Also remove any .. in the final path
 *
 * @param $path (string) path input
 * @return (string) path clean
 *
 * <strong>Example :</strong>
 *
 * clean_path("..//./../dir4//./dir5/dir6/..//dir7/") => "../../dir4/dir5/dir7/" => "/dir4/dir5/dir7/"
 *
 * @warning : this function replace realpath php function because this function
 * don't access to filesystem to resolv symbolic links...
 */
function clean_path($path) {
	$result = array();
	$pathA = explode('/', $path);
	if (!$pathA[0]) {
		$result[] = '';
	}

	foreach ($pathA AS $key => $dir) {
		if ($dir == '..') {
			if (end($result) == '..') {
				$result[] = '..';
			} elseif (!array_pop($result)) {
				$result[] = '..';
			}
		} elseif ($dir && $dir != '.') {
			$result[] = trim($dir);
		}
	}
	if (!end($pathA)) {
		$result[] = '';
	}

	$securepath = implode('/', $result);
	$securepath = ereg_replace("[\.][\.]+/?", "", $securepath);

	return $securepath;
}

?>
