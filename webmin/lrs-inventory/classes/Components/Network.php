<?php

include_once('Component.php');

/**
 * Network class contains all informations about one's machine network card.
 *
 * @author Maxime Wojtczak (Linbox FAS)
 */
class Network extends Component
{
	function Network()
	{
		$this->m_Properties = array(	'CardType'=>'' , 
						'NetworkType'=>'' ,
						'MIB'=>'' ,
						'Bandwidth'=>'' ,
						'MACAddress'=>'' ,
						'State'=>'' ,
						'IP'=>'' ,
						'SubnetMask'=>'' ,
						'Gateway'=>'' ,
						'DNS'=>'' );
		
		$this->m_Desc = array ( 
			'this' => array('en'=>'network', 'fr'=>'réseau'),
			'CardType' => array('en'=>'network card', 'fr'=>'carte réseau'),
			);

	}

	/**
	 * Returns the card type of the current network.
	 * 
	 * @return The card type
	 */
	function getCardType()
	{
		return $this->getProperty('CardType');
	}

	/**
	 * Sets a new value of the card type of the current network.
	 * 
	 * @param cardtype The card type value to set.
	 */
	function setCardType($cardtype)
	{
		$this->setProperty('CardType',$cardtype);
	}

	/**
	 * Returns the network type of the current network.
	 * 
	 * @return The network type
	 */
	function getNetworkType()
	{
		return $this->getProperty('NetworkType');
	}

	/**
	 * Sets a new value of the network type of the current network.
	 * 
	 * @param networktype The network type value to set.
	 */
	function setNetworkType($networktype)
	{
		$this->setProperty('NetworkType',$networktype);
	}

	/**
	 * Returns the MIB of the current network.
	 * 
	 * @return The MIB
	 */
	function getMIB()
	{
		return $this->getProperty('MIB');
	}

	/**
	 * Sets a new value of the MIB of the current network.
	 * 
	 * @param mib The MIB value to set.
	 */
	function setMIB($mib)
	{
		$this->setProperty('MIB',$mib);
	}

	/**
	 * Returns the bandwidth of the current network.
	 * 
	 * @return The bandwidth
	 */
	function getBandwidth()
	{
		return $this->getProperty('Bandwidth');
	}

	/**
	 * Sets a new value of the bandwidth of the current network.
	 * 
	 * @param bandwidth The bandwidth value to set.
	 */
	function setBandwidth($bandwidth)
	{
		$this->setProperty('Bandwidth',$bandwidth);
	}

	/**
	 * Returns the MAC address of the current network.
	 * 
	 * @return The MAC address
	 */
	function getMACAddress()
	{
		return $this->getProperty('MACAddress');
	}

	/**
	 * Sets a new value of the MAC address of the current network.
	 * 
	 * @param macaddress The MAC address value to set.
	 */
	function setMACAddress($macaddress)
	{
		$this->setProperty('MACAddress',$macaddress);
	}

	/**
	 * Returns the state of the current network.
	 * 
	 * @return The state
	 */
	function getState()
	{
		return $this->getProperty('State');
	}

	/**
	 * Sets a new value of the state of the current network.
	 * 
	 * @param state The state value to set.
	 */
	function setState($state)
	{
		$this->setProperty('State',$state);
	}

	/**
	 * Returns the IP of the current network.
	 * 
	 * @return The IP
	 */
	function getIP()
	{
		return $this->getProperty('IP');
	}

	/**
	 * Sets a new value of the IP of the current network.
	 * 
	 * @param ip The IP value to set.
	 */
	function setIP($ip)
	{
		$this->setProperty('IP',$ip);
	}

	/**
	 * Returns the subnet mask of the current network.
	 * 
	 * @return The subnet mask
	 */
	function getSubnetMask()
	{
		return $this->getProperty('SubnetMask');
	}

	/**
	 * Sets a new value of the subnet mask of the current network.
	 * 
	 * @param subnetmask The subnet mask value to set.
	 */
	function setSubnetMask($subnetmask)
	{
		$this->setProperty('SubnetMask',$broadcast);
	}

	/**
	 * Returns the gateway of the current network.
	 * 
	 * @return The gateway
	 */
	function getGateway()
	{
		return $this->getProperty('Gateway');
	}

	/**
	 * Sets a new value of the gateway of the current network.
	 * 
	 * @param gateway The gateway value to set.
	 */
	function setGateway($gateway)
	{
		$this->setProperty('Gateway',$gateway);
	}

	/**
	 * Returns the DNS of the current network.
	 * 
	 * @return The DNS
	 */
	function getDNS()
	{
		return $this->getProperty('DNS');
	}

	/**
	 * Sets a new value of the DNS of the current network.
	 * 
	 * @param dns The DNS value to set.
	 */
	function setDNS($dns)
	{
		$this->setProperty('DNS',$dns);
	}

}

?>