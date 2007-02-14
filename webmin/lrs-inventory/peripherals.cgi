#!/var/lib/lrs/php
<?php

	include_once('commons.php');

	print perl_exec("./lbs_header.cgi", array("lrs-inventory peripherals", $text{'title_peri'}, "periphericals"));

	renderTable('Printer');
	renderTable('Input');
	renderTable('Monitor');
	renderTable('Modem');
	renderTable('Port');

    print perl_exec("lbs_footer.cgi");

?>