#!/var/lib/lrs/php
<?php

	include_once('commons.php');
	include_once('classes/libchart/libchart.php');
		
	$datasource->loadComponentClass('Component');
	
	//print perl_exec("./lbs_header.cgi", array("lrs-inventory general", $text{'index_title'}, "general"));

	renderGraph($_GET['type'], $_GET['field']);

	//print perl_exec("lbs_footer.cgi");

?>