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
 * Append command_history
 */
function lsc_command_history_append($id_command_on_host, $date, $state, $stdout, $stderr = "")
{
	global $database, $DEBUG;
	
	if (!isset($database)) {
		$database = new LSC_DB();
		if ($DEBUG >= 1) $database->Debug = true;
	}
	
	$query = sprintf(
"
INSERT INTO
	%s
	(
	id_command_on_host,
	date,
	state,
	stdout,
	stderr
	)

VALUES
	(
	\"%s\",
	\"%s\",
	\"%s\",
	\"%s\",
	\"%s\"
	)
",
	COMMANDS_HISTORY_TABLE,
	$id_command_on_host,
	$date,
	$state,
	addslashes($stdout),
	addslashes($stderr)
	);

	$database->query($query);
}

?>
