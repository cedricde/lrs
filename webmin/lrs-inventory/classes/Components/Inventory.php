<?php

include_once('Object.php');

/**
 * Inventory class contains all informations about an Inventory.
 *
 * @author Maxime Wojtczak (Linbox FAS)
 */
class Inventory extends Object
{
	/**
	 * Creates a new Inventory object.
	 * 
	 * @param date The date of the inventory.
	 */
	function Inventory($date='', $time='')
	{
		parent::Object();

		if ( empty($date) )
			$date = date('Y-m-d');

		if ( empty($time) )
			$time = date('H:i:s');
			
		$this->setDate($date);
		$this->setTime($time);
		
	}

	/**
	 * Returns the date of the current inventory.
	 * 
	 * @return The date of the inventory.
	 */
	function getDate()
	{
		return $this->getProperty('Date');
	}

	/**
	 * Sets the date of the current inventory.
	 * 
	 * @param date The date of the inventory.
	 */
	function setDate($date)
	{
		$this->setProperty('Date',$date);
	}

	/**
	 * Returns the time of the current inventory.
	 * 
	 * @return The time of the inventory.
	 */
	function getTime()
	{
		return $this->getProperty('Time');
	}

	/**
	 * Sets the time of the current inventory.
	 * 
	 * @param time The time of the inventory.
	 */
	function setTime($time)
	{
		$this->setProperty('Time',$time);
	}

}

?>