<?php

include_once('Component.php');

/**
 * Monitor class contains all informations about one's machine monitor.
 *
 * @author Maxime Wojtczak (Linbox FAS)
 */
class Monitor extends Component
{
	function Monitor()
	{
		$this->m_Properties = array(	'Stamp'=>'' , 
										'Description'=>'' ,
										'Type'=>'' );
	}

	/**
	 * Returns the stamp of the current monitor.
	 * 
	 * @return The stamp
	 */
	function getStamp()
	{
		return $this->getProperty('Stamp');
	}

	/**
	 * Sets a new value of the stamp of the current monitor.
	 * 
	 * @param stamp The stamp value to set.
	 */
	function setStamp($stamp)
	{
		$this->setProperty('Stamp',$stamp);
	}

	/**
	 * Returns the description of the current monitor.
	 * 
	 * @return The description
	 */
	function getDescription()
	{
		return $this->getProperty('Description');
	}

	/**
	 * Sets a new value of the description of the current monitor.
	 * 
	 * @param description The description value to set.
	 */
	function setDescription($description)
	{
		$this->setProperty('Description',$description);
	}

	/**
	 * Returns the type of the current monitor.
	 * 
	 * @return The type
	 */
	function getType()
	{
		return $this->getProperty('Type');
	}

	/**
	 * Sets a new value of the type of the current monitor.
	 * 
	 * @param type The type value to set.
	 */
	function setType($type)
	{
		$this->setProperty('Type',$type);
	}

}

?>