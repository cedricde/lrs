#!/var/lib/lrs/php -q
<?php

putenv("WEBMIN_CONFIG=/etc/webmin/");

require_once(dirname(__FILE__) . "/../lbs_common/lbs_common.php");
require_once(dirname(__FILE__) . "/../lbs_common/web-lib.php");
require_once(dirname(__FILE__) . "/include/scheduler.inc.php");

lib_init_config();
if ($config==-1) die("Error: config file not found\n");
initLbsConf("/etc/lbs.conf", 1);

/*
 * Dispatch all command
 */
$scheduler = new LSC_Scheduler();
$scheduler->dispatch_all_commands();

/*
 * Start all command
 */
$scheduler->start_all_commands();

?>
