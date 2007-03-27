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

require_once(dirname(__FILE__) . "/../../lbs_common/lbs_common.php"); /**< Use Template class */

/* Get the webmin lang settings */
$lang = $current_lang;

/**
 * 
 */
class LSC_Tmpl extends Template
{
	var $header_param = array();
	var $footer_param = array();

	function LSC_Tmpl($tpl_files, $root_dir = "./")
	{
		global $gconfig, $tb, $cb, $remote_user, $current_lang;

		$l = $current_lang;
		$d = $root_dir . "tmpl/$l";
		if (!is_dir($d) || $l == "") {
			$d = $root_dir . "tmpl/en";
		}
		Template::Template($d, "remove");
		$this->set_file($tpl_files);
		$this->set_var(array(
			"TB" => $tb,
			"CB" => $cb
		));
	}

  function pparse($target, $handle, $help, $append = false) {
    print perl_exec("lbs_header.cgi", $this->header_param, $help);
    Template::pparse($target, $handle, $append); 
    print perl_exec("lbs_footer.cgi", $this->footer_param);
    return (false);
  }

  function unset_var($varname)
  {
    if (!empty($varname)) {
      unset($this->varkeys[$varname]);
      unset($this->varvals[$varname]);
    }
  }
  
  function rename_var($oldname, $newname)
  {   
      $this->varkeys[$newname] =  "/".$this->varname($newname)."/";
      $this->varvals[$newname] = $this->varvals[$oldname];
      unset($this->varkeys[$oldname]);
      unset($this->varvals[$oldname]);
  }
  
  function copy_var($src, $dst)
  {
    $this->varkeys[$dst] = "/".$this->varname($dst)."/";
    $this->varvals[$dst] = $this->varvals[$src];
  }
  
  # swap content between 2 var
  function swap_var($in, $varname, $newname)
  {
    $this->set_var($varname, "\{$newname}");
    $this->parse("$inTMPSWP", $in);
    $this->rename_var("$inTMPSWP", $in);
    $this->unset_var($varname);
  }
}

/**
 *function that parse the template for the tree directory of
 * the explorer
 * because phplib doesn't recursive template.. it's ... hard ;-)
 */
function LinboxLSC_tmplTreeParse(&$tpl, $dir,  &$last, $level = 0)
{
	$distant_data = $dir->distant_data; 
	$tpl->copy_var("ITEMDIR", "TPLITEMDIR$level");
	$tpl->copy_var("ENUMDIR", "TPLENUMDIR$level");
	$tpl->swap_var("TPLENUMDIR$level", "ITEMDIRS", "ITEMDIRS$level");
	while (($cur = $dir->LSC_NextDir()) !== false) {
		$obj = $cur['obj'];
		$c++;
		$tpl->set_var("DIR_NAME$level", $cur['name']);
		$tpl->set_var("DIR_UP$level", LSC_cygpath($cur['curdir'], "LinToWin", $distant_data['mount_point2']));
		if ($obj != null) {
			LinboxLSC_tmplTreeParse($tpl, &$obj, $last, $level+1);
			if (!strcmp($obj->curdir, $last->curdir)) {
				$tpl->set_var("DIR_OPEN", " class=\"active\"");
			} else {
				$tpl->set_var("DIR_OPEN", " class=\"open\"");
			}
		} else {
			$tpl->set_var("DIR_OPEN", "");
			$tpl->set_var("SUBDIR", "");
		}
		$tpl->rename_var("DIR_NAME$level", "DIR_NAME");
		$tpl->rename_var("DIR_UP$level", "DIR_UP");
		$tpl->parse("ITEMDIRS$level", "TPLITEMDIR$level", true);
		$tpl->unset_var("DIR_OPEN");
	}
	if ($c == 0) {
		$tpl->set_var("ITEMDIRS$level", "");
	}
	$tpl->parse("SUBDIR", "TPLENUMDIR$level");
	$tpl->unset_var("TPLENUMDIR$level");
	$tpl->unset_var("TPLITEMDIR$level");
	$tpl->unset_var("ITEMDIRS$level");
}


