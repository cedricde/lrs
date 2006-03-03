<?php

include_once('Component.php');

/**
 * Hardware class contains all informations about one's machine hardware.
 *
 * @author Ludovic Drolez (Linbox FAS)
 */
class BootGeneral extends Component
{
	function BootGeneral()
	{
		$this->m_Properties = array(	'MacAddr'=>'' ,
						'LowMem'=>'' ,
						'HighMem'=>'' ,
						'TotalMem'=>'' ,
						'CpuVendor'=>'' ,
						'Model'=>'' ,
						'Freq'=>'' ,
						'System'=>'' ,
						'Bios'=>'' ,
						'MiscSMB'=>'' , 
						'MiscMem'=>'' ,
						'Chassis'=>'' ,
					    );
					    
		$this->m_Desc = array ( 
			'this' => array('en'=>'client', 'fr'=>'client'),
			'System0' => array('en'=>'marque', 'fr'=>'brand'),
			'Model' => array('en'=>'processor type', 'fr'=>'type de processeur'),
			'Freq' => array('en'=>'processor frequency', 'fr'=>'fréquence du processeur'),
			'TotalMem' => array('en'=>'total memory', 'fr'=>'mémoire totale'),
			);

	}

}

?>