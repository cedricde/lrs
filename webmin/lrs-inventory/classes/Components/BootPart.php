<?php

include_once('Component.php');

/**
 * Hardware class contains all informations about one's machine hardware.
 *
 * @author Ludovic Drolez (Linbox FAS)
 */
class BootPart extends Component
{
	function BootPart()
	{
		$this->m_Properties = array(	'Disk'=>'',
						'Num'=>'',
						'Type'=>'' ,
						'Length'=>'',
						'Flag'=>''
					    );
	}
}

?>