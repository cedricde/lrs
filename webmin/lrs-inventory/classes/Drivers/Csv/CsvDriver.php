<?php

include_once($INCLUDE_PATH .'Drivers/Driver.php');
include_once($INCLUDE_PATH .'Drivers/Csv/CsvDefinition.php');

/**
 * The CsvDriver class implements a driver used for reading and writing CSV files according to a CsvDefinition object.
 * 
 * @author Maxime Wojtczak (Linbox FAS)
 */
class CsvDriver extends Driver
{
	var $m_DataPath;
	var $m_DefinitionPath;
	var $m_Definitions;
	var $m_Machines;
	var $appcsv = array(); // cache for apps.csv file

	/**
	 * Constructor. Build a CsvDriver object.
	 * 
	 * @param source The source name for which the driver has been created.
	 * @param parameters An array containing parameters for CSV reading and storage.
	 */
	function CsvDriver($source, $paramters)
	{	
		parent::Driver($source);
			
		$this->m_DataPath = $paramters['DataPath'];
		$this->m_DefinitionPath = $paramters['DefinitionPath'];
		
		$this->m_Definitions = array();
		$this->m_Machines = array();
	}

	/**
	 * Writes an object array in a CSV file.
	 * 
	 * @param objects An object array.
	 */
	function write(&$objects)
	{
		debug('Call to CsvDriver::write');
		
		$first = & $objects[0]->getHost();

		$hostname = $first->getName();
		
		// Get the right version
		$version = & $this->getObjectDefaultVersion( $objects[0] );

		// If there is no version informations to complete storage
		if ( empty($version) )

			// Exit method
			return;

		$this->createPathForType($version);

		$csv = '';

		// Convert each object
		foreach ($objects as $object)

			$csv .= $this->getObjectCsv($object, $version);

		// and write them in the correct file
		$filename = $this->m_DataPath . $version->getDirectory() .'/'. $hostname .'.csv';

		$tmpname = tempnam('/tmp', 'inventory');

		copy($filename, $tmpname);
		
		$fp = fopen($filename, 'w');
		
		if ($fp)
		{
			fwrite($fp, $csv);
			fclose($fp);
		}

		system("diff \"$filename\" \"$tmpname\" > \"$filename.diff\"");
		system("rm \"$tmpname\" -f");
	}
	
	/**
	 * Returns the type definition version of the object given in parameter.
	 * 
	 * @param object Object to get the version.
	 * @return A reference to a CsvVersion object.
	 */
	function & getObjectDefaultVersion(&$object)
	{
		$typedefinition = & $this->getDefinition($object->getClassName());
		$version = & $typedefinition->getDefaultVersion();

		return $version;
	}
	
	/**
	 * Create a string in the CSV format agree to the object and version given in parameter.
	 * 
	 * @param object Object to convert into CSV.
	 * @param version Version of CSV conversion.
	 * @return The CSV-formatted string.
	 */
	function getObjectCsv(&$object,&$version)
	{
		$csvvalues = array();

		// for each field to store
		for ( $i=0 ; $i<$version->getFieldCount() ; $i++ )
		{
			$field = $version->getField($i);

			// put it in the right rank
			if ( ! empty($field) )
			{
				if ( $field=='Host' )
				{
					$host = & $object->getHost();
					$csvvalues[$i] = $host->getName();
				}
				else
					$csvvalues[$i] = $object->getProperty($field);
			}

			else
				$csvvalues[$i] = '';
		}

		// join them all with commas
		return implode(';', $csvvalues) ."\n";
	}
	
	/**
	 * Return the type name corresponding to the given directory
	 * 
	 * @param directory The directory.
	 * @return The corresponding type.
	 */
	function getTypeForDirectory($directory)
	{
		$this->loadAllDefinitions();

		for ( $i=0 ; $i<count($this->m_Definitions) ; $i++ )
		{
			$definition = & $this->m_Definitions[$i];
			
			if ( $definition->containDirectory($directory) )
			
				return $definition->getType();
		}
		
		return '';
	}
	
	/**
	 * Returns the Csv definition according to the type passed in parameter. If the defintion has not been yet loaded, then it automatically loads it.
	 * 
	 * @param type Type name as a string
	 * @return A reference to the CsvDefinition object.
	 */
	function & getDefinition($type)
	{
		global $INCLUDE_PATH;

		// Warning : class names in PHP are all converted in lower case characters, then, a convertion is needed.
		$type = strtolower($type);

		// Search in all already loaded definitions for the right definition.
		for ( $i=0 ; $i<count($this->m_Definitions) ; $i++ )
		{
			$current = strtolower( $this->m_Definitions[$i]->getType() );

			if ( $current==$type )

				return $this->m_Definitions[$i];
		}

		return $this->loadDefinition($type);
	}
	
