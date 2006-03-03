<?php

include_once($INCLUDE_PATH .'Drivers/Csv/CsvDriver.php');

/**
 * A driver used for reading CSV-formated informations through HTTP (coming from OCS Inventory 3) and writing them to a client browser.
 * 
 * @author Maxime Wojtczak (Linbox FAS)
 */
class CsvHttpDriver extends CsvDriver
{
	function CvsHttpDriver($source, $paramters)
	{	
		parent::CsvDriver('', $paramters);
	}
	
	/**
	 * Write method simply display the data in a CSV like format on the browser.
	 * 
	 * @param objects Objects to write.
	 */
	function write(&$objects)
	{
		debug('Call to CsvHttpDriver::write');
		
		$version = & $this->getObjectDefaultVersion($objects[0]);
		
		// Send headers for automatic download
		if ( ! headers_sent() )
		{
			$type = $objects[0]->getClassName();

			header("Content-type: application/csv");
			header("Content-disposition: inline; filename=\"$type.csv\"");
		}

		// Write objects to client
		foreach ( $objects as $object )

			print $this->getObjectCsv($object, $version);

	}

	/**
	 * Reads Machine object in CSV format through HTTP informations.
	 * 
	 * @param machines The name of the machine to read.
	 * @param inventory Ignored.
	 * @return An array of machines.
	 */
	function & readMachineToTable($machines='', $inventory='')
	{
		global $datasource;
		$datasource->loadComponentClass('Machine');

		$return = array();

		// Open the file sent by the client
		$fh = fopen( $_FILES['filename']['tmp_name'] ,'r' );
		
		$line = fgets($fh, 4096);

		foreach ($machines as $machine)
		{
			// If the machine is the one sent
			$machine = ereg_replace('-[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{2}-[0-9]{2}-[0-9]{2}$', '', $machine);
			$line = ereg_replace('-[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{2}-[0-9]{2}-[0-9]{2};', ';', $line);

			if ( ereg("^$machine;", $line) )
			{
				// Return it
				$object = new Machine();
				$object->setName($machine);
				
				$return[] = & $object;
			}
		}

		fclose($fh);
		
		return $return;
	}

	/**
	 * Reads components in the HTTP informations.
	 * One should carefully give the type because there is no verification about the real type of the file to read...
	 * 
	 * @param type The type of objects to read.
	 * @param machines Owners of the components
	 * @param inventory The inventory from which machine should be read.
	 * @return An array of objects.
	 */
	function & readComponentToTable($type, & $machines, $inventory='')
	{
		global $datasource;
		$datasource->loadComponentClass($type);

		$objects = array();

		for ( $i=0 ; $i<count($machines) ; $i++ )
		{
			$machine = & $machines[$i];
			
			$machine->m_Components[$type] = array();
			$read = & $this->processCsvFile($machine, $type, $_FILES['filename']['tmp_name']);

			// Merge the arrays
			for ( $j=0 ; $j<count($read) ; $j++ )

				$objects[] = & $read[$j];

		}

		return $objects;
	}
}
 
?>