function LSC_tmplFilesParse(&$tpl, &$dir, $base, $in, $mimeicons)
{
  $dir->LSC_reset();
  $tpl->set_block($base, $in, "ROWFILES");
  for ($cur = $dir->LSC_NextElm(), $b = 0;
        $cur !== false;
        $i++, $b = $i % 2, $cur = $dir->LSC_NextElm()) {
    $obj = $cur['obj'];
    $tpl->set_var("PWD_DIR", $obj->distant_name);
    $tpl->set_var("BACKGROUND_CLASS", "background$b");
    $tpl->set_var("FILENAME", $cur['name']);
    $tpl->set_var("SIZE", ConvertSize($cur['size']));
    $tpl->set_var("CTIME", date("d-m-Y H:i", $cur['ctime']));
    $tpl->set_var("MIMETYPE", $obj->mimetype);
    if ($cur['type'] == "directory")
      $tpl->set_var("ICON_MIMETYPE", MIME_DIR_ICON);
    else
      $tpl->set_var("ICON_MIMETYPE", $mimeicons[$obj->extension]);
    $tpl->parse("ROWFILES", $in, true);
  }
  if ($i == 0)
   $tpl->set_var("ROWFILES", "");
}

# like LSC_tmplTreeParse, but with group of computers
# $stop : if true, stop de recursive
# $cur : the current str group.
function LSC_tmplGroupParse(&$tpl, $ar_groups,  $cur, $level = 0, $stop = 0)
{
  $tpl->copy_var("ITEMDIR", "TPLITEMDIR$level");
  $tpl->copy_var("ENUMDIR", "TPLENUMDIR$level");
  $tpl->swap_var("TPLENUMDIR$level", "ITEMDIRS", "ITEMDIRS$level");
  if (empty($cur)) $stop = 1;
  foreach($ar_groups as $key => $obj) {
    $c++;
    $tpl->set_var("DIR_NAME$level", $obj->name);
    $tpl->set_var("LPROFIL$level", $obj->profile);
    $tpl->set_var("LGROUP$level", $obj->name);
    if ($stop == 0) {
      LSC_tmplGroupParse($tpl, &$obj->sib, $cur, $level+1 , !strcmp($obj->name, $cur));
      $tpl->set_var("DIR_OPEN", " class=\"open\"");
    }
    else {
      $tpl->set_var("DIR_OPEN", "");
      $tpl->set_var("SUBDIR", "");
    } 
 
    $tpl->rename_var("DIR_NAME$level", "DIR_NAME");
    $tpl->rename_var("LGROUP$level", "LGROUP");
    $tpl->rename_var("LPROFIL$level", "LPROFIL");
    $tpl->rename_var("DIR_UP$level", "DIR_UP");
    $tpl->parse("ITEMDIRS$level", "TPLITEMDIR$level", true);
    $tpl->unset_var("DIR_OPEN");
  }
  if ($c == 0)
    $tpl->set_var("ITEMDIRS$level", "");
  $tpl->parse("SUBDIR", "TPLENUMDIR$level");
  $tpl->unset_var("TPLENUMDIR$level");
  $tpl->unset_var("TPLITEMDIR$level");
  $tpl->unset_var("ITEMDIRS$level");
}

function LSC_tmplFilesGroupParse(&$tpl, &$dir, $base, $in, $mimeicons)
{ 
  $dir->LSC_reset();
  $tpl->set_block($base, $in, "ROWFILES");
  for ($cur = $dir->LSC_NextElm(), $b = 0;
        $cur !== false;
        $i++, $b = $i % 2, $cur = $dir->LSC_NextElm()) {
    $obj = $cur['obj'];
    $tpl->set_var("PWD_DIR", $obj->distant_name);
    $tpl->set_var("BACKGROUND_CLASS", "background$b");
    $tpl->set_var("FILENAME", $cur['name']);
    $tpl->set_var("SIZE", ConvertSize($cur['size']));
    $tpl->set_var("CTIME", date("d-m-Y H:i", $cur['ctime']));
    $tpl->set_var("MIMETYPE", $obj->mimetype);
    if ($cur['type'] == "directory")
      $tpl->set_var("ICON_MIMETYPE", MIME_DIR_ICON);
    else
      $tpl->set_var("ICON_MIMETYPE", $mimeicons[$obj->extension]);
    $tpl->parse("ROWFILES", $in, true);
  }
  if ($i == 0)
   $tpl->set_var("ROWFILES", "");
}

?>
