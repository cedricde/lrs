<?php

include_once('Component.php');

/**
 * Slot class contains all informations about one's machine slot.
 *
 * @author Maxime Wojtczak (Linbox FAS)
 */
class Slot extends Component
{
	function Slot()
	{
		$this->m_Properties = array(	
			'Connector'=>'' , 
			'PortType'=>'' ,
			'Availability'=>'' ,
			'State'=>'' );
	}

	/**
	 * Returns the connector of the current slot.
	 * 
	 * @return The connector
	 */
	function getConnector()
	{
		return $this->getProperty('Connector');
	}

	/**
	 * Sets a new value of the connector of the current slot.
	 * 
	 * @param connector The connector value to set.
	 */
	function setConnector($connector)
	{
		$this->setProperty('Connector',$connector);
	}

	/**
	 * Returns the port type of the current slot.
	 * 
	 * @return The port type
	 */
	function getPortType()
	{
		return $this->getProperty('PortType');
	}

	/**
	 * Sets a new value of the port type of the current slot.
	 * 
	 * @param porttype The port type value to set.
	 */
	function setPortType($porttype)
	{
		$this->setProperty('PortType',$porttype);
	}

	/**
	 * Returns the availabality of the current slot.
	 * 
	 * @return The availabality
	 */
	function getAvailabality()
	{
		return $this->getProperty('Availabality');
	}

	/**
	 * Sets a new value of the availabality of the current slot.
	 * 
	 * @param availabality The availabality value to set.
	 */
	function setAvailabality($availabality)
	{
		$this->setProperty('Availabality',$availabality);
	}

	/**
	 * Returns the state of the current slot.
	 * 
	 * @return The state
	 */
	function getState()
	{
		return $this->getProperty('State');
	}

	/**
	 * Sets a new value of the state of the current slot.
	 * 
	 * @param state The state value to set.
	 */
	function setState($state)
	{
		$this->setProperty('State',$state);
	}

}

?>