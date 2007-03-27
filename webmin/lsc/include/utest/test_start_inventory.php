<?php
require_once(dirname(__FILE__)."/../inventory.php");

start_inventory("192.168.0.11", $command, $output, $return_var, $stdout, $stderr);
print("command : ".$command."\n");
print("output : ".$output."\n");
print("return_var : ".$return_var."\n");
print("stdout : ".$stdout."\n");
print("stderr : ".$stderr."\n");

?>
