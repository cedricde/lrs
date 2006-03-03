<?php

	$QUERY;
	$DEVICEID;
	$DATA;

	include_once('../classes/DataSource.php');

	// Load data source
	$datasource = & DataSource::getDefaultDataSource();

	// Read compressed data
	$stdin = fopen('php://input','r');
	$data = fread($stdin,$_SERVER['CONTENT_LENGTH']);
	fclose($stdin);
	
	// Write it in a temporary file
	$fh = fopen("/tmp/${_SERVER[REMOTE_ADDR]}.tmp",'w');
	fwrite($fh,$data);
	fclose($fh);
	
	// Uncompress it
	exec("perl uncompress.pl /tmp/${_SERVER[REMOTE_ADDR]}.tmp",$DATA);
	$DATA = join('',$DATA);
	
	system("rm /tmp/${_SERVER[REMOTE_ADDR]}.tmp -f");
	
	// Retrieve query and sender
	ereg("<QUERY>([a-zA-Z0-9_-]+)</QUERY>", $DATA, $matches);
	$QUERY = $matches[1];
	
	ereg('<DEVICEID>([a-zA-Z0-9_-]+)</DEVICEID>', $DATA, $matches);
	$DEVICEID = $matches[1];
	
	$DEBUG = true;

	if ( $QUERY=='PROLOG' )

		// Always send the inventory
		$data = '<?xml version="1.0" encoding="utf-8" ?><REPLY><RESPONSE>send</RESPONSE></REPLY>';

	else if ( $QUERY=='INVENTORY' )
	{
		// Extract inventory data
		ereg('(<HARDWARE>.+)<\/CONTENT>', $DATA, $matches);
		$INVENTORY = '<?xml version="1.0" encoding="utf-8" ?><Inventory>'. $matches[1] .'</Inventory>';

		$data = '<?xml version="1.0" encoding="utf-8" ?><REPLY><RESPONSE>no_update</RESPONSE></REPLY>';

		// Parse data
		$machines = & $datasource->readMachine( array($DEVICEID), null, 'OcsNG' );

		// Store data on the server
		for ( $i=0 ; $i<count($machines) ; $i++ )
		{
			$machine = & $machines[$i];

			foreach ( array_keys($machine->m_Components) as $type )

				$datasource->write($machine->m_Components[$type]);
		}

	}

	print gzcompress($data);


?>