	/**
	 * Loads the definition file associated with the given type.
	 * 
	 * @param type Type to load.
	 * @return The corresponding CsvDefinition object.
	 */
	function & loadDefinition($type)
	{
		$type = strtolower($type);
		
		// If it has not been found, then, load it.
		$dh = opendir( $this->m_DefinitionPath );

		// Case insensitive file search...
		while ( $file = readdir($dh) )
		{
			$current = ereg_replace('\.xml$','',strtolower($file));

			if ( $current==$type )
			{
				$filename =  $this->m_DefinitionPath . $file;
				break;
			}
		}

		closedir($dh);

		// If a file has been found, then return it
		if ( !empty($filename) )
		{
			$definition = & CsvDefinition::loadFromFile($filename);
			$this->m_Definitions[] = & $definition;
	
			return $definition;
		}
		else
		
			return '';
	}
	
	/**
	 * Loads all definitions available in the data directory.
	 */
	function loadAllDefinitions()
	{
		$dh = opendir( $this->m_DefinitionPath );
		
		$definitions = array();
		
		while ( $file = readdir($dh) )
		{
			$filename =  $this->m_DefinitionPath . $file;

			$this->m_Definitions[] = & CsvDefinition::loadFromFile($filename);

			unset($definition);
		}

		closedir($dh);
	}

	/**
	 * Creates the directory where to store the CSV file.
	 * 
	 * @param version Version to store.
	 */
	function createPathForType($version)
	{
		$filedir = $this->m_DataPath .'/'. $version->getDirectory();

		if ( ! file_exists($filedir) )
			mkdir($filedir,0700);
	}
	
	/**
	 * Returns the machine object corresponding to the given name.
	 * 
	 * @param name The machine name.
	 * @return A machine object.
	 */
	function & getMachine($name)
	{
		global $datasource;

		$datasource->loadComponentClass('Machine');

		// If the machine hasn't been load
		if ( ! in_array($name, $this->m_Machines) )
		{
			// Create it and store it
			$machine = new Machine();
			$machine->setName($name);
			
			$this->m_Machines[$name] = & $machine;
		}

		return $this->m_Machines[$name];
	}

	/**
	 * Reads Machine object in the CSV files.
	 * 
	 * @param machines Machine names or MAC addresses to read.
	 * @param inventory The inventory from which machine should be read.
	 * @return An array of machines.
	 */
	function & readMachineToTable($machines='', $inventory='')
	{
		global $datasource;
		$datasource->loadComponentClass('Machine');
		
		if ( is_array($machines) )
		{
			$clauses = array();
			
			foreach ( $machines as $current )
			
				if ( eregi('^[0-9a-f]{2}:[0-9a-f]{2}:[0-9a-f]{2}:[0-9a-f]{2}:[0-9a-f]{2}:[0-9a-f]{2}$', $current) )

					$clauses[] = $current;
					
				else
				
					$clauses[] = '^'. $current;
			
			$pattern = '/('. join('|', $clauses) .')/';
		}
		
		// Thanks to awk, a CSV-like output containing machine informations is created and read just like any other file.
		$commandline =	'awk -F ";" -- \''. $pattern .'{met=0; for (x in already) if (x==$1) met=1; if (met==0) print $1 ";" $6; already[$1]=1 }\' '. $this->m_DataPath .'Network/*.csv '. $this->m_DataPath .'Networks/*.csv';

		// Open the pipe
		$programhandle = popen($commandline, 'r');
		
		$machines = array();
		
		// Fetch all lines
		while ( !feof($programhandle) )
		{
			unset($object);
			
			$line = fgets($programhandle, 4096);
			
			// If there is data to process
			if ( !empty($line) )
			{
				// Fetch the data
				$object = & $this->fetchObjectFromLine('Machine', $line);
				
				$machines[] = & $object;
			}
		}
		
		pclose($programhandle);
		
		return $machines;
	}

	/**
	 * Reads components in the CSV files.
	 * 
	 * @param type The type of objects to read.
	 * @param machines Owners of the components
	 * @param inventory The inventory from which machine should be read.
	 * @return An array of objects.
	 */
	function & readComponentToTable($type, &$machines, $inventory='')
	{
		global $datasource;
		$datasource->loadComponentClass($type);
		
		$objects = array();
		
		// Foreach machine
		for ( $i=0 ; $i<count($machines) ; $i++ )
		{
			$machine = & $machines[$i];
			
			$machine->m_Components[$type] = array();

			// Get the CSV definition of the type to read
			$typedefinition = & $this->getDefinition($type);

			// If a definition has been found
			if ( ! empty($typedefiniction) )
			{
				// Find the file where data are stored
				$file = $this->getFileForType($typedefinition, $machine);
	
				if ( ! empty($file) )
				{
					$date = date("Y-m-d", filemtime($file));
	
					// If requested informations are those from the previous inventory and previous inventory informations are available
					if ( !empty($inventory) && strcmp($date, $inventory)==1 && file_exists($file .'.diff') )
	
						// Then, read informations from patched inventory
						$fh = @popen("patch \"$file\" \"$file.diff\" -o /dev/stdout --quiet", 'r');
	
					else
	
						// else open inventory as-is
						$fh = @fopen($file, 'r');
	
					if ( $fh!=false )
					{
						// When the file is finally found, process it
						$read = & $this->processCsvFlow($machine, $type, $fh);
			
						// Merge the arrays
						for ( $j=0 ; $j<count($read) ; $j++ )
	
							$objects[] = & $read[$j];
	
					}
				}
			}

		}

		return $objects;
	}

