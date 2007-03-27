#!/var/lib/lrs/php -q
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

/*
 * @file This file send lsc mail rapport
 *
 * It use commands_history table to build the daily rapport.
 *
 */
include_once(dirname(__FILE__) . "/include/LSC_DB.inc.php");

/**
 * Initialise rapport data structure
 */
$rapport = array(
	"success" => array(),		// Array content array("title_command" => "...", "hostname" => "...")
	"errors" => array(), 		// Array content array("title_command" => "...", "hostname" => "...")
	"not_reachable" => array() 	// Array content array("title_command" => "...", "hostname" => "...")	
);


$database = new LSC_DB();

/**
 * Get previous day
 */
$yesterday = getdate(time() - 60 * 60 * 24); // Current timestamp - 1 day

$previous_day = $yesterday[year] . "-" . $yesterday[mon] . "-" . $yesterday[mday];

/**
 * Get commands history data
 */
$query="
SELECT DISTINCT
	C.title,
	B.host,
	B.current_state
FROM
	".COMMANDS_HISTORY_TABLE." AS A,
	".COMMANDS_ON_HOST_TABLE." AS B,
	".COMMANDS_TABLE." AS C
WHERE
	date LIKE \"".$previous_day."%\" AND
	(
		B.current_state=\"done\" OR
		B.current_state=\"not_reachable\" OR
		B.current_state=\"upload_failed\" OR
		B.current_state=\"execution_failed\" OR
		B.current_state=\"delete_failed\" OR
		B.current_state=\"inventory_failed\"
	) AND
	A.id_command_on_host = B.id_command_on_host AND
	B.id_command = C.id_command
";
$database->query($query);

if ($database->num_rows() == 0) {
	print("Rapport is empty\n");
	exit(0);
}

/**
 * Build rapport structure
 */
while($database->next_record()) {
	if ($database->f("current_state") == "done") {
		array_push(
			$rapport["success"],
			array(
				"title_command" => $database->f("title"), 
				"hostname" => $database->f("host")
			)
		);
	} elseif ($database->f("current_state") == "not_reachable") {
		array_push(
			$rapport["not_reachable"],
			array(
				"title_command" => $database->f("title"), 
				"hostname" => $database->f("host")
			)
		);
	} else {
		array_push(
			$rapport["errors"],
			array(
				"title_command" => $database->f("title"),
				"hostname" => $database->f("host")
			)
		);
	}
}

$mail_subject = "[LRS][LSC] Linbox Secure Control daily rapport (".$yesterday[year]."-".$yesterday[mon]."-".$yesterday[mday].")";
$mail_body = "
Number of success commands : ".count($rapport["success"])."
Number of errors commands : ".count($rapport["errors"])."
Number of hosts not reachable : ".count($rapport["not_reachable"])."
";

if (count($rapport["success"])) {
	$mail_body .= "
	
Success commands list :
=======================

";

	foreach($rapport["success"] as $row) {
		$mail_body.="Command \"".$row["title_command"]."\" on \"".$row["hostname"]."\"\n";
	}
}

if (count($rapport["errors"])) {
	$mail_body .= "
	
Errors commands list :
======================

";

	foreach($rapport["errors"] as $row) {
		$mail_body.="Command \"".$row["title_command"]."\" on \"".$row["hostname"]."\"\n";
	}
}

if (count($rapport["not_reachable"])) {
	$mail_body .= "
	
Not reachable commands list :
======================

";

	foreach($rapport["errors"] as $row) {
		$mail_body.="Command \"".$row["title_command"]."\" on \"".$row["hostname"]."\"\n";
	}
}

print("Subject : " . $mail_subject . "\n");
print("Mail body : ". $mail_body);

mail("lsc@localhost", $mail_subject, $mail_body);
print("Mail rapport is sending to lsc@localhost\n");
?>
