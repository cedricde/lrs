<?php
#
# Linbox Rescue Server
# Copyright (C) 2005  Linbox FAS
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

require_once(dirname(__FILE__) . "/../common.inc.php");
require_once(dirname(__FILE__) . "/../ssh.inc.php");
require_once(dirname(__FILE__) . "/config_host.php"); // Define MAC_ADRESS constant

$DEBUG = 9;
$OUTPUT_TYPE = "TERMINAL";

/** 
 * Init webmin
 */
$config_directory="./";
lib_init_config();
initLbsConf($config['lbs_conf'], 1);

/**
 * Open a new session
 */
print("Open session\n");
$new_session = new LSC_Session(MAC_ADRESS, "root");

/**
 * Launch "ls" command in ssh connection
 */
print("Launch \"ls\" command in ssh connection\n");
$new_session->LSC_cmdAdd("ls");

print_r($new_session->LSC_cmdFlush());

/**
 * Launch many command : "ls" + "ls ../" command in ssh connection
 */
print("Launch \"ls\" + \"ls ../\" commands in ssh connection\n");
$new_session->LSC_cmdAdd("ls");
$new_session->LSC_cmdAdd("ls ../");

print_r($new_session->LSC_cmdFlush());

/**
 * Launch many command : "ls" + "ls ffhfd/" command in ssh connection
 *
 * Second command send error !
 */
print("Launch \"ls\" + \"ls dsdsds/\" commands in ssh connection\n");
$new_session->LSC_cmdAdd("ls");
$new_session->LSC_cmdAdd("ls dsdsds/");

print_r($new_session->LSC_cmdFlush());
?>
