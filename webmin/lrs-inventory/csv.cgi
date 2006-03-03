#!/var/lib/lrs/php
<?php

	include_once('commons.php');
	
	$type = $_GET['type'];
	
	// Handle special types (Custom field based)
	if ( $type=='Warranty' || $type=='Location' )
	{
		// Send headers for automatic download
		if ( ! headers_sent() )
		{
			header("Content-type: application/csv");
			header("Content-disposition: inline; filename=\"$type.csv\"");
		}
 
		for ( $i=0 ; $i<count($machines) ; $i++ )
		{
			$machine = & $machines[$i];

			$customfields = & $datasource->readCustomFields($machine);
			$fields = array( $machine->getName() , $customfields['BuyDate'] , $customfields['WarrantyEnd'] , $customfields['Comments'] );

			print join(';', $fields) ."\n";
		}

	}
	else
	{
		$data = & $datasource->read($type, $machines);
	
		// Write data to client browser
		$datasource->write($data, 'Http');
	}

?>