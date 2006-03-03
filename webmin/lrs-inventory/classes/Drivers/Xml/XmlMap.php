<?php

/**
 * The XmlMap class allows XmlDriver to map tags from the original OCS Inventory XML files to object fields compliant to the inventory module.
 * 
 * @author Maxime Wojtczak (Linbox FAS)
 */
class XmlMap
{
	var $m_MappedObjects;
	var $m_MappedFields;
	var $m_ReverseObjects;
	var $m_ReverseFields;

	/**
	 * Constructor. Parse the XML file given in parameter.
	 * 
	 * @param mapfile XML file to parse.
	 */
	function XmlMap($mapfile)
	{
		$this->m_MappedFields = array();
		$this->m_MappedObjects = array();
		$this->m_ReverseFields = array();
		$this->m_ReverseObjects = array();

		$filehandle = fopen($mapfile, 'r');
		
		if ( $filehandle )
		{			
			$xml_parser = xml_parser_create();

			xml_parser_set_option($xml_parser, XML_OPTION_CASE_FOLDING, true);
			xml_parser_set_option($xml_parser, XML_OPTION_SKIP_WHITE, true);

			xml_set_element_handler($xml_parser, 'startElementXmlMap', 'endElementXmlMap');

			$GLOBALS['CURRENT_OBJECT'] = '';
			$GLOBALS['CURRENT_MAP'] = & $this;


			while ( !feof($filehandle) )		
				xml_parse($xml_parser, fgets($filehandle, 512) );
			
			fclose($filehandle);

			xml_parser_free($xml_parser);
		}
		else

			die("Unable to open \"$mapfile\" map file.");
		
		debug($this);

	}
	
	/**
	 * Sets the class name corresponding to a tag.
	 * 
	 * @param tag Tag name that can be found in XML file.
	 * @param mappedclass Class name corresponding to the tag.
	 */
	function setClass($tag,$mappedclass)
	{
		$this->m_MappedObjects[$tag] = $mappedclass;
		$this->m_ReverseObjects[$mappedclass] = $tag;
		$this->m_ReverseObjects[ strtolower($mappedclass) ] = $tag;
	}
	
	/**
	 * Returns the class name corresponding to the given tag.
	 * 
	 * @param tag Tag name.
	 * @return The corresponding class name.
	 */
	function getClass($tag)
	{
		return $this->m_MappedObjects[$tag];
	}
	
	/**
	 * Returns the tag corresponding to the class name given in parameter.
	 * 
	 * @param class The class name.
	 * @return The tag name.
	 */
	function getReverseClass($class)
	{
		return $this->m_ReverseObjects[$class];
	}
	
	/**
	 * Sets the object field corresponding to the tag name.
	 * 
	 * @param tag The tag name (the one corresponding to the class name).
	 * @param field The field name in the XML.
	 * @param mappedfield The object field name.
	 */
	function setField($tag, $field, $mappedfield)
	{
		$this->m_MappedFields[$tag][$field] = $mappedfield;
		$this->m_ReverseFields[$tag][$mappedfield] = $field;
	}
	
	/**
	 * Gets the object field name.
	 * 
	 * @param tag The tag name (the one corresponding to the class name).
	 * @param field The XML field name.
	 * @return The object field name.
	 */
	function getField($tag, $field)
	{
		return $this->m_MappedFields[$tag][$field];
	}
	
	/**
	 * Gets the XML field name.
	 * 
	 * @param tag The tag name (the one corresponding to the class name).
	 * @param field The object field name.
	 * @return The XML field name.
	 */
	function getReverseField($tag, $field)
	{
		return $this->m_ReverseFields[$tag][$field];
	}
}




	/**
	 * Function used for XML parsing.
	 */
	function startElementXmlMap($parser, $name, $attrs)
	{
		$xmlmap = & $GLOBALS['CURRENT_MAP'];

		switch ($name)
		{
			case 'MAPPEDOBJECT':
				$GLOBALS['CURRENT_OBJECT'] = $attrs['NAME'];
				$xmlmap->setClass( $attrs['NAME'],$attrs['CLASS'] );
				break;

			case 'MAPPEDFIELD':
				$xmlmap->setField( $GLOBALS['CURRENT_OBJECT'],$attrs['FROM'],$attrs['TO'] );
				break;
		}
	}
	
	/**
	 * Function used for XML parsing.
	 */
	function endElementXmlMap($parser, $name)
	{
	}

?>
