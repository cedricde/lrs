<?php

/**
 * This class contains all informations about fields order in a CSV file.
 * 
 * @author Maxime Wojtczak (Linbox FAS)
 */
class CsvVersion
{
	var $m_Fields;
	var $m_Directory;
	var $m_Version;
	
	/**
	 * Gets the directory where CSV files are stored.
	 * 
	 * @return The directory.
	 */
	function getDirectory()
	{
		return $this->m_Directory;
	}

	/**
	 * Sets the directory where CSV files are stored.
	 * 
	 * @param directory The directory to set.
	 */
	function setDirectory($directory)
	{
		$this->m_Directory = $directory;
	}
	
	/**
	 * Returns the number of fields in the currently defined CSV file.
	 * 
	 * @return The number of fields.
	 */
	function getFieldCount()
	{
		// because some fields remains unused, we need to find the higher index in order to get the field count
		$max = -1;
		
		foreach ($this->m_Fields as $index => $value )
		
			if ( $index>$max )
				$max = $index;
		
		return $max+1;
	}
	
	/**
	 * Gets the field name at a given index.
	 * 
	 * @param index The index of the field to get.
	 * @return The field name.
	 */
	function getField($index)
	{
		if ( empty($this->m_Fields[$index]) )
			return '';

		return $this->m_Fields[$index];
	}
	
	/**
	 * Sets the field name at a given index.
	 * 
	 * @param index The index of the field.
	 * @param value The field name to set.
	 */
	function setField($index,$value)
	{
		$this->m_Fields[$index] = $value;
	}
	
	/**
	 * Sets the version of the currently defined CSV file.
	 * 
	 * @param version The new version number to set.
	 */
	function setVersion($version)
	{
		$this->m_Version = $version;
	}
	
	/**
	 * Gets the version number of the currently defined CSV file.
	 * 
	 * @return The version number.
	 */
	function getVersion()
	{
		return $this->m_Version;
	}
	
	function toString()
	{
		$string = 'Version '. $this->m_Version .' [';
		
		for ( $i=0 ; $i<$this->getFieldCount() ; $i++ )
			$string .= ( $i>0 ? ';' : '' ) . $this->getField($i);
		
		$string .= ']';
		
		return $string;
	}

}
 
?>