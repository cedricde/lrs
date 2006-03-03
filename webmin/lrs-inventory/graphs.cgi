#!/var/lib/lrs/php
<?php

	include_once('commons.php');
		
	print perl_exec("./lbs_header.cgi", array("lrs-inventory general", $text{'index_title'}, "general"));
    
	$type = $_GET['type'];
	$field = $_GET['field'];
	$mac = $_GET['mac'];
	$group = $_GET['group'];
	$profile = $_GET['profile'];

	print "<center><img src=\"graph.cgi?type=$type&field=$field&mac=$mac&group=$group&profile=$profile\" alt='graph'></center>";

	print perl_exec("lbs_footer.cgi");

?>