	/**
	 * Retrieve the path of the CSV file 
	 *
	 * @param typedefinition The type defintion of CSV file to retrieve
	 * @param 
	 */
	function getFileForType(&$typedefinition, &$machine)
	{
		// First, have a look at the default version
		$version = & $typedefinition->getDefaultVersion();
		$directory = $version->getDirectory();
		$file = $this->m_DataPath . $directory .'/'. $machine->getName() .'.csv';
		
		unset($version);

		if ( file_exists($file) )

			return $file;

		else

			// If nothing found at the default location, then try alternate directories
			foreach ( $typedefinition->getVersions() as $version )
			{
				$directory = $version->getDirectory();

				$file = $this->m_DataPath .'/'. $directory .'/'. $machine->getName() .'.csv';

				if ( file_exists($file) )

					return $file;
			}

		return '';
	}

	/**
	 * load the Apps.csv file to add information to OCSv2 inventories
	 *
	 */
	function loadAppsCSV()			
	{
	  	global $INCLUDE_PATH;

		if ( ! empty($this->appcsv) ) { return; }
		      
		@$appfile = file("$INCLUDE_PATH/../agent/Apps.csv");

		foreach ( $appfile as $val ) {
			$m = split(";", trim($val));
			$id = $m[0];
			$name = $m[1];
			$ver = $m[2];
			$ed = $m[5];
			$this->appcsv[$id] = "$ed;$name;;$ver";
		}
	}

	/**
	 * Reads the content of a CSV file and store it into the given machine.
	 * 
	 * @param machine The machine where to store the read objects.
	 * @param type The type of data to read.
	 * @param file The file to read.
	 * @return An array of the read objects.
	 */
	function & processCsvFile(&$machine, $type, $file)
	{
		// Open the file
		if ( $fh = @fopen($file, 'r') )
		{
			$objects = & $this->processCsvFlow($machine, $type, $fh);

			fclose($fh);
		}
		else
			$objects = array();

		return $objects;
	}

	
	/**
	 * Reads the content of a CSV file and store it into the given machine.
	 * 
	 * @param machine The machine where to store the read objects.
	 * @param type The type of data to read.
	 * @param file The file to read.
	 * @return An array of the read objects.
	 */
	function & processCsvFlow(&$machine, $type, $filehandle)
	{
		$objects = array();

		// Read all data in available in the opened file
		while ( !feof($filehandle) )
		{
			$line = fgets($filehandle, 4096);

			if (trim($line) == ";;") return $objects;

			// OCSv2 and no version info, try to get it from Apps.csv
			if ($type == "Software") {
				if (substr_count($line, ";") == 5) {
					$this->loadAppsCSV();
					list ($sid) = sscanf(strstr($line, ";"), ";%d;");
					if (isset($this->appcsv[$sid])) {
						$line = trim($line).$this->appcsv[$sid];
					}
				}
			}

			// If there is data to process
			if ( !empty($line) )
			{
				// Fetch the data
				$object = & $this->fetchObjectFromLine($type, $line);
				
				// Update component<=>host links
				$machine->m_Components[$type][] = & $object;
				$object->setHost($machine);
				
				$objects[] = & $object;

				unset($object);
			}
		}

		return $objects;
	}

	/**
	 * Returns the object described by the given CSV line.
	 * 
	 * @param type The type of object to read.
	 * @param line The line to read.
	 * @return The read object.
	 */
	function & fetchObjectFromLine($type, $line)
	{
		$object = new $type();

		// Get the definition describing the type
		$typedefinition = & $this->getDefinition($type);
		
		$values = explode(';', $line);
		
		// Find the right version of the line
		$version = & $typedefinition->detectVersion('', count($values));

		// Fill object properties with fields
		for ( $i=0 ; $i<count($values) ; $i++ )
		{
			$values[$i] = trim($values[$i]);

			// If the field has to be process
			if ( ! empty($values[$i]) && $values[$i]!='N/A' )
			{
				$fieldname = $version->getField($i);

				// Perform a special operation on the Name of a machine
				// (removing date-based id of OCS inventory 3 and NG)
				if ( $fieldname=='Name' && $type=='Machine' )
				{
					$object->setProperty($fieldname, ereg_replace('-[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{2}-[0-9]{2}-[0-9]{2}$', '', $values[$i]) );
				}
				elseif ( !empty($fieldname) && $fieldname!='Unused' && $fieldname!='Host' )

					$object->setProperty($fieldname, $values[$i]);
			}
		}
		
		return $object;
	}

