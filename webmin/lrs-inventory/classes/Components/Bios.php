<?php

include_once('Component.php');

/**
 * Bios class contains all informations about one's machine bios.
 *
 * @author Maxime Wojtczak (Linbox FAS)
 */
class Bios extends Component
{
	function Bios()
	{
		$this->m_Properties = array(	'Serial'=>'' , 
						'Version'=>'' ,
						'Vendor'=>'' ,
						'Chipset'=>'' ,
						'ChipsetSerial'=>'' ,
						'ChipsetVendor'=>'' ,
						'TypeMachine'=>'' );
	}

	/**
	 * Returns the serial of the current bios.
	 * 
	 * @return The serial
	 */
	function getSerial()
	{
		return $this->getProperty('Serial');
	}

	/**
	 * Sets a new value of the serial of the current bios.
	 * 
	 * @param serial The serial value to set.
	 */
	function setSerial($serial)
	{
		$this->setProperty('Serial',$serial);
	}

	/**
	 * Returns the version of the current bios.
	 * 
	 * @return The version
	 */
	function getVersion()
	{
		return $this->getProperty('Version');
	}

	/**
	 * Sets a new value of the version of the current bios.
	 * 
	 * @param version The version value to set.
	 */
	function setVersion($version)
	{
		$this->setProperty('Version',$version);
	}

	/**
	 * Returns the vendor of the current bios.
	 * 
	 * @return The vendor
	 */
	function getVendor()
	{
		return $this->getProperty('Vendor');
	}

	/**
	 * Sets a new value of the vendor of the current bios.
	 * 
	 * @param vendor The vendor value to set.
	 */
	function setVendor($vendor)
	{
		$this->setProperty('Vendor',$vendor);
	}

	/**
	 * Returns the chipset of the current bios.
	 * 
	 * @return The chipset
	 */
	function getChipset()
	{
		return $this->getProperty('Chipset');
	}

	/**
	 * Sets a new value of the chipset of the current bios.
	 * 
	 * @param chipset The chipset value to set.
	 */
	function setChipset($chipset)
	{
		$this->setProperty('Chipset',$chipset);
	}

	/**
	 * Returns the chipset serial of the current bios.
	 * 
	 * @return The chipset serial
	 */
	function getChipsetSerial()
	{
		return $this->getProperty('ChipsetSerial');
	}

	/**
	 * Sets a new value of the chipset serial of the current bios.
	 * 
	 * @param chipsetserial The chipset serial value to set.
	 */
	function setChipsetSerial($chipsetserial)
	{
		$this->setProperty('ChipsetSerial',$chipsetserial);
	}

	/**
	 * Returns the chipset vendor of the current bios.
	 * 
	 * @return The chipset vendor
	 */
	function getChipsetVendor()
	{
		return $this->getProperty('ChipsetVendor');
	}

	/**
	 * Sets a new value of the chipset vendor of the current bios.
	 * 
	 * @param chipsetvendor The chipset vendor value to set.
	 */
	function setChipsetVendor($chipsetvendor)
	{
		$this->setProperty('ChipsetVendor',$chipsetvendor);
	}

	/**
	 * Returns the machine type of the current bios.
	 * 
	 * @return The machine type
	 */
	function getMachineType()
	{
		return $this->getProperty('TypeMachine');
	}

	/**
	 * Sets a new value of the machine type of the current bios.
	 * 
	 * @param machinetype The machine type value to set.
	 */
	function setMachineType($machinetype)
	{
		$this->setProperty('TypeMachine',$machinetype);
	}

}

?>