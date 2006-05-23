#!/var/lib/lrs/php
<?php
#
# $Id$
#

include_once('commons.php');
		
print perl_exec("./lbs_header.cgi", array("list_of_machines status inventory", $text{'index_title'}, "general"));
 
$driver = $datasource->getDefaultSourceDriver();

$template = tmplInit(array('all' => 'Status.tpl'));

$since = $_GET["since"];
if ($since == "") $since = 0;
$template->set_var("SINCE", $since);
$type = "";
$hosts = $driver->getNotReceived($since, $type);
	
$template->set_block('all', 'row', 'rows');
if ($hosts) {
	sort($hosts);
	foreach ($hosts as $id => $val) {
		$template->set_var("HOST", "$val[0]");	
		if ($val[1]) {
			$template->set_var("DATE", " &nbsp; ".$text[received]." ".dateReverseFromSQL($val[1])." $val[2]");
		}
		$template->parse('rows', 'row', true);
	}
}

$type = "Boot";
$hosts = $driver->getNotReceived($since, $type);

$template->set_block('all', 'rowboot', 'rowsboot');
if ($hosts) {
	sort($hosts);
	foreach ($hosts as $id => $val) {
		$template->set_var("HOST", "$val[0]");
		if ($val[1]) {
			$template->set_var("DATE", " &nbsp; ".$text[received]." ".dateReverseFromSQL($val[1])." $val[2]");
		}
		$template->parse('rowsboot', 'rowboot', true);
	}
}

$template->pparse("out", "all", "all");

print perl_exec("lbs_footer.cgi");

?>
