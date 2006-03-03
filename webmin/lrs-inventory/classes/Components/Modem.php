<?php

include_once('Component.php');

/**
 * Modem class contains all informations about one's machine modem.
 *
 * @author Maxime Wojtczak (Linbox FAS)
 */
class Modem extends Component
{
	function Modem()
	{
		$this->m_Properties = array(	'Vendor'=>'' , 
										'Description'=>'' ,
										'Type'=>'' );
	}
	
	/**
	 * Returns the vendor of the current modem.
	 * 
	 * @return The vendor
	 */
	function getVendor()
	{
		return $this->getProperty('Vendor');
	}

	/**
	 * Sets a new value of the vendor of the current modem.
	 * 
	 * @param vendor The vendor value to set.
	 */
	function setVendor($vendor)
	{
		$this->setProperty('Vendor',$vendor);
	}

	/**
	 * Returns the description of the current modem.
	 * 
	 * @return The description
	 */
	function getDescription()
	{
		return $this->getProperty('Description');
	}

	/**
	 * Sets a new value of the description of the current modem.
	 * 
	 * @param description The description value to set.
	 */
	function setDescription($description)
	{
		$this->setProperty('Description',$description);
	}

	/**
	 * Returns the type of the current modem.
	 * 
	 * @return The type
	 */
	function getType()
	{
		return $this->getProperty('Type');
	}

	/**
	 * Sets a new value of the type of the current modem.
	 * 
	 * @param type The type value to set.
	 */
	function setType($type)
	{
		$this->setProperty('Type',$type);
	}

}

?>