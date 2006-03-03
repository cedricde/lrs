<?php

include_once('Component.php');

/**
 * Software class contains all informations about one's machine software.
 *
 * @author Maxime Wojtczak (Linbox FAS)
 */
class Software extends Component
{
	function Software()
	{
		$this->m_Properties = array(	'Company'=>'' , 
						'ProductName'=>'' ,
						'ProductVersion'=>'' ,
						'ProductPath'=>'' ,
						'ExecutableSize'=>'' ,
						'Application'=>'' ,
						'Type'=>'' );
		$this->m_Desc = array ( 
			'this' => array('en'=>'software', 'fr'=>'logiciels'),
			'Company' => array('en'=>'company', 'fr'=>'éditeur'),
			'ProductName' => array('en'=>'product', 'fr'=>'application'),
			);
	}

	/**
	 * Returns the company of the current software.
	 * 
	 * @return The company
	 */
	function getCompany()
	{
		return $this->getProperty('Company');
	}

	/**
	 * Sets a new value of the company of the current software.
	 * 
	 * @param company The company value to set.
	 */
	function setCompany($company)
	{
		$this->setProperty('Company',$company);
	}

	/**
	 * Returns the product name of the current software.
	 * 
	 * @return The product name
	 */
	function getProductName()
	{
		return $this->getProperty('ProductName');
	}

	/**
	 * Sets a new value of the product name of the current software.
	 * 
	 * @param productname The product name value to set.
	 */
	function setProductName($productname)
	{
		$this->setProperty('ProductName',$productname);
	}

	/**
	 * Returns the product version of the current software.
	 * 
	 * @return The product version
	 */
	function getProductVersion()
	{
		return $this->getProperty('ProductVersion');
	}

	/**
	 * Sets a new value of the product version of the current software.
	 * 
	 * @param productversion The product version value to set.
	 */
	function setProductVersion($productversion)
	{
		$this->setProperty('ProductVersion',$productversion);
	}

	/**
	 * Returns the product path of the current software.
	 * 
	 * @return The product path
	 */
	function getProductPath()
	{
		return $this->getProperty('ProductPath');
	}

	/**
	 * Sets a new value of the product path of the current software.
	 * 
	 * @param productpath The product path value to set.
	 */
	function setProductPath($productpath)
	{
		$this->setProperty('ProductPath',$productpath);
	}

	/**
	 * Returns the executable size of the current software.
	 * 
	 * @return The executable size
	 */
	function getExecutableSize()
	{
		return $this->getProperty('ExecutableSize');
	}

	/**
	 * Sets a new value of the executable size of the current software.
	 * 
	 * @param executablesize The executable size value to set.
	 */
	function setExecutableSize($executablesize)
	{
		$this->setProperty('ExecutableSize',$executablesize);
	}

	/**
	 * Returns the application of the current software.
	 * 
	 * @return The application
	 */
	function getApplication()
	{
		return $this->getProperty('Application');
	}

	/**
	 * Sets a new value of the application of the current software.
	 * 
	 * @param application The application value to set.
	 */
	function setApplication($application)
	{
		$this->setProperty('Application',$application);
	}

	/**
	 * Returns the type of the current software.
	 * 
	 * @return The type
	 */
	function getType()
	{
		return $this->getProperty('Type');
	}

	/**
	 * Sets a new value of the type of the current software.
	 * 
	 * @param type The type value to set.
	 */
	function setType($type)
	{
		$this->setProperty('Type',$type);
	}

}

?>