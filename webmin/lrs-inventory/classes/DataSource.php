<?php
/**
 * The DataSource class is used each time a data access is required. It provides fully independant data access methods to data sources.
 * All these data sources can be configured through the DataSource.conf configuration file.
 *
 * @author Maxime Wojtczak (Linbox FAS)
 */

include_once('configuration.php');
include_once('DataSourceConfiguration.php');
include_once('Components/Inventory.php');

class DataSource
{
	var $m_Instance;

	var $m_Default;
	var $m_Sources;
	var $m_SourceConfigurations;

	/**
	 * Constructor. Creates a DataSource object.
	 */
	function DataSource()
	{
		global $INCLUDE_PATH, $DATASOURCECONFIGURATION;
		
		$this->m_Sources = array();
		$this->m_SourceConfigurations = DataSourceConfiguration::loadFromFile($DATASOURCECONFIGURATION);
	}
	
	/**
	 * Returns a reference the DataSource object that should be used for each data read and write access. Singleton.
	 * 
	 * @return A unique DataSource object.
	 */
	function & getDefaultDataSource()
	{
		static $defaultdatasource;
		
		if ( !isset($defaultdatasource) )
			$defaultdatasource = new DataSource();
			
		return $defaultdatasource;
	}

	/**
	 * Returns the driver associated to the given source.
	 * 
	 * @param sourcename The source name to get the driver.
	 * @return A Driver derivated object.
	 */
	function & getSourceDriver($sourcename)
	{
		debug('Call to DataSource::getSourceDriver');

		global $INCLUDE_PATH;

		if ( empty($sourcename) )

			$sourcename = 'Default';

		// If the driver hasn't been yet loaded.
		if (  ! array_key_exists($sourcename, $this->m_Sources) )
		{
			$sourceconfiguration = & $this->m_SourceConfigurations;

			// If the source name doesn't exist
			if ( ! $sourceconfiguration->isSource($sourcename) )

				die ("$sourcename is not defined.");

			// Load the file containing the driver code
			$drivername = $sourceconfiguration->getType($sourcename);
			$includefile = $INCLUDE_PATH .'Drivers/'. $drivername .'/'. $drivername .'Driver.php';
			include_once($includefile);
			
			debug('Driver loaded');
			
			// Create the driver
			$driverclass = "${drivername}Driver";
			$driver = new $driverclass($sourcename, $sourceconfiguration->getParameters($sourcename) );

			$this->m_Sources[$sourcename] = & $driver;
		}
		
		return $this->m_Sources[$sourcename];
	}

	/**
	 * Returns the driver that should be used by default.
	 * 
	 * @return A Driver-derivated object.
	 */
	function & getDefaultSourceDriver()
	{
		return $this->getSourceDriver('');
	}
	
	/**
	 * Read object in a given type, machine, date on a given source.
	 * 
	 * @param type Type of object to read.
	 * @param machine Hosting machine.
	 * @param date Inventory date.
	 * @param source Source name
	 */
	function & read($type,$machines='',$date='',$source='')
	{
		global $datasource;

		$datasource->loadComponentClass($type);

		// If no source has been specified
		if ( empty($source) )
			// Use the default source driver
			$driver = & $this->getDefaultSourceDriver();

		else
			// Else load the right driver
			$driver = & $this->getSourceDriver($source);

		// Test if it is a real driver
		if ( ! is_subclass_of($driver,'Driver') )
			die('Not a driver');
			
		if ( !empty($machines) )
		{
			if ( !is_array($machines) )
			{
				$machinestoread = array();
				$machinestoread[] = &$machines;
			}	
			else
			
				$machinestoread = &$machines;

		}
		
		// Then read from it
		$data = & $driver->readComponentToTable($type,$machinestoread,$date);
		
		return $data;
	}
	
	/**
	 * 
	 */
	function & readMachine($machine='',$date='',$source='')
	{
		debug('Call to DataSource::readMachine');
		
		// If no source has been specified
		if ( empty($source) )
			// Use the default source driver
			$driver = & $this->getDefaultSourceDriver();

		else
			// Else load the right driver
			$driver = & $this->getSourceDriver($source);
			
		// Test if it is a real driver
		if ( ! is_subclass_of($driver,'Driver') )
			die('Not a driver');

		if ( !empty($machine) )
		
			if (!is_array($machine) )
		
				$machine = array($machine);

		// Then read machines from it
		$data = & $driver->readMachineToTable($machine,$date);
		
		return $data;
	}
	
	/**
	 * Write objects in the given data source.
	 * 
	 * @param objects One or more objects to write (can be either the object or an array of objects).
	 * @param source The source name.
	 */
	function write(&$objects,$source='')
	{
		debug('Call to DataSource::write');
		
		if ( ! is_array($objects) )
			$objects = array($objects);

		if ( empty($source) )
			$driver = & $this->getDefaultSourceDriver();
		else
			$driver = & $this->getSourceDriver($source);

		if ( ! is_subclass_of($driver,'Driver') )
			die('Not a driver');

		if ( count($objects)>0 )
			$driver->write($objects);

	}

	function & readCustomFields(&$machine,$source='')
	{
		debug('Call to DataSource::readCustomFields');

		if ( empty($source) )
			$driver = & $this->getDefaultSourceDriver();
		else
			$driver = & $this->getSourceDriver($source);

		$customfields = & $driver->readCustomFields($machine);
		
		return $customfields;
	}
	
	function saveCustomFields(&$machine,$source='')
	{
		debug('Call to DataSource::saveCustomFields');

		if ( empty($source) )
			$driver = & $this->getDefaultSourceDriver();
		else
			$driver = & $this->getSourceDriver($source);
			
		$driver->saveCustomFields($machine);
	}
	
	function loadComponentClass($classname)
	{
		debug('DataSource::loadComponentClass');

		global $INCLUDE_PATH;

		include_once($INCLUDE_PATH .'Components/'. $classname .'.php');
	}

}

?>
