<?php

include_once('Component.php');

/**
 * Hardware class contains all informations about one's machine hardware.
 *
 * @author Ludovic Drolez (Linbox FAS)
 */
class BootDisk extends Component
{
	function BootDisk()
	{
		$this->m_Properties = array(	'Num'=>'',
						'Name'=>'' ,
						'Cyl'=>'' ,
						'Head'=>'' ,
						'Sector'=>'' ,
						'Capacity'=>''
					    );
		$this->m_Desc = array ( 
			'this' => array('en'=>'disks detected at boot', 'fr'=>'disques détectés au boot'),
			'Capacity' => array('en'=>'capacity', 'fr'=>'capacité'),
			);
	}
}

?>