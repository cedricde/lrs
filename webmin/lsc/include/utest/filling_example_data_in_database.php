<?php
include(dirname(__FILE__)."/../LSC_DB.inc.php");

$database = new LSC_DB();

function add_command($target, $title)
{
	global $database;
	
	$query="
INSERT INTO
	commands

(
target,
title,
date_created,
start_date,
end_date,
dispatched
)
VALUES
(
	\"".$target."\",
	\"".$title."\",
	\"".date("Y-m-d H:i:s")."\",
	\"0000-00-00 00:00:00\",
	\"0000-00-00 00:00:00\",
	\"YES\"
)
";
	$database->query($query);
	
	$database->query("SELECT LAST_INSERT_ID()");
	$database->next_record();
	
	return $database->f("last_insert_id()");
}

function add_command_on_host($id_command, $host)
{
	global $database;
	
	$state=array(
		"upload_in_progress",
		"upload_done",
		"upload_failed",
		"execution_in_progress",
		"execution_done",
		"execution_failed",
		"delete_in_progress",
		"delete_done",
		"delete_failed",
		"not_reachable",
		"done",
		"pause",
		"stop",
		"scheduled"
	);
	
	$state2=array(
		"TODO",
		"IGNORED",
		"WORK_IN_PROGRESS",
		"FAILED"
	);
	
	$query="
INSERT INTO
	commands_on_host

(
id_command,
host,
current_state,
uploaded,
executed,
deleted
)

VALUES
(
	\"".$id_command."\",
	\"".$host."\",
	\"".$state[rand(0, 13)]."\",
	\"".$state2[rand(0,3)]."\",
	\"".$state2[rand(0,3)]."\",
	\"".$state2[rand(0,3)]."\"
)";
	$database->query($query);
	
	$database->query("SELECT LAST_INSERT_ID()");
	$database->next_record();
	
	return $database->f("last_insert_id()");
}

for($i=0;$i<100;$i++) {
	$id_command = add_command("target".$i, "titre".$i);
	for($j=0;$j<rand(1, 20);$j++) {
		add_command_on_host($id_command, "host".$i.$j);
	}
}
?>
