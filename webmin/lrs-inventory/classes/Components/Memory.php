<?php

include_once('Component.php');

/**
 * Memory class contains all informations about one's machine memory.
 *
 * @author Maxime Wojtczak (Linbox FAS)
 */
class Memory extends Component
{
	function Memory()
	{
		$this->m_Properties = array(	'Type'=>'' , 
						'ExtendedDescription'=>'' ,
						'Description'=>'' ,
						'Size'=>'' ,
						'ChipsetType'=>'' ,
						'Frequency'=>'' ,
						'SlotCount'=>'' );
	}
	
	/**
	 * Returns the type of the current memory.
	 * 
	 * @return The type.
	 */
	function getType()
	{
		return $this->getProperty('Type');
	}

	/**
	 * Sets a new value of the type of the current memory.
	 * 
	 * @param type The type value to set.
	 */
	function setType($type)
	{
		$this->setProperty('Type',$type);
	}

	/**
	 * Returns the extended description of the current memory.
	 * 
	 * @return The extended description.
	 */
	function getExtendedDescription()
	{
		return $this->getProperty('ExtendedDescription');
	}

	/**
	 * Sets a new value of the extended description of the current memory.
	 * 
	 * @param extendeddescription The extended description value to set.
	 */
	function setExtendedDescription($extendeddescription)
	{
		$this->setProperty('ExtendedDescription',$extendeddescription);
	}

	/**
	 * Returns the size of the current memory.
	 * 
	 * @return The size.
	 */
	function getSize()
	{
		return $this->getProperty('Size');
	}

	/**
	 * Sets a new value of the size of the current memory.
	 * 
	 * @param size The size value to set.
	 */
	function setSize($size)
	{
		$this->setProperty('Size',$size);
	}

	/**
	 * Returns the chipset type of the current memory.
	 * 
	 * @return The chipset type.
	 */
	function getChipsetType()
	{
		return $this->getProperty('ChipsetType');
	}

	/**
	 * Sets a new value of the chipset type of the current memory.
	 * 
	 * @param chipsettype The chipset type value to set.
	 */
	function setChipsetType($chipsettype)
	{
		$this->setProperty('ChipsetType',$chipsettype);
	}

	/**
	 * Returns the frequency of the current memory.
	 * 
	 * @return The frequency.
	 */
	function getFrequency()
	{
		return $this->getProperty('Frequency');
	}

	/**
	 * Sets a new value of the frequency of the current memory.
	 * 
	 * @param frequency The frequency value to set.
	 */
	function setFrequency($frequency)
	{
		$this->setProperty('Frequency',$frequency);
	}

	/**
	 * Returns the slot count of the current memory.
	 * 
	 * @return The slot count.
	 */
	function getSlotCount()
	{
		return $this->getProperty('SlotCount');
	}

	/**
	 * Sets a new value of the slot count of the current memory.
	 * 
	 * @param slotcount The slot count value to set.
	 */
	function setSlotCount($slotcount)
	{
		$this->setProperty('SlotCount',$slotcount);
	}

}

?>