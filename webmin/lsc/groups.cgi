#!/var/lib/lrs/php
<?php
#
# Linbox Rescue Server - Secure Remote Control Module
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

require_once('include/common.inc.php');
require_once('include/ssh.inc.php');
require_once('include/file.inc.php');
require_once('include/tree.inc.php');

lib_init_config();
initLbsConf("/etc/lbs.conf", 1);
$msg_str = "";
$msg = 0;
$icons = array();
$exticonsfile = $config_directory."/".$module_info['name']."/".$config['extensionicons'];
LSC_loadMime($exticonsfile, &$icons, NULL);
//$explorer = LSC_GetExplorerData($session, $exticonsfile);
$dir = new LSC_Directory(substr(FILES_PATH, 0, -1), $icons);
$dir->LSC_scanDir();
$tpl = new LSC_Tmpl(array("groups" => "groups.tpl"));
$tpl->set_block("groups", "MESSAGE");
if ($msg == 0)
  $tpl->set_var("MESSAGE", "");
else {
     $tpl->set_var("MESS", $msg_str);
     $tpl->set_var("MESS_ICON", "error");
}
$tpl->set_var("CUR_PROFILE", $_GET['profile']);
$tpl->set_var("GROUP", $_GET['group']);
$ether = etherLoad();
$profiles = new LSC_profiles();
$tpl->set_block("groups", "ITEMDIR", "ITEMDIRS");
$tpl->set_block("groups", "ENUMDIR");
$groups = $profiles->LSC_getGroups(!empty($_GET['profile']) ? $_GET['profile'] : NO_PROFILE);
LSC_tmplGroupParse($tpl, $groups, LSC_getLastGroup($_GET['group']));
LSC_tmplFilesGroupParse($tpl, $dir, "groups", "ROWFILE", $icons);
$tpl->rename_var("SUBDIR", "ENUMDIR");
$tpl->header_param = array("lsc groups", $text{'explorer_title'});
$tpl->footer_param = array("2");
$tpl->pparse("out", "groups", "groups");
?>
