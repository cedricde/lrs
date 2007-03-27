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

require_once(dirname(__FILE__) . "/debug.inc.php"); /* Load debug display function */
require_once(dirname(__FILE__) . "/config.inc.php"); /* Set all LSC configurations constants */
require_once(dirname(__FILE__) . "/LSC_DB.inc.php"); /* Load database access class */

/**
 * @file
 *
 * This file implement lock database table function to commands, commands_on_host, commands_history tables
 */

/**
 * Lock table
 *
 * @param table_name
 * @param mode = "READ" or "WRITE"
 *
 * This function lock one database table in READ or WRITE mode
 */
function lsc_lock_table($table_name, $mode)
{
	global $database, $DEBUG;
	
	if (!isset($database)) {
		$database = new LSC_DB();
		if ($DEBUG >= 1) $database->Debug = true;
	}
	
	if (is_array($table_name)) {
		$query = "LOCK TABLES ";
		$separator = "";
		foreach($table_name as $t) {
			$query .= $separator.$t." ".$mode;
			$separator = ", ";
		}
	} else {
		$query = sprintf(
"
LOCK TABLES %s %s
",
		$table_name,
		$mode
		);
	} 
	
	$database->query($query);
}

/**
 * Unlock tables
 */
function lsc_unlock_tables()
{
	global $database, $DEBUG;
	
	if (!isset($database)) {
		$database = new LSC_DB();
		if ($DEBUG >= 1) $database->Debug = true;
	}
	
	$database->query("UNLOCK TABLES");
}
?>
