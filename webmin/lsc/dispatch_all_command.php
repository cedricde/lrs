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

/**
 * @file This script dispatch all commands
 *
 */
putenv("WEBMIN_CONFIG=/etc/webmin/");

require_once(dirname(__FILE__) . "/../lbs_common/lbs_common.php");
require_once(dirname(__FILE__) . "/../lbs_common/web-lib.php");
require_once(dirname(__FILE__) . "/include/scheduler.inc.php"); /**< Use LSC_Scheduler */

/* 
 * Init webmin
 */
lib_init_config();
if ($config==-1) die("Error: config file not found\n");
initLbsConf("/etc/lbs.conf", 1);

$scheduler = new LSC_Scheduler();
print("Start dispatch all commands...\n");
$scheduler->dispatch_all_commands();
print("Dispatch all commands done\n");

?>
