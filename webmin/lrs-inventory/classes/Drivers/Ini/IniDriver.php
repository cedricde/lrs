<?php

include_once($INCLUDE_PATH .'Drivers/Driver.php');
//include_once($INCLUDE_PATH .'Drivers/Csv/CsvDefinition.php');

/**
 * The IniDriver class implements a driver used for reading and writing CSV files according to a CsvDefinition object.
 * 
 * @author Ludovic Drolez (Linbox FAS)
 */
class IniDriver extends Driver
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
	function IniDriver($source, $paramters)
	{	
		parent::Driver($source);
			
		$this->m_DataPath = $paramters['DataPath'];
		$this->m_DefinitionPath = $paramters['DefinitionPath'];
		
		$this->m_Definitions = array();
		$this->m_Machines = array();
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
		//$fh = fopen( $_FILES['filename']['tmp_name'] ,'r' );
		
		//$line = fgets($fh, 4096);

		foreach ($machines as $machine)
		{
		  
		  // Return it
		  $object = new Machine();
		  $object->setName($machine);
		  
		  $return[] = & $object;
	
		}

		return $return;
	}

	/**
	 * Like parse_ini_file with less restrictions
	 *
	 * @param filename File to parse
	 * @param commentchar char used for comments
	 * @return The ini file parsed
	 */
	function parseIniFile ($filename, $commentchar = '#' ) 
	{
		$array1 = file($filename);
	  	$section = '';
		foreach ($array1 as $filedata) {
			$dataline = trim($filedata);
			$firstchar = substr($dataline, 0, 1);
			if ($firstchar!=$commentchar && $dataline!='') {
				//It's an entry (not a comment and not a blank line)
				if ($firstchar == '[' && substr($dataline, -1, 1) == ']') {
					//It's a section
					$section = substr($dataline, 1, -1);
	      			} else {
					//It's a key...
					$delimiter = strpos($dataline, '=');
					if ($delimiter > 0) {
						//...with a value
						$key = trim(substr($dataline, 0, $delimiter));
						$value = trim(substr($dataline, $delimiter + 1));
						if (substr($value, 1, 1) == '"' && substr($value, -1, 1) == '"') { $value = substr($value, 1, -1); }
						$array2[$section][$key] = stripcslashes($value);
					} else {
						//...without a value
						$array2[$section][trim($dataline)]='';
					}
	      			}
	    		}else{
	      			//It's a comment or blank line.  Ignore.
	    		}
	  	}
	  	return $array2;
	}

	/**
	 * Reads components from the Ini files.
	 * 
	 * @param type The type of objects to read.
	 * @param machines Owners of the components
	 * @param inventory The inventory from which machine should be read.
	 * @return An array of objects.
	 */
	function & readComponentToTable($type, &$machines, $inventory='')
	{
		global $datasource, $argv;

		// type is ignored since an ini file always contains grub inventory info
		$datasource->loadComponentClass("BootGeneral");
		$datasource->loadComponentClass("BootPCI");
		$datasource->loadComponentClass("BootDisk");
		$datasource->loadComponentClass("BootPart");
		$datasource->loadComponentClass("BootMem");
		
		$objects = array();
	
		// Foreach machine
		for ( $i=0 ; $i<count($machines) ; $i++ )
		{
			$machine = & $machines[$i];
			
			$machine->m_Components[$type] = array();

			// Get the CSV definition of the type to read
			$typedefinition = "test"; //& $this->getDefinition($type);

			// If a definition has been found
			if ( ! empty($typedefinition) )
			{
				// Find the file where data are stored
				//$file = $this->getFileForType($typedefinition, $machine);
	
			  
			  $data = $this->parseIniFile($argv[1]);

			  foreach($data as $sname => $section)		
			  {
			  	// section name to type mapping
			      	// should be in a config file ?
			      	if ($sname == "MAIN") {
				  	$type = "BootGeneral";
				} else if (preg_match("/^PCI/", $sname)) {
					$type = "BootPCI";
				} else if (preg_match("/^DISK/", $sname)) {
					$type = "BootDisk";
				} else if (preg_match("/^MEM/", $sname)) {
					$type = "BootMem";
				} else {
					$type = "";
				}
			      
			      
			        if ($type == "") continue;

			      // fill the object
			      $object = new $type();
			      $parts = array();
			      foreach ($section as $key => $value)
				{
				  if ($type == "BootDisk") {
			      		preg_match("/[0-9]+$/", $sname, $dnum);
			      		$object->setProperty("Num", $dnum[0]);
				  	// partitions are in the bootdisk section
				  	if (preg_match("/Part([A-Za-z]+)([0-9]+)/", $key, $m)) {
						$num = $m[2];
						if (!isset($parts[$num])) {
							$parts[$num] = & new BootPart();
							$parts[$num]->setHost($machine);
						}
						$parts[$num]->setProperty("Disk", $dnum[0]);
						$parts[$num]->setProperty($m[1], $value);
						$parts[$num]->setProperty("Flag", "");
						continue;
					}
				  }
				  $object->setProperty($key, $value);
				}
			      $object->setHost($machine);
			      $objects[] = & $object;
			      unset($object);
			      
			      // add partition objects
			      foreach($parts as $key => $obj)
			      {
				      $objects[] = & $parts[$key];			      	
			      }
			      
			    }
			  
			}

		}

		return $objects;
	}


}

?>
