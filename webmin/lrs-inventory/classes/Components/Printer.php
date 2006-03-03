<?php

include_once('Component.php');

/**
 * Printer class contains all informations about one's machine printer.
 *
 * @author Maxime Wojtczak (Linbox FAS)
 */
class Printer extends Component
{
	function Printer()
	{
		$this->m_Properties = array(	'Name'=>'' , 
										'Driver'=>'' ,
										'Port'=>'' );
	}

	/**
	 * Returns the name of the current printer.
	 * 
	 * @return The name
	 */
	function getName()
	{
		return $this->getProperty('Name');
	}

	/**
	 * Sets a new value of the name of the current printer.
	 * 
	 * @param name The name value to set.
	 */
	function setName($name)
	{
		$this->setProperty('Name',$name);
	}

	/**
	 * Returns the driver of the current printer.
	 * 
	 * @return The driver
	 */
	function getDriver()
	{
		return $this->getProperty('Driver');
	}

	/**
	 * Sets a new value of the driver of the current printer.
	 * 
	 * @param driver The driver value to set.
	 */
	function setDriver($driver)
	{
		$this->setProperty('Driver',$driver);
	}

	/**
	 * Returns the port of the current printer.
	 * 
	 * @return The port
	 */
	function getPort()
	{
		return $this->getProperty('Port');
	}

	/**
	 * Sets a new value of the port of the current printer.
	 * 
	 * @param port The port value to set.
	 */
	function setPort($port)
	{
		$this->setProperty('Port',$port);
	}

}

?>