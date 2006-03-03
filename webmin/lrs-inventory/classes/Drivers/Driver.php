<?php

include_once($INCLUDE_PATH .'Components/Object.php');

/**
 * The Driver class is the base class for all implemented drivers. All derivated drivers should at least override read and write methods to perform storage and read access.
 * 
 * @author Maxime Wojtczak (Linbox FAS)
 */
class Driver
{
	var $m_Source;
	
	function Driver($source)
	{
		$this->m_Source = $source;
	}

	/**
	 * Read one or more object of the type given in parameter, registered on the specified date.
	 * 
	 * @param type The object type to read.
	 * @param machine The owner machine.
	 * @param date The object registered on this date (Optional). If no date is specified, then date is set to the latest update date.
	 * 
	 * @return A Parser containing all read objects.
	 */	
	function & read($type,$machine,$date='')
	{
		global $INCLUDE_PATH;

		include_once($INCLUDE_PATH .'Components/'. $type .'.php');
	}

	/**
	 * Machine-dedicated read method.
	 * 
	 * @param machine An array of the machine names and/or machine MAC addresses to get.
	 * @param date The date of the inventory.
	 * @return a Sql Parser object.
	 */
	function & readMachine($machine='', $date='')
	{
		global $INCLUDE_PATH;

		include_once($INCLUDE_PATH .'Components/Machine.php');
	}

	/**
	 * Reads all the custom fields of the given machine. Custom fields are both retrieved and filled into the machine object.
	 * 
	 * @param machine The machine to get the custom fields.
	 *
	 * @return The custom fields in an array.
	 */	
	function & readCustomFields(&$machine)
	{
		return array();
	}
	
	/**
	 * Saves all the custom fields of the given machine.
	 * 
	 * @param machine The machine containing the custom fields to save
	 */
	function saveCustomFields(&$machine)
	{
	}

	/**
	 * Write the object array passed in parameter.
	 * 
	 * @param object The object or object array to write.
	 */
	function write($objects)
	{
	}
	
	/**
	 * IsWritable informs if an object can be written through the Driver system.
	 * 
	 * @param object Object to test.
	 * 
	 * @return Returns true if the object is writable.
	 */
	function isWritable($object)
	{
		return is_subclass_of($object, "Object");
	}
	
	/**
	 * Gets the source name for which the driver has been created.
	 * 
	 * @return The source name.
	 */
	function getSource()
	{
		return $this->m_Source;
	}
	
	/**
	 * Sets the source name for which the driver has been created.
	 */
	function setSource($source)
	{
		$this->m_Source = $source;
	}
}

?>