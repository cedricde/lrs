<?php

include_once('Component.php');

/**
 * Hardware class contains all informations about one's machine hardware.
 *
 * @author Maxime Wojtczak (Linbox FAS)
 */
class Hardware extends Component
{
	function Hardware()
	{
		$this->m_Properties = array(	'Description'=>'',
						'Type'=>'',
						'ProcessorType'=>'' ,
						'ProcessorFrequency'=>'' ,
						'ProcessorCount'=>'' ,
						'RamTotal'=>'' ,
						'SwapSpace'=>'' ,
						'IpAddress'=>'' ,
						'Date'=>'' ,
						'User'=>'' ,
						'Workgroup'=>'' ,
						'OperatingSystem'=>'' , 
						'Version'=>'' ,
						'Build'=>'' ,
						'RegisteredName'=>'' ,
						'RegisteredCompany'=>'' ,
						'OSSerialNumber'=>'' );
						
		$this->m_Desc = array ( 
			'this' => array('en'=>'client', 'fr'=>'client'),
			'OperatingSystem' => array('en'=>'operating system', 'fr'=>'système d\'exploitation'),
			'Version' => array('en'=>'version', 'fr'=>'version'),
			'RamTotal' => array('en'=>'total memory', 'fr'=>'mémoire totale'),
			);
	}

	/**
	 * Returns the operating system of the current hardware.
	 * 
	 * @return The operating system
	 */
	function getOperatingSystem()
	{
		return $this->getProperty('OperatingSystem');
	}

	/**
	 * Sets a new value of the operating system of the current hardware.
	 * 
	 * @param operatingsystem The operating system value to set.
	 */
	function setOperatingSystem($operatingsystem)
	{
		$this->setProperty('OperatingSystem',$operatingsystem);
	}

	/**
	 * Returns the version of the current hardware.
	 * 
	 * @return The version
	 */
	function getVersion()
	{
		return $this->getProperty('Version');
	}

	/**
	 * Sets a new value of the version of the current hardware.
	 * 
	 * @param version The version value to set.
	 */
	function setVersion($version)
	{
		$this->setProperty('Version',$version);
	}

	/**
	 * Returns the build of the current hardware.
	 * 
	 * @return The build
	 */
	function getBuild()
	{
		return $this->getProperty('Build');
	}

	/**
	 * Sets a new value of the build of the current hardware.
	 * 
	 * @param build The build value to set.
	 */
	function setBuild($build)
	{
		$this->setProperty('Build',$build);
	}

	/**
	 * Returns the processor type of the current hardware.
	 * 
	 * @return The processor type
	 */
	function getProcessorType()
	{
		return $this->getProperty('ProcessorType');
	}

	/**
	 * Sets a new value of the processor type of the current hardware.
	 * 
	 * @param processortype The processor type value to set.
	 */
	function setProcessorType($processortype)
	{
		$this->setProperty('ProcessorType',$processortype);
	}

	/**
	 * Returns the processor frequency of the current hardware.
	 * 
	 * @return The processor frequency
	 */
	function getProcessorFrequency()
	{
		return $this->getProperty('ProcessorFrequency');
	}

	/**
	 * Sets a new value of the processor frequency of the current hardware.
	 * 
	 * @param processorfrequency The processor frequency value to set.
	 */
	function setProcessorFrequency($processorfrequency)
	{
		$this->setProperty('ProcessorFrequency',$processorfrequency);
	}

	/**
	 * Returns the processor count of the current hardware.
	 * 
	 * @return The processor count
	 */
	function getProcessorCount()
	{
		return $this->getProperty('ProcessorCount');
	}

	/**
	 * Sets a new value of the processor count of the current hardware.
	 * 
	 * @param processorcount The processor count value to set.
	 */
	function setProcessorCount($processorcount)
	{
		$this->setProperty('ProcessorCount',$processorcount);
	}

	/**
	 * Returns the ram total of the current hardware.
	 * 
	 * @return The ram total
	 */
	function getRamTotal()
	{
		return $this->getProperty('RamTotal');
	}

	/**
	 * Sets a new value of the ram total of the current hardware.
	 * 
	 * @param ramtotal The ram total value to set.
	 */
	function setRamTotal($ramtotal)
	{
		$this->setProperty('RamTotal',$ramtotal);
	}

	/**
	 * Returns the swap space of the current hardware.
	 * 
	 * @return The swap space
	 */
	function getSwapSpace()
	{
		return $this->getProperty('SwapSpace');
	}

	/**
	 * Sets a new value of the swap space of the current hardware.
	 * 
	 * @param swapspace The swap space value to set.
	 */
	function setSwapSpace($swapspace)
	{
		$this->setProperty('SwapSpace',$swapspace);
	}

	/**
	 * Returns the ip address of the current hardware.
	 * 
	 * @return The ip address
	 */
	function getIpAddress()
	{
		return $this->getProperty('IpAddress');
	}

	/**
	 * Sets a new value of the ip address of the current hardware.
	 * 
	 * @param ipaddress The ip address value to set.
	 */
	function setIpAddress($ipaddress)
	{
		$this->setProperty('IpAddress',$ipaddress);
	}

	/**
	 * Returns the date of the current hardware.
	 * 
	 * @return The date
	 */
	function getDate()
	{
		return $this->getProperty('Date');
	}

	/**
	 * Sets a new value of the date of the current hardware.
	 * 
	 * @param date The date value to set.
	 */
	function setDate($date)
	{
		$this->setProperty('Date',$date);
	}

	/**
	 * Returns the user of the current hardware.
	 * 
	 * @return The user
	 */
	function getUser()
	{
		return $this->getProperty('User');
	}

	/**
	 * Sets a new value of the user of the current hardware.
	 * 
	 * @param user The user value to set.
	 */
	function setUser($user)
	{
		$this->setProperty('User',$user);
	}

	/**
	 * Returns the workgroup of the current hardware.
	 * 
	 * @return The workgroup
	 */
	function getWorkgroup()
	{
		return $this->getProperty('Workgroup');
	}

	/**
	 * Sets a new value of the workgroup of the current hardware.
	 * 
	 * @param workgroup The workgroup value to set.
	 */
	function setWorkgroup($workgroup)
	{
		$this->setProperty('Workgroup',$workgroup);
	}

	/**
	 * Returns the registered name of the current hardware.
	 * 
	 * @return The registered name
	 */
	function getRegisteredName()
	{
		return $this->getProperty('RegisteredName');
	}

	/**
	 * Sets a new value of the registered name of the current hardware.
	 * 
	 * @param registeredname The registered name value to set.
	 */
	function setRegisteredName($registeredname)
	{
		$this->setProperty('RegisteredName',$registeredname);
	}

	/**
	 * Returns the registered company of the current hardware.
	 * 
	 * @return The registered company
	 */
	function getRegisteredCompany()
	{
		return $this->getProperty('RegisteredCompany');
	}

	/**
	 * Sets a new value of the registered company of the current hardware.
	 * 
	 * @param registeredcompany The registered company value to set.
	 */
	function setRegisteredCompany($registeredcompany)
	{
		$this->setProperty('RegisteredCompany',$registeredcompany);
	}

	/**
	 * Returns the o s serial number of the current hardware.
	 * 
	 * @return The o s serial number
	 */
	function getOSSerialNumber()
	{
		return $this->getProperty('OSSerialNumber');
	}

	/**
	 * Sets a new value of the o s serial number of the current hardware.
	 * 
	 * @param osserialnumber The o s serial number value to set.
	 */
	function setOSSerialNumber($osserialnumber)
	{
		$this->setProperty('OSSerialNumber',$osserialnumber);
	}

}

?>