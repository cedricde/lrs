#!/var/lib/lrs/php
<?php

	include_once('commons.php');
	include_once('request/ssh.inc.php');

	print perl_exec("./lbs_header.cgi", array("lrs-inventory general", $text{'index_title'}, "general"));

	$request_results = array();
	$toproceed = array();

	// Read all machine names that have been already requested.
	$fh = @fopen('toproceed.txt', 'r');
	if ( $fh )
	{
		while ( !feof($fh) )
		{
			$line = trim ( fgets($fh, 4096) );

			if ( ! empty($line) )

				$toproceed[] = $line;
		}

		fclose($fh);
	}

	// For each requested machines
	for ( $i=0 ; $i<count($machinenames) ; $i++ )
	{
		$machine = & $machinenames[$i];
		$mac = & $macaddresses[$i];

		// Check if it is connected
		if ( isConnected($machine) )
		{
			// Prepare SSH connexion
			$ssh = new LSC_Session($mac);

			// Execute the inventory
			$command = "C:/Progra~1/LRSInv~1/lrs-inventory.exe";

			$ssh->LSC_cmdAdd($command);
			$results = $ssh->LSC_cmdFlush();

			// Check if it has been successful
			if ( empty( $results[$command]['STDERR'] ) )

				$request_results[] = sprintf( $text['request_successful'] , $machine );

			else

				$request_results[] = sprintf( $text['request_failed'] , $machine );

		}
		else
		{
			// If machine is unreachable
			$request_results[] = sprintf( $text['request_delayed'] , $machine );

			// Add it to the future request of the inventory
			if ( ! in_array($machine, $toproceed) )

				$toproceed[] = $machine;

		}
	}

	// Store already requested machines in the dedicated file
	$fh = fopen('toproceed.txt', 'w');
	fputs($fh,  join("\n", $toproceed) );
	fclose($fh);

	// Display request results
	$template = tmplInit(array('template' => 'Request.tpl'));

	$template->set_var('GENERAL_URL', "general.cgi?${_ENV[QUERY_STRING]}");
	$template->set_var('REQUEST_RESULTS', join('<br/>', $request_results) );

	// Display the template
	$template->pparse("out", "template", "template");

	print perl_exec("lbs_footer.cgi");

?>
