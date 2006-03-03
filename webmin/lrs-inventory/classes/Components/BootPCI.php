<?php

include_once('Component.php');

/**
 * Hardware class contains all informations about one's machine hardware.
 *
 * @author Ludovic Drolez (Linbox FAS)
 */
class BootPCI extends Component
{
	function BootPCI()
	{
		$this->m_Properties = array(	'Num'=>'',
						'Bus'=>'' ,
						'Func'=>'' ,
						'Vendor'=>'' ,
						'Device'=>'' ,
						'Class'=>'' ,
						'Type'=>''
					    );
	}

}

?>