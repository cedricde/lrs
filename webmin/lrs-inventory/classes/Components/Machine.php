<?php

include_once('Object.php');

/**
 * Machine class contains all informations about one client machine.
 *
 * @author Maxime Wojtczak (Linbox FAS)
 */
class Machine extends Object
{
	var $m_Components;
	var $m_CustomFields;

	function Machine()
	{
		parent::Object();
		
		$this->m_Properties = array( 'Name' => '' );
		$this->m_CustomFields = array();
		$this->m_Components = array();
	}

	/**
	 * Returns the name of the current machine.
	 * 
	 * @return The name.
	 */
	function getName()
	{
		return $this->getProperty('Name');
	}

	/**
	 * Sets the name of the current machine.
	 * 
	 * @param name The name value to set.
	 */
	function setName($name)
	{
		$this->setProperty('Name',$name);
	}

	/**
	 * Returns all the sub-components of a given type.
	 * 
	 * @param type Type of the components to read.
	 * @return A reference to the array containing Component-derivated objects
	 */
	function & getComponents($type)
	{
		// If Components hasn't been yet loaded
		if ( ! isset($this->m_Components[$type]) )

			$this->loadComponents($type);
		
		return $this->m_Components[$type];
	}

	/**
	 * Loads all the hosted components of a given type in the current Machine
	 * 
	 * @param type Type of the components to load.
	 */
	function loadComponents($type)
	{
		if ( ! isset( $this->m_Components[$type] ) )
		{
			// read all components of the given type
			$datasource = & DataSource::getDefaultDataSource();
			
			$this->m_Components[$type] = & $datasource->read($type, $this);
		}
	}

	/**
	 * Returns the components at the given index and of type given in parameter.
	 * 
	 * @param type Type of the object to get.
	 * @param i Rank of the object to get.
	 * @return A reference to the read component.
	 */
	function & getComponent($type,$i)
	{
		// If Components hasn't been yet loaded
		if ( ! array_key_exists($type, $this->m_Components) )

			$this->loadComponents($type);

		return $this->m_Components[$type][$i];
	}
	
	/**
	 * Returns the number of components of a given type hosted by the current machine.
	 * 
	 * @param type Type of components to count.
	 */
	function getComponentCount($type)
	{
		// If Components hasn't been yet loaded
		if ( ! isset($this->m_Components[$type]) )

			$this->loadComponents($type);

		return count( $this->m_Components[$type] );
	}
	
	function setCustomField($customfield,$value)
	{
		$this->m_CustomFields[$customfield] = $value;
	}
	
	function getCustomField($customfield)
	{
		return $this->m_CustomFields[$customfield];
	}
	
	function & getCustomFields()
	{
		return $this->m_CustomFields;
	}
	
	function deleteCustomField($customfield)
	{
		unset( $this->m_CustomFields[$customfield] );
	}

	function & getBios($i)
	{
		return $this->getComponent('Bios',$i);
	}

	function & getBioss()
	{
		return $this->getComponents('Bios');
	}
	
	function getBiosCount()
	{
		return $this->getComponentCount('Bios');
	}

	function & getController($i)
	{
		return $this->getComponent('Controller',$i);
	}

	function & getControllers()
	{
		return $this->getComponents('Controller');
	}
	
	function getControllerCount()
	{
		return $this->getComponentCount('Controller');
	}

	function & getDrive($i)
	{
		return $this->getComponent('Drive',$i);
	}

	function & getDrives()
	{
		return $this->getComponents('Drive');
	}
	
	function getDriveCount()
	{
		return $this->getComponentCount('Drive');
	}

	function & getHardware($i)
	{
		return $this->getComponent('Hardware',$i);
	}

	function & getHardwares()
	{
		return $this->getComponents('Hardware');
	}
	
	function getHardwareCount()
	{
		return $this->getComponentCount('Hardware');
	}

	function & getInput($i)
	{
		return $this->getComponent('Input',$i);
	}

	function & getInputs()
	{
		return $this->getComponents('Input');
	}
	
	function getInputCount()
	{
		return $this->getComponentCount('Input');
	}

	function & getMemory($i)
	{
		return $this->getComponent('Memory',$i);
	}

	function & getMemories()
	{
		return $this->getComponents('Memory');
	}
	
	function getMemoryCount()
	{
		return $this->getComponentCount('Memory');
	}
	
	function & getModem($i)
	{
		return $this->getComponent('Modem',$i);
	}

	function & getModems()
	{
		return $this->getComponents('Modem');
	}
	
	function getModemCount()
	{
		return $this->getComponentCount('Modem');
	}

	function & getMonitor($i)
	{
		return $this->getComponent('Monitor',$i);
	}

	function & getMonitors()
	{
		return $this->getComponents('Monitor');
	}
	
	function getMonitorCount()
	{
		return $this->getComponentCount('Monitor');
	}

	function & getNetwork($i)
	{
		return $this->getComponent('Network',$i);
	}

	function & getNetworks()
	{
		return $this->getComponents('Network');
	}
	
	function getNetworkCount()
	{
		return $this->getComponentCount('Network');
	}

	function & getPort($i)
	{
		return $this->getComponent('Port',$i);
	}

	function & getPorts()
	{
		return $this->getComponents('Port');
	}
	
	function getPortCount()
	{
		return $this->getComponentCount('Port');
	}

	function & getPrinter($i)
	{
		return $this->getComponent('Printer',$i);
	}

	function & getPrinters()
	{
		return $this->getComponents('Printer');
	}
	
	function getPrinterCount()
	{
		return $this->getComponentCount('Printer');
	}

	function & getSlot($i)
	{
		return $this->getComponent('Slot',$i);
	}

	function & getSlots()
	{
		return $this->getComponents('Slot');
	}
	
	function getSlotCount()
	{
		return $this->getComponentCount('Slot');
	}

	function & getSoftware($i)
	{
		return $this->getComponent('Software',$i);
	}

	function & getSoftwares()
	{
		return $this->getComponents('Software');
	}
	
	function getSoftwareCount()
	{
		return $this->getComponentCount('Software');
	}

	function & getStorage($i)
	{
		return $this->getComponent('Storage',$i);
	}

	function & getStorages()
	{
		return $this->getComponents('Storage');
	}
	
	function getStorageCount()
	{
		return $this->getComponentCount('Storage');
	}

	function & getVideo($i)
	{
		return $this->getComponent('Video',$i);
	}

	function & getVideos()
	{
		return $this->getComponents('Video');
	}
	
	function getVideoCount()
	{
		return $this->getComponentCount('Video');
	}
}

?>
