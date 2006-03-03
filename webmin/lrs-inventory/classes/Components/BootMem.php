<?php

include_once('Component.php');

/**
 * Hardware class contains all informations about one's machine hardware.
 *
 * @author Ludovic Drolez (Linbox FAS)
 */
class BootMem extends Component
{
	function BootMem()
	{
		$this->m_Properties = array(	'Used'=>'',
						'Location'=>'' ,
						'Form'=>'' ,
						'Type'=>'' ,
						'Speed'=>'' ,
						'Capacity'=>''
					    );
	}

}

?>