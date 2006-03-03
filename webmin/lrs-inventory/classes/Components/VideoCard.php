<?php

include_once('Component.php');

/**
 * VideoCard class contains all informations about one's machine video card.
 *
 * @author Maxime Wojtczak (Linbox FAS)
 */
class VideoCard extends Component
{
	function VideoCard()
	{
		$this->m_Properties = array(	'Model'=>'' , 
										'Chipset'=>'' ,
										'VRAMSize'=>'' ,
										'Resolution'=>'' );
	}

	/**
	 * Returns the model of the current video card.
	 * 
	 * @return The model
	 */
	function getModel()
	{
		return $this->getProperty('Model');
	}

	/**
	 * Sets a new value of the model of the current video card.
	 * 
	 * @param model The model value to set.
	 */
	function setModel($model)
	{
		$this->setProperty('Model',$model);
	}

	/**
	 * Returns the chipset of the current video card.
	 * 
	 * @return The chipset
	 */
	function getChipset()
	{
		return $this->getProperty('Chipset');
	}

	/**
	 * Sets a new value of the chipset of the current video card.
	 * 
	 * @param chipset The chipset value to set.
	 */
	function setChipset($chipset)
	{
		$this->setProperty('Chipset',$chipset);
	}

	/**
	 * Returns the v r a m size of the current video card.
	 * 
	 * @return The v r a m size
	 */
	function getVRAMSize()
	{
		return $this->getProperty('VRAMSize');
	}

	/**
	 * Sets a new value of the v r a m size of the current video card.
	 * 
	 * @param vramsize The v r a m size value to set.
	 */
	function setVRAMSize($vramsize)
	{
		$this->setProperty('VRAMSize',$vramsize);
	}

	/**
	 * Returns the resolution of the current video card.
	 * 
	 * @return The resolution
	 */
	function getResolution()
	{
		return $this->getProperty('Resolution');
	}

	/**
	 * Sets a new value of the resolution of the current video card.
	 * 
	 * @param resolution The resolution value to set.
	 */
	function setResolution($resolution)
	{
		$this->setProperty('Resolution',$resolution);
	}

}

?>