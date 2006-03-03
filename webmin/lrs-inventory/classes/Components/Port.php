<?php

include_once('Component.php');

/**
 * Port class contains all informations about one's machine port.
 *
 * @author Maxime Wojtczak (Linbox FAS)
 */
class Port extends Component
{
	function Port()
	{
		$this->m_Properties = array(	'Stamp'=>'' , 
										'Type'=>'' );
	}

	/**
	 * Returns the stamp of the current port.
	 * 
	 * @return The stamp
	 */
	function getStamp()
	{
		return $this->getProperty('Stamp');
	}

	/**
	 * Sets a new value of the stamp of the current port.
	 * 
	 * @param stamp The stamp value to set.
	 */
	function setStamp($stamp)
	{
		$this->setProperty('Stamp',$stamp);
	}

	/**
	 * Returns the type of the current port.
	 * 
	 * @return The type
	 */
	function getType()
	{
		return $this->getProperty('Type');
	}

	/**
	 * Sets a new value of the type of the current port.
	 * 
	 * @param type The type value to set.
	 */
	function setType($type)
	{
		$this->setProperty('Type',$type);
	}

}

?>