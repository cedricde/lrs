<?php

include_once('Component.php');

/**
 * Drive class contains all informations about one's machine drive.
 *
 * @author Maxime Wojtczak (Linbox FAS)
 */
class Drive extends Component
{
	function Drive()
	{
		$this->m_Properties = array(	'DriveLetter'=>'' , 
										'DriveType'=>'' ,
										'TotalSpace'=>'' ,
										'FreeSpace'=>'' ,
										'VolumeName'=>'' ,
										'FileSystem'=>'' ,
										'FileCount'=>'' );
	}

	/**
	 * Returns the drive letter of the current drive.
	 * 
	 * @return The drive letter
	 */
	function getDriveLetter()
	{
		return $this->getProperty('DriveLetter');
	}

	/**
	 * Sets a new value of the drive letter of the current drive.
	 * 
	 * @param driveletter The drive letter value to set.
	 */
	function setDriveLetter($driveletter)
	{
		$this->setProperty('DriveLetter',$driveletter);
	}

	/**
	 * Returns the drive type of the current drive.
	 * 
	 * @return The drive type
	 */
	function getDriveType()
	{
		return $this->getProperty('DriveType');
	}

	/**
	 * Sets a new value of the drive type of the current drive.
	 * 
	 * @param drivetype The drive type value to set.
	 */
	function setDriveType($drivetype)
	{
		$this->setProperty('DriveType',$drivetype);
	}

	/**
	 * Returns the total space of the current drive.
	 * 
	 * @return The total space
	 */
	function getTotalSpace()
	{
		return $this->getProperty('TotalSpace');
	}

	/**
	 * Sets a new value of the total space of the current drive.
	 * 
	 * @param totalspace The total space value to set.
	 */
	function setTotalSpace($totalspace)
	{
		$this->setProperty('TotalSpace',$totalspace);
	}

	/**
	 * Returns the free space of the current drive.
	 * 
	 * @return The free space
	 */
	function getFreeSpace()
	{
		return $this->getProperty('FreeSpace');
	}

	/**
	 * Sets a new value of the free space of the current drive.
	 * 
	 * @param freespace The free space value to set.
	 */
	function setFreeSpace($freespace)
	{
		$this->setProperty('FreeSpace',$freespace);
	}

	/**
	 * Returns the volume name of the current drive.
	 * 
	 * @return The volume name
	 */
	function getVolumeName()
	{
		return $this->getProperty('VolumeName');
	}

	/**
	 * Sets a new value of the volume name of the current drive.
	 * 
	 * @param volumename The volume name value to set.
	 */
	function setVolumeName($volumename)
	{
		$this->setProperty('VolumeName',$volumename);
	}

	/**
	 * Returns the file system of the current drive.
	 * 
	 * @return The file system
	 */
	function getFileSystem()
	{
		return $this->getProperty('FileSystem');
	}

	/**
	 * Sets a new value of the file system of the current drive.
	 * 
	 * @param filesystem The file system value to set.
	 */
	function setFileSystem($filesystem)
	{
		$this->setProperty('FileSystem',$filesystem);
	}

	/**
	 * Returns the file count of the current drive.
	 * 
	 * @return The file count
	 */
	function getFileCount()
	{
		return $this->getProperty('FileCount');
	}

	/**
	 * Sets a new value of the file count of the current drive.
	 * 
	 * @param filecount The file count value to set.
	 */
	function setFileCount($filecount)
	{
		$this->setProperty('FileCount',$filecount);
	}

}

?>