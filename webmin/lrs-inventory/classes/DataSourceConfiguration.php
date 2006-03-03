<?php

/**
 * The DataSourceConfiguration class contains all informations about the types and parameters of drivers used by the inventory module.
 * 
 * @author Maxime Wojtczak (Linbox FAS)
 */
class DataSourceConfiguration
{
	var $m_Parameters;
	var $m_Types;

	function DataSourceConfiguration()
	{
		$this->m_Parameters = array();
		$this->m_Types = array();
	}
	
	function & getParameters($sourcename)
	{
		if ( array_key_exists($sourcename, $this->m_Parameters) && is_array($this->m_Parameters[$sourcename]) )
		
			return $this->m_Parameters[$sourcename];
			
		return array();
	}
	
	function setParameters($sourcename, $parameters)
	{
		$this->m_Parameters[$sourcename] = & $parameters;
	}
	
	function getType($sourcename)
	{
		return $this->m_Types[$sourcename];
	}
	
	function setType($sourcename, $type)
	{
		$this->m_Types[$sourcename] = $type;
	}
	
	function isSource($sourcename)
	{
		return array_key_exists($sourcename, $this->m_Types);
	}

	/**
	 * Loads a Data Source Configuration object from a XML file.
	 * 
	 * @param filename The name of the file to load.
	 */
	function & loadFromFile($filename)
	{
		$dsc = new DataSourceConfiguration();

		// Preparing global variables
		$GLOBALS['dsc'] = & $dsc;
		$GLOBALS['level'] = 0;

		// Then begin to parse the XML content
		$xml_parser = xml_parser_create();

		xml_parser_set_option($xml_parser, XML_OPTION_CASE_FOLDING, true);
		xml_parser_set_option($xml_parser, XML_OPTION_SKIP_WHITE, true);
		
		xml_set_element_handler($xml_parser, 'startElementDSC', 'endElementDSC');
		xml_set_character_data_handler($xml_parser, 'characterDataDSC');

		if ( $fp = @fopen($filename, "r") )
		{
			while ( $data = fread($fp, 4096) )
				xml_parse($xml_parser, $data);

			fclose($fp);
		}

		xml_parser_free($xml_parser);

		unset($GLOBALS['dsc']);
		unset($GLOBALS['level']);
		
		return $dsc;
	}
}



/**
 * Function used for XML parsing.
 */
function startElementDSC($parser, $name, $attrs)
{
	$dsc = & $GLOBALS['dsc'];
	$level = ++$GLOBALS['level'];
	
	$state = & $GLOBALS['currentstate'];

	$type = & $GLOBALS['currenttype'];
	$parameters = & $GLOBALS['currentparameters'];
	$sourcename = & $GLOBALS['currentsourcename'];

	
	if ( $level==2 && $name=='DATASOURCE' )
	{
		$parameters = array();
		$type = '';
		$sourcename = '';
	}

	if ( $level==3 && $name=='NAME' )
		$state = 'SourceName';

	if ( $level==3 && $name=='TYPE' )
		$state = 'Type';
		
	if ( $level==4 && $name=='PARAMETER' )
	{
		$state = 'Parameter';
		$GLOBALS['paramname'] = $attrs['NAME'];
	}
}

/**
 * Function used for XML parsing.
 */
function endElementDSC($parser, $name)
{
	$dsc = & $GLOBALS['dsc'];
	$level = & $GLOBALS['level'];
	
	$state = & $GLOBALS['currentstate'];

	$type = & $GLOBALS['currenttype'];
	$parameters = & $GLOBALS['currentparameters'];
	$sourcename = & $GLOBALS['currentsourcename'];
	
	if ( $level==2 && $name=='DATASOURCE' )
	{
		$dsc->m_Parameters[$sourcename] = $parameters;
		$dsc->m_Types[$sourcename] = $type;
	}
	
	$level--;
}

/**
 * Function used for XML parsing.
 */
function characterDataDSC($parser, $data)
{
	$dsc = & $GLOBALS['dsc'];
	$level = $GLOBALS['level'];
	
	$state = & $GLOBALS['currentstate'];

	$type = & $GLOBALS['currenttype'];
	$parameters = & $GLOBALS['currentparameters'];
	$sourcename = & $GLOBALS['currentsourcename'];

	switch ($state)
	{
		case 'SourceName' :
			$sourcename = $data;
			$state = '';
			break;

		case 'Type' :
			$type = $data;
			$state = '';
			break;
			
		case 'Parameter' :
			$parameters[ $GLOBALS['paramname'] ] = $data;
			unset($GLOBALS['paramname']);
			$state = '';
			break;
	}

}



?>
