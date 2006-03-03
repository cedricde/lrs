<?php

// split the DB field when a pipe char is found
// and also split the UUID field (System4)
function FilterSplitPipe(&$data) {
	$props = array("System", "Bios", "Chassis");

	foreach ($props as $prop)
	{
		for ( $i=0 ; $i<count($data) ; $i++ )
		{
			$object = & $data[$i];
			$properties = $object->getProperties(); 
			if ($properties[$prop] == "") {
				// to avoid problems with templates
				$properties[$prop] = "||||||||";
			}
			$list = split("\|", $properties[$prop]);
			foreach ($list as $key => $val) 
			{
				$properties["$prop".$key] = $val;
			}
			if (!empty($properties["System4"]) && $prop == "System")
			{
				$properties["System4"] =
					preg_replace("/(.{8})(.{4})(.{4})(.{4})(.{12})/",
					"\\1-\\2-\\3-\\4-\\5", $properties["System4"]);
			}
			$object->setProperties($properties);
			unset($properties);
		}
	}
}


/** Filter which replace the OCS chipset info with the display controller 
 *  found in the BootPCI table
 */
function FilterPCIVC(&$data)
{
	global $datapci;
	
	$infos = array();
	// find all display controllers
	for ( $i=0 ; $i<count($datapci) ; $i++ )
	{
		$object = & $datapci[$i];
		if (get_class($object) == "bootpci")
		{		
			$props = $object->getProperties();
			if (stristr($props['Class'], "display controller"))
			{
				$host = $object->getHost();
				$host = $host->getName();
				$infos[$host] = array ($props["Vendor"]." ".$props['Device'], $object->getFirstApparition() );
			}
			unset($properties);		
		}
	}
	// for each card found assign create a new inventory entry
	foreach ($infos as $host => $info)
	{
		$vc =& findOrCreateObject($data, $host, "VideoCard");

		$vc->setProperty("Chipset", $info[0]);
		$vc->setFirstApparition($info[1]);		
	}
}

/**
 *
 */
function FilterFromSQL($data, $type)
{
	global $reversedate;
	
	// short type
	ereg("[a-zA-Z]+", $type, $tmp);
	$stype = strtolower($tmp[0]);
	$ret = $data;
	
	switch ($stype) {
		case "date":
			if ($reversedate) {
				$ret = ereg_replace("([0-9]{4})-([0-9]{1,2})-([0-9]{1,2})", "\\3/\\2/\\1", $data);
			}
			break;
		default;
	}

	return $ret;
}

/**
 *
 */
function FilterToSQL($data, $type)
{
	global $reversedate;
	
	// short type
	ereg("[a-zA-Z]+", $type, $tmp);
	$stype = strtolower($tmp[0]);
	$ret = $data;
	
	switch ($stype) {
		case "date":
			if ($reversedate) {
				$ret = ereg_replace("([0-9]{1,2})/([0-9]{1,2})/([0-9]{4})", "\\3-\\2-\\1", $data);
			}
			break;
		default;
	}

	return $ret;
}

?>
