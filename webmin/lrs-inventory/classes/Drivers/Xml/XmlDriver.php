<?php

include_once($INCLUDE_PATH .'Drivers/Driver.php');
include_once($INCLUDE_PATH .'Components/Inventory.php');
include_once('XmlMap.php');

/**
 * The XmlDriver class is a Driver-derivated class aiming at reading data from XML files.
 * 
 * @author Maxime Wojtczak (Linbox FAS)
 */
class XmlDriver extends Driver
{
	var $m_MappedFields;
	var $m_DataPath;
	var $m_UTF8 = false;

	function XmlDriver($source, $parameters)
	{
		parent::Driver($source);

		if ( array_key_exists('MapFile', $parameters) )

			$this->m_MappedFields = new XmlMap( $parameters['MapFile'] );
		
		$this->m_DataPath = $parameters['DataPath'];
	}

	/**
	 * Writes objects in a XML file.
	 * 
	 * @param objects An array containing all objects to store.
	 */
	function write(&$objects)
	{
		debug('Call to XmlDriver::write');

		$xml = '';
		
		$first = & $objects[0]->getHost;

		$hostname = $first->getName();

		foreach ( $objects as $object )

			$xml .= $this->getObjectXml( $object );
			
		$fileout = sprintf("%s/%s.xml", $this->m_DataPath, $hostname);

		$fh = fopen($fileout,'w');
		fputs($fh, $xml);
		fclose($fh);

		
	}

	/**
	 * Create a string in the XML format agree to the object and version given in parameter.
	 * 
	 * @param object Object to convert into CSV.
	 * @param version Version of CSV conversion.
	 * @return The CSV-formatted string.
	 */
	function getObjectXml(&$object)
	{
		debug('Call to XmlDriver::write');
		
		$first = & $objects->getHost();

		$hostname = $first->getName();
		
		$xml = '';

		$xmlmap = & $this->m_MappedFields;

		$tag = $xmlmap->getReverseClass( $object->getClassName() );
		
		$xml .= "<$tag>\n";

		foreach ( $object->getProperties() as $name => $value )
		{
			if ( !empty($value) )
			{
				$tagprop = $xmlmap->getReverseField( $tag , $name );
	
				if ( !empty($tagprop) )
					$xml .= "\t<$tagprop>$value</$tagprop>\n";
			}
		}

		$xml .= "</$tag>\n";
		
		return $xml;
	}

	/**
	 * Reads Machine object from XML file sent by POST method.
	 * 
	 * @param machines The name of the machine to read.
	 * @param inventory Ignored.
	 * @return An array of machines.
	 */
	function & readMachineToTable($machines='', $inventory='')
	{
		global $INVENTORY;
		global $datasource;

		$return = array();

		$datasource->loadComponentClass('Machine');

		// Parse the XML content into an object.
		// See the NG reception agent to see the origin of $INVENTORY variable.
		$machine = & $this->parseXmlContent($INVENTORY);

		$return[] = & $machine;

		return $return;
	}

	/**
	 * Reads components in the XML file.
	 * Because A XML file contains all informations about the machine, all components are already loaded and the method only return them.
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
		
		// Foreach machine
		for ( $i=0 ; $i<count($machines) ; $i++ )
		{
			$machine = & $machines[$i];
			
			// For each component of the machine
			for ( $j=0 ; $j<count($machine->m_Components[$type]) ; $j++ ) {
				// Only append the current component to the end of array
				$obj = & $machine->m_Components[$type][$j];
				$obj->setHost($machine);
				$objects[] = & $obj;
			}
		}
	
		return $objects;
	}
	
	/**
	 * Parse the given file into a Machine object.
	 * Because A XML file contains all informations about the machine, all components are also created.
	 * 
	 * @param file File name.
	 * @return A Machine object.
	 */
	function & parseXmlFile($file)
	{
		$machine = new Machine();

		$fh = @fopen($file);

		if ( $fh )
		{
			$parser = & $this->createParser($machine);

			while ( !feof($fh) )
			{
				$line = fgets($fh, 1024);

				xml_parse($parser, $line);
			}

			fclose($fh);
		}
		else
		
			debug("File $file not found in parseXmlFile");

		return $machine;
	}
	
