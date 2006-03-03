#!/var/lib/lrs/php
<?php

	include_once('lbs-inventory.php');
	include_once('commons.php');

	print perl_exec("./lbs_header.cgi", array("lrs-inventory software", $text{'title_soft'}, "software"));
	
	renderTable('Software', null, array('ExecutableSize'=>'Byte' ) );
	
	print perl_exec("lbs_footer.cgi");

?>
