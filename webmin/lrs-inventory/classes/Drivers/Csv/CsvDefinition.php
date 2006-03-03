<?php

include_once('CsvVersion.php');

/**
 * The CsvDefinition class contains all informations about CSV fields, including their name, order, path, etc. A automated detection of the CSV version is also available.
 * 
 * @author Maxime Wojtczak (Linbox FAS)
 */
class CsvDefinition
{
	var $m_DefaultVersion;
	var $m_Directory;
	var $m_Type;
	var $m_Versions;
	
	/**
	 * The definition type and directory where to find the definition XML files should be passed as constructor arguments.
	 * 
	 * @param type The type of definition to load.
	 * @param directory The path where to find the definition file.
	 */
	function CsvDefinition($type='',$directory='')
	{
		$this->m_Type = $type;
		$this->m_Directory = $directory;		
		$this->m_Versions = array();
	}
	
	/**
	 * Returns the type defined by the current CsvDefinition object.
	 * 
	 * @return Type name.
	 */
	function getType()
	{
		return $this->m_Type;
	}
	
	/**
	 * Sets the type of the current CsvDefinition object.
	 * 
	 * @param type The new type to set.
	 */
	function setType($type)
	{
		$this->m_Type = $type;
	}

	/**
	 * If differents versions of the same type are availables, then getDefaultVersion returns the default version to use for storage.
	 * 
	 * @return A reference to the default CsvVersion.
	 */	
	function & getDefaultVersion()
	{
		return $this->m_DefaultVersion;
	}
	
	/**
	 * Explicitly sets the default version to use.
	 * 
	 * @param defaultversion The new default version.
	 */
	function setDefaultVersion($defaultversion)
	{
		$this->m_DefaultVersion = $defaultversion;
	}
	
	function & getVersions()
	{
		return $this->m_Versions;
	}
	
	/**
	 * This method can be used to detect the version of a CSV file. Thanks to the storage directory and field count, the method searchs for the correct version.
	 * 
	 * @param directory The directory where is stored the file.
	 * @param fieldcount The number of field of a CSV file line.
	 * @return A reference to the most accurate CsvVersion object. If no correct version can be found, then it returns the default CsvVersion.
	 */
	function & detectVersion($directory, $fieldcount=-1)
	{
		foreach ( $this->m_Versions as $version )
		{

			// If no fieldcount has been given
			if ( $fieldcound==-1 )
			{
				// then use a directory-based detection
				if ( $version->getDirectory()==$directory )
					return $version;
			}		
			else
			{
				// else rely on the fieldcount
				if ( $version->getFieldCount()==$fieldcount )
					return $version;
			}

		}
		
		// If no full-match version has been found, then return the default version.
		return $this->getDefaultVersion();
	}
	
	/**
	 * Tells if the directory given can contain Csv file of the current definition.
	 * 
	 * @param directory The directory to test
	 * @return True if the directory can contain file of the current definition, false otherwise.
	 */
	function containDirectory($directory)
	{
		debug("Appel containDirectory");
		foreach ( $this->m_Versions as $version )
		{
			$dir = $version->getDirectory();

			if ( $version->getDirectory()==$directory )

				return true;
				
		}

		return false;
	}
	
	/**
	 * Loads a CSV definition file and creates the corresponding CsvDefinition object.
	 * 
	 * @param filename The name of the file to load.
	 */
	function & loadFromFile($filename)
	{
		$definition = new CsvDefinition();

		// Preparing global variables
		$GLOBALS['currentstate'] = '';
		$GLOBALS['currentid'] = '';
		$GLOBALS['definition'] = & $definition;

		// Then begin to parse the XML content
		$xml_parser = xml_parser_create();

		xml_parser_set_option($xml_parser, XML_OPTION_CASE_FOLDING, true);
		xml_parser_set_option($xml_parser, XML_OPTION_SKIP_WHITE, true);
		
		xml_set_element_handler($xml_parser, 'startElement', 'endElement');
		xml_set_character_data_handler($xml_parser, 'characterData');

		if ( $fp = fopen($filename, "r") )
		{
			while ( $data = fgets($fp, 4096) )
				xml_parse($xml_parser, $data);

			fclose($fp);
		}

		xml_parser_free($xml_parser);

		// Sets an arbitrary choosen CsvVersion as the default one if none has been specified
		if	(
				empty($definition->m_DefaultVersion)
				&& count($definition->m_Versions)>0
			)

			$definition->setDefaultVersion( & $definition->m_Versions[0] );
			
		unset($GLOBALS['currentstate']);
		unset($GLOBALS['currentid']);
		unset($GLOBALS['definition']);
		
		return $definition;
	}
	
	/**
	 * Return the current CSV definition in String format.
	 * 
	 * @return A String describing the current object.
	 */
	function toString()
	{
		$string = $this->m_Type .' [';
		
		for ( $i=0 ; $i<count($this->m_Versions) ; $i++ )
			$string .= ( $i>0 ? ';' : '' ) . $this->m_Versions[$i]->toString();
		
		$string .= ']';
		
		return $string;
	}

}




/**
 * Function used for XML parsing.
 */
function startElement($parser, $name, $attrs)
{
	$definition = & $GLOBALS['definition'];

	// If it is a new version
	if ( $name=='VERSION' )
	{
		// Create the object with version number and default informations
		$version = new CsvVersion();
		$definition->m_Versions[] = & $version;
		
		if (array_key_exists('NUMBER',$attrs))
			$version->setVersion($attrs['NUMBER']);

		if (array_key_exists('DEFAULT',$attrs) && $attrs['DEFAULT']=='yes')
			$definition->m_DefaultVersion = & $definition->m_Versions[ count($definition->m_Versions)-1 ] ;

	}
	else if ( $name=='FIELD' && array_key_exists('INDEX',$attrs) )
	{
		$GLOBALS['currentstate'] = 'infield';
		$GLOBALS['currentid'] = $attrs['INDEX'];
	}
	else if ( $name=='TYPE' )
	{
		$GLOBALS['currentstate'] = 'intype';
	}
	else if ( $name=='DIRECTORY' )
	{
		$GLOBALS['currentstate'] = 'indirectory';
	}
}

/**
 * Function used for XML parsing.
 */
function endElement($parser, $name)
{
}

/**
 * Function used for XML parsing.
 */
function characterData($parser, $data)
{
	$definition = & $GLOBALS['definition'];

	if ( count($definition->m_Versions)>0 )
		$version = & $definition->m_Versions[count($definition->m_Versions)-1];

	if ( $GLOBALS['currentstate']=='infield' )
		$version->setField($GLOBALS['currentid'],$data);

	else if ( $GLOBALS['currentstate']=='intype' )
		$definition->setType($data);
	
	else if ( $GLOBALS['currentstate']=='indirectory' )
		$version->setDirectory($data);
		
	$GLOBALS['currentstate'] = '';
}



?>