<?php

/**
 * The Object class is the base class of all elements that can be stored on the  server. This class aims at being very general in order to make it easy to store informations and properties in databse, XML, etc. in a generic way.
 *
 * @author Maxime Wojtczak (Linbox FAS)
 */
class Object
{
	/**
	 * Contains all the properties of the current object. Access can be made through setProperty and getProperty methods.
	 */
	var $m_Properties;
	
	var $m_FirstApparition;
	
	/* properties textual descrption */
	var $m_Desc;

	function Object()
	{
		$this->m_Properties = array();
	}

	/**
	 * Sets a property in the current object and updates the modified flag if needed.
	 *
	 * @param name The property name to set.
	 * @param value The new value.
	 */
	function setProperty($name,$value)
	{
		$this->m_Properties[$name] = $value;
	}

	/**
	 * Returns the current value of a property.
	 *
	 * @param name The property to get.
	 * @return The value of the property
	 */
	function getProperty($name)
	{
		return $this->m_Properties[$name];
	}
	
	/**
	 * Returns all the properties in an associative array.
	 * 
	 * @return An associative array containing properties.
	 */
	function getProperties()
	{
		return $this->m_Properties;
	}
	
	/**
	 * Sets all the properties of the current object.
	 * 
	 * @param properties An associative array containing properties.
	 */
	function setProperties(&$properties)
	{
		$this->m_Properties = & $properties;
	}

	/**
	 * Returns a string which contains the current class name.
	 *
	 * @return The class name.
	 */
	function getClassName()
	{
		return get_class($this);
	}

	/**
	 * Returns a string which describe the current object, with type of object and all the properties.
	 *
	 * @return A string describing the current object.
	 */
	function toString()
	{
		$string = $this->getClassName() .' [';
		
		$first = true;
		
		foreach ( $this->m_Properties as $property => $value )
		{
			if ( !empty($value) )
			{
				$string .= ( $first ? '' : ';' ) . $property .'='. $value;
				$first = false;
			}
		}
		
		$string .= ']';
		
		return $string;
	}
	
	/**
	 * Returns the first apparition of the current object.
	 * 
	 * @return The date of the first apparition (yyyy-mm-dd)
	 */
	function getFirstApparition()
	{
		return $this->m_FirstApparition;
	}
	
	/**
	 * Sets first apparition date of the current object.
	 * 
	 * @param firstapparition The date of the first apparition (yyyy-mm-dd)
	 */
	function setFirstApparition($firstapparition)
	{
		$this->m_FirstApparition = $firstapparition;
	}

	/**
	 * Test if the object given as parameter is equal to the current one.
	 *
	 * @param object The object to compare.
	 * @return True if the objects are equals, false otherwise.
	 */
	function equals(&$object)
	{
		if ( strcasecmp( $this->getClassName(),$object->getClassName() )!=0 )

			return false;

		else
		{
			$keys = array_keys($this->getProperties());

			foreach ( $object->getProperties() as $key=>$value )

				if ( ! in_array($key, $keys) )

					$keys[] = $key;

			foreach ( $keys as $key )

				if ( $this->getProperty($key)!=$object->getProperty($key) )

					return false;

		}

		return true;
	}
	
	/**
	 * Returns the description of a property.
	 *
	 * @param name The property to get.
	 * @return The value of the property
	 */
	function getDesc($name)
	{
		global $gconfig, $remote_user, $lang;
	
		$trad = $this->m_Desc[$name][$lang];
		if ($trad) {
			return $trad;
		}
		$trad = ereg_replace("_", " ", $name);
		return $trad;
	}
}

?>
