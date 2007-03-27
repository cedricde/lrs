<?php
/*
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

/**
 * @file common.inc.php
 * This file provide some basic common functions.
 */

require_once(dirname(__FILE__) . "/debug.inc.php"); /**< Use debug function */
require_once(dirname(__FILE__) . "/../../lbs_common/lbs_common.php");
require_once(dirname(__FILE__) . "/tmpl.inc.php");

/**
 * Reverse strrchr
 *
 * Like PHP function 'Strrchr' but return everything
 * in $haystack up to the LAST instance of $needle.
 *
 * @param $haystack The string where to search
 * @param $needle The carachere to seach
 * @return the resultat string.
 * If $needle isn't find in $haystack, $haystack is return.
 *
 */
function strrrchr($haystack, $needle)
{
	$pos = strrpos($haystack, $needle);
	if ($pos === false) {
		return ($haystack);
	}

	return (substr($haystack, 0, $pos + 1));
}

/**
 * Ereg in Array
 *
 * It's the Ereg PHP function but it search
 * $pattern in all string of array $haystack.
 *
 * @param $pattern The $pattern to search
 * @param $haystack The array of string where to search
 * @return The TOTAL string of the string that match the pattern.
 * If nothing match, return FALSE.
 *
 */
function LSC_arrayEreg($pattern, $haystack)
{
	for ($i = 0; $i < count($haystack); $i++) {
		if (ereg($pattern, $haystack[$i])) {
		      return ($i);
		}
	}
	
	return (FALSE);
} 

/**
 * fnmatch in Array
 *
 * Check if $haystack match one or more pattern of array $ar_pattern
 *
 * @param $ar_pattern The array of patterns.
 * @param $haystack The string to match.
 * @return 0 if nothing match, else return 1
 *
 */
function LSC_arrayFnmatch($ar_pattern, $haystack)
{
	foreach ($ar_pattern as $pattern) {
		if (fnmatch($pattern, $haystack)) {
			return (1);
		}
	}
	
	return (0);
}

/**
 * Time function
 *
 * This function is used to calcul the time
 * that takes a PHP page to be generared.
 *
 * @return The actual time in msec.
 */
function LSC_time() 
{
	list($msec, $sec) = explode(' ', microtime());
	return ((float) $sec + (float) $msec) * 1000000;
}

/**
 * Return HTML relative path to root module directory
 *
 * @return string relative path value to root module directory
 *
 * <p><strong>Example :</strong></p>
 *
 * <p>I'm in "http://foo.org/lsc/ui_test/empty_page.cgi". 
 * If I call relative_path_to_root_module_directory function
 * I get "../" string.</p>
 */
function relative_path_to_root_module_directory()
{
	$absolute_root_module_directory = realpath(dirname(__FILE__) . "/../");
	debug(9, 
		sprintf(
			"%s - absolute_root_module_directory is : %s",
			__FUNCTION__,
			$absolute_root_module_directory
		)
	);
	$script_sub_directory = str_replace($absolute_root_module_directory, "", realpath(dirname($_SERVER['SCRIPT_FILENAME'])));
	debug(9, 
		sprintf(
			"%s - script_sub_directory is : %s",
			__FUNCTION__,
			$script_sub_directory
		)
	);

	$return_val = "";
	foreach(split("/",$script_sub_directory) as $i) {
		if ($i != "") $return_val .= "../";
	}

	debug(9, 
		sprintf(
			"%s - return value is : %s",
			__FUNCTION__,
			$return_val
		)
	);
	
	return $return_val; 
}
?>