	/**
	 * Reads all the custom fields of the given machine. Custom fields are both retrieved and filled into the machine object.
	 * 
	 * @param machine The machine to get the custom fields.
	 *
	 * @return The custom fields in an array.
	 */	
	function & readCustomFields(&$machine)
	{
		$customfields = array();

		$networks = & $machine->getNetworks();
		
		// Retrieve the files describing custom fields
		for ( $i=0 ; $i<count($networks) ; $i++ )
		{
			$mac = $networks[$i]->getMACAddress();
			
			$filename = $this->m_DataPath .'/Info/Garantie/'. $mac .'_garantie.ini';

			// If a warranty file has been found, read it
			if ( file_exists($filename) )
			{
				$fields = $this->readIniFile($filename);
				
				foreach ($fields as $key=>$value)

					$customfields[$key] = $value;
			}
			
			$filename = $this->m_DataPath .'/Info/Situation_Geo/'. $mac .'_site_geo.ini';

			// If a location file has been found, read it
			if ( file_exists($filename) )
			{
				$fields = $this->readIniFile($filename);
				
				foreach ($fields as $key=>$value)

					$customfields[$key] = $value;
			}

			// When data are read, exit
			if ( !empty($customfields) )
			
				break;
		}
		
		$machine->m_CustomFields = & $customfields;

		return $customfields;
	}
	
	/**
	 * Reads an INI file and returns data in an associative array.
	 * 
	 * @param filename File to open.
	 * @return An associative array containing pairs.
	 */
	function & readIniFile($filename)
	{			
		$fields = array();
		
		// Open the file
		if ( $fh = @fopen($filename, 'r') )
		{
			while ( ! feof($fh) )
			{
				$line = fgets($fh, 4096);
				
				// If a field has to be read
				if ( ereg('(.+)=.*"(.+)"', $line, $matches) )
				{
					// Read it
					$key = trim( $matches[1] );
					$value = trim( $matches[2] );
					
					// Perform some mapping operations
					switch ($key)
					{
						case 'situation_geographique':
							$key = 'Location';
							break;
						case 'telephone_proche':
							$key = 'Phone';
							break;
						case 'date_achat':
							$key = 'BuyDate';
							break;
						case 'garantie_constructeur':
							$key = 'WarrantyEnd';
							break;
						case 'commentaires':
							$key = 'Comments';
							break;
					}
					
					$fields[$key] = $value;
				}

			}

			fclose($fh);
		}

		return $fields;
	}
	
	/**
	 * Saves all the custom fields of the given machine.
	 * 
	 * @param machine The machine containing the custom fields to save
	 */
	function saveCustomFields(&$machine)
	{
		// Search for files which already exists
		$networks = $machine->getNetworks();
		foreach ($networks as $network)
		{
			$warrantyfile = $this->m_DataPath .'/Info/Garantie/'. $network->getMACAddress() .'_garantie.ini';
			$locationfile = $this->m_DataPath .'/Info/Situation_Geo/'. $network->getMACAddress() .'_site_geo.ini';
		
			if ( file_exists($warrantyfile) || file_exists($locationfile) )
			{
				$mac = $network->getMACAddress();
				break;
			}
		}

		// If no file has been found, then consider the identifier MAC address is the first one
		if ( !isset($mac) )
		
			$mac = $network[0]->getMACAddress();
		
		// Retrieve the custom fields
		$customfields = $machine->m_CustomFields;

		// Write warranty informations in the dedicated file
		$filename = $this->m_DataPath .'/Info/Garantie/'. $mac .'_garantie.ini';
		
		if ( $fh = fopen($filename, 'w') )
		{
			foreach ( array('BuyDate','WarrantyEnd','Comments') as $key)
			{
				fwrite($fh, "$key = \"${customfields[$key]}\"\n");
				
				unset($customfields[$key]);
			}

			fclose($fh);
		}

		// Write location informations in the dedicated file
		$filename = $this->m_DataPath .'/Info/Situation_Geo/'. $mac .'_site_geo.ini';

		if ( $fh = fopen($filename, 'w') )
		{
			foreach ( $customfields as $key=>$value )

				fwrite($fh, "$key = \"$value\"\n");

			fclose($fh);
		}
	}
}

?>