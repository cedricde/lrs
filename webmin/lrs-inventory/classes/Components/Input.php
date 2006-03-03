<?php

include_once('Component.php');

/**
 * Input class contains all informations about one's machine input.
 *
 * @author Maxime Wojtczak (Linbox FAS)
 */
class Input extends Component
{
	function Input()
	{
		$this->m_Properties = array(	'Type'=>'' , 
										'StandardDescription'=>'' ,
										'ExpandedDescription'=>'' ,
										'Connector'=>'' );
	}
	
	/**
	 * Returns the type of the current input.
	 * 
	 * @return The vendor
	 */
	function getType()
	{
		return $this->getProperty('Type');
	}

	/**
	 * Sets a new value of the type of the current input.
	 * 
	 * @param type The type value to set.
	 */
	function setType($type)
	{
		$this->setProperty('Type',$type);
	}

	/**
	 * Returns the standard description of the current input.
	 * 
	 * @return The standard description
	 */
	function getStandardDescription()
	{
		return $this->getProperty('StandardDescription');
	}

	/**
	 * Sets a new value of the standard description of the current input.
	 * 
	 * @param standarddescription The standard description value to set.
	 */
	function setStandardDescription($standarddescription)
	{
		$this->setProperty('StandardDescription',$standarddescription);
	}

	/**
	 * Returns the expanded description of the current input.
	 * 
	 * @return The expanded description
	 */
	function getExpandedDescription()
	{
		return $this->getProperty('ExpandedDescription');
	}

	/**
	 * Sets a new value of the expanded description of the current input.
	 * 
	 * @param expandeddescription The expanded description value to set.
	 */
	function setExpandedDescription($expandeddescription)
	{
		$this->setProperty('ExpandedDescription',$expandeddescription);
	}

	/**
	 * Returns the connector of the current input.
	 * 
	 * @return The connector
	 */
	function getConnector()
	{
		return $this->getProperty('Connector');
	}

	/**
	 * Sets a new value of the connector of the current input.
	 * 
	 * @param connector The connector value to set.
	 */
	function setConnector($connector)
	{
		$this->setProperty('Connector',$connector);
	}

}

?>