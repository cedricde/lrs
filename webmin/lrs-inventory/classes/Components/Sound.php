<?php

include_once('Component.php');

/**
 * Memory class contains all informations about one's machine memory.
 *
 * @author Maxime Wojtczak (Linbox FAS)
 */
class Sound extends Component
{
	function Sound()
	{
		$this->m_Properties = array(	'Name'=>'' , 
										'Description'=>'' );
	}
	
	/**
	 * Returns the name of the current sound.
	 * 
	 * @return The name.
	 */
	function getName()
	{
		return $this->getProperty('Name');
	}

	/**
	 * Sets a new value of the name of the current sound.
	 * 
	 * @param type The name value to set.
	 */
	function setName($name)
	{
		$this->setProperty('Name',$name);
	}

	/**
	 * Returns the description of the current sound.
	 * 
	 * @return The description.
	 */
	function getDescription()
	{
		return $this->getProperty('Description');
	}

	/**
	 * Sets a new value of the description of the current sound.
	 * 
	 * @param description The description value to set.
	 */
	function setDescription($description)
	{
		$this->setProperty('Description',$description);
	}

}

?>