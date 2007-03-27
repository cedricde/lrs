<?php
require_once(dirname(__FILE__)."/exec.inc.php");
/*
 * Run the inventory on Windows. Do not use the scheduler to avoid trace in the log
 */
function start_inventory($ip, &$command, &$output, &$return_var, &$stdout, &$stderr)
{
	lsc_scp( "root", $ip, "./scripts/run-inventory.bat", "/cygdrive/c/", $output, $return_var, $stdout, $stderr, $scp_command);

	$command = "/cygdrive/c/run-inventory.bat";
	lsc_ssh( "root", $ip, $command, $output, $return_var, $stdout, $stderr);

	$command = "rm /cygdrive/c/run-inventory.bat";
	lsc_ssh( "root", $ip, $command, $output, $return_var, $stdout, $stderr);
}
?>
