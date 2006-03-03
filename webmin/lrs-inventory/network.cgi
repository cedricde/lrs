#!/var/lib/lrs/php
<?php

	include_once('commons.php');
	
	print perl_exec("./lbs_header.cgi", array("lrs-inventory network", $text{'title_net'}, "network"));
	
	renderTable('Network');
	
	print perl_exec("lbs_footer.cgi");

?>