	/**
	 * Parse a XML-formated content into a machine object.
	 * Once again, all sub-components are all directly created to avoid a second parsing operation of the same data.
	 * 
	 * @param content Content to parse.
	 * @return 
	 */
	function & parseXmlContent( &$content )
	{
		$machine = new Machine();

		$parser = & $this->createParser($machine);
		
		if (eregi(" encoding=.utf-8.", $content)) {
			$this->m_UTF8 = true;
		}
		
		xml_parse($parser, $content);

		xml_parser_free($parser);

		return $machine;
	}

	/**
	 * Create a parser that can be used for parsing XML content into a given machine object.
	 * 
	 * @param machine The machine objct to fill.
	 * @return A ready-to-use parser.
	 */
	function & createParser( &$machine )
	{
		// Set some global variables
		$GLOBALS['CURRENTMACHINE'] = & $machine;
		$GLOBALS['CURRENTTAG'] = '';
		$GLOBALS['CURRENTFIELD'] = '';
		$GLOBALS['CURRENTOBJECT'] = null;
		$GLOBALS['CURRENTLEVEL'] = 0;
		$GLOBALS['CURRENTXMLMAP'] = & $this->m_MappedFields;

		$parser = xml_parser_create();

		xml_parser_set_option($parser, XML_OPTION_CASE_FOLDING, true);
		xml_parser_set_option($parser, XML_OPTION_SKIP_WHITE, true);
		
		xml_set_element_handler($parser, 'startElementXmlParser', 'endElementXmlParser');
		xml_set_character_data_handler($parser, 'characterDataXmlParser');
		
		return $parser;
	}
}




	/**
	 * Function used for XML parsing.
	 */
	function startElementXmlParser($parser, $name, $attrs)
	{
		$GLOBALS['CURRENTLEVEL']++;

		//print $GLOBALS['CURRENTLEVEL'] ." : Debut $name\n";
		
		$xmlmap = & $GLOBALS['CURRENTXMLMAP'];

		//echo $GLOBALS['CURRENTLEVEL'].":$name;".$GLOBALS['CURRENTTAG'].";";
		
		switch ( $GLOBALS['CURRENTLEVEL'] )
		{
			case 2:
			
				if ( $name!='CustomFields' )
				{
					$class = $xmlmap->getClass($name);
					
					if ( empty($class) )
						$class = $name;
					
					if ( ! class_exists($class) )
					{
						global $datasource;
						@$datasource->loadComponentClass($class);
					}

					if ( class_exists($class) && $class != "Null" )
					{
						unset($GLOBALS['CURRENTOBJECT']);
						
						$object = new $class;
						
						$GLOBALS['CURRENTOBJECT'] = & $object;
	
						$machine = & $GLOBALS['CURRENTMACHINE'];

						$machine->m_Components[$class][] = & $object;
						$object->setHost(&$machine);
					}
					else
					{
						//global $datasource;
						//$datasource->loadComponentClass('Object');
						
						unset($GLOBALS['CURRENTOBJECT']);
						// = new Object();
					}
				}

				$GLOBALS['CURRENTTAG'] = $name;

				break;

			case 3:
			
				$field = $xmlmap->getField($GLOBALS['CURRENTTAG'], $name);
				
				if ( empty($field) )
				
					$field = $name;

				$GLOBALS['CURRENTFIELD'] = $field;

				break;
		}
	}
	
	/**
	 * Function used for XML parsing.
	 */
	function endElementXmlParser($parser, $name)
	{
		$GLOBALS['CURRENTLEVEL']--;
	}

	/**
	 * Function used for XML parsing.
	 */
	function characterDataXmlParser($parser, $data)
	{
exec("echo \"==D\" >>/tmp/log"); 			
		if ( trim($data) != "" && $data!='N/A' && isset($GLOBALS['CURRENTOBJECT']))
		{		
			$object = & $GLOBALS['CURRENTOBJECT'];
	
			if ($this->m_UTF8) { $data = utf8_decode($data); }
			$object->setProperty($GLOBALS['CURRENTFIELD'], $data);
	
			$machine = & $GLOBALS['CURRENTMACHINE'];

exec("echo \"==C\" >>/tmp/log"); 			
			// Sets the machine name
			if ( ($GLOBALS['CURRENTFIELD']=='Host' || $GLOBALS['CURRENTFIELD']=='NAME') && $GLOBALS['CURRENTTAG']=='HARDWARE') {
				$machine->setName($data);
			}
		}
	}
?>
