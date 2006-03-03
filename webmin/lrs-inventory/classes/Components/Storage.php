<?php

include_once('Component.php');

/**
 * Storage class contains all informations about one's machine storage unit.
 *
 * @author Maxime Wojtczak (Linbox FAS)
 */
class Storage extends Component
{
	function Storage()
	{
		$this->m_Properties = array(	'ExtendedType'=>'' , 
										'Model'=>'' ,
										'VolumeName'=>'' ,
										'Media'=>'' ,
										'StandardType'=>'' );
	}

	/**
	 * Returns the extended type of the current storage.
	 * 
	 * @return The extended type
	 */
	function getExtendedType()
	{
		return $this->getProperty('ExtendedType');
	}

	/**
	 * Sets a new value of the extended type of the current storage.
	 * 
	 * @param extendedtype The extended type value to set.
	 */
	function setExtendedType($extendedtype)
	{
		$this->setProperty('ExtendedType',$extendedtype);
	}

	/**
	 * Returns the model of the current storage.
	 * 
	 * @return The model
	 */
	function getModel()
	{
		return $this->getProperty('Model');
	}

	/**
	 * Sets a new value of the model of the current storage.
	 * 
	 * @param model The model value to set.
	 */
	function setModel($model)
	{
		$this->setProperty('Model',$model);
	}

	/**
	 * Returns the volume name of the current storage.
	 * 
	 * @return The volume name
	 */
	function getVolumeName()
	{
		return $this->getProperty('VolumeName');
	}

	/**
	 * Sets a new value of the volume name of the current storage.
	 * 
	 * @param volumename The volume name value to set.
	 */
	function setVolumeName($volumename)
	{
		$this->setProperty('VolumeName',$volumename);
	}

	/**
	 * Returns the media of the current storage.
	 * 
	 * @return The media
	 */
	function getMedia()
	{
		return $this->getProperty('Media');
	}

	/**
	 * Sets a new value of the media of the current storage.
	 * 
	 * @param media The media value to set.
	 */
	function setMedia($media)
	{
		$this->setProperty('Media',$media);
	}

	/**
	 * Returns the standard type of the current storage.
	 * 
	 * @return The standard type
	 */
	function getStandardType()
	{
		return $this->getProperty('StandardType');
	}

	/**
	 * Sets a new value of the standard type of the current storage.
	 * 
	 * @param standardtype The standard type value to set.
	 */
	function setStandardType($standardtype)
	{
		$this->setProperty('StandardType',$standardtype);
	}

}

?>