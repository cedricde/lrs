<?php

include_once('Component.php');

/**
 * Controller class contains all informations about one's machine controller.
 *
 * @author Maxime Wojtczak (Linbox FAS)
 */
class Controller extends Component
{
	function Controller()
	{
		$this->m_Properties = array(	'Vendor'=>'' , 
										'ExpandedType'=>'' ,
										'HardwareVersion'=>'' ,
										'StandardType'=>'' );
	}
	
    /**
     * Returns the vendor of the current controller.
     * 
     * @return The vendor
     */
    function getVendor()
    {
        return $this->getProperty('Vendor');
    }

    /**
     * Sets a new value of the vendor of the current controller.
     * 
     * @param vendor The vendor value to set.
     */
    function setVendor($vendor)
    {
        $this->setProperty('Vendor',$vendor);
    }

    /**
     * Returns the expanded type of the current controller.
     * 
     * @return The expanded type
     */
    function getExpandedType()
    {
        return $this->getProperty('ExpandedType');
    }

    /**
     * Sets a new value of the expanded type of the current
controller.
     * 
     * @param expandedtype The expanded type value to set.
     */
    function setExpandedType($expandedtype)
    {
        $this->setProperty('ExpandedType',$expandedtype);
    }

    /**
     * Returns the hardware version of the current controller.
     * 
     * @return The hardware version
     */
    function getHardwareVersion()
    {
        return $this->getProperty('HardwareVersion');
    }

    /**
     * Sets a new value of the hardware version of the current
controller.
     * 
     * @param hardwareversion The hardware version value to set.
     */
    function setHardwareVersion($hardwareversion)
    {
        $this->setProperty('HardwareVersion',$hardwareversion);
    }

    /**
     * Returns the standard type of the current controller.
     * 
     * @return The standard type
     */
    function getStandardType()
    {
        return $this->getProperty('StandardType');
    }

    /**
     * Sets a new value of the standard type of the current
controller.
     * 
     * @param standardtype The standard type value to set.
     */
    function setStandardType($standardtype)
    {
        $this->setProperty('StandardType',$standardtype);
    }

}

?>
