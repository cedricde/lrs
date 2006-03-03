<?php

include_once('Object.php');

/**
 * A Component is a hardware or software object representation which is contained in a computer. The aim of such a class is to make it easy to identify this handling computer.
 *
 * @author Maxime Wojtczak (Linbox FAS)
 */
class Component extends Object
{
	/**
	 * The host is the machine handling the current component.
	 */
	var $m_Host;

	/**
	 * Returns the hosting computer of the current component.
	 * @return Hosting computer
	 */

	function & getHost()
	{		
		return $this->m_Host;
	}
	
	function setHost(&$host)
	{
		$this->m_Host = & $host;
	}

}

?>