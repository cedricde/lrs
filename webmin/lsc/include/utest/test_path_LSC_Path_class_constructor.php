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
require_once(dirname(__FILE__) . "/../path.inc.php");

/** 
 * Init webmin
 */
$config_directory="./";
lib_init_config();
initLbsConf($config['lbs_conf'], 1);

/**
 * Function to test one path
 */
function test($path)
{
	print("Test class : LSC_Path\n");

	printf("Path is : %s\n", $path);

	$new_path = new LSC_Path($path);

	printf("profile name : %s\n", $new_path->get_profile_name());
	printf("group depth : %s\n", $new_path->get_group_depth());
	for ( $i=0 ; $i < $new_path->get_group_depth() ; $i++ ) {
		printf("Group name level %s : %s\n", $i, $new_path->get_group_name($i));
	}
	printf("host name : %s\n", $new_path->get_host());
}

print("====\n");
test("profil1:");
print("====\n");
test(":group1/");
print("====\n");
test(":host1");
print("====\n");
test(":group1/group2/");
print("====\n");
test("profil1:group1/group2/");
print("====\n");
test("profil1:/group1/group2/");
print("====\n");
test("profil1:group1/group2/host2");
print("====\n");
test("host2");
print("====\n");
test("group2/");
print("====\n");
test("group1/host9");
print("====\n");
test("all:");
print("====\n");
test("zin");
print("====\n");
test("host3");
?>
