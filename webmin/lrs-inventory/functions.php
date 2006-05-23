<?php

	include_once('lbs-part.pl');	// yes it's perl !

	/**
	 * Fills a template with informations of a given type. Data are loaded from the default data source.
	 * 
	 * @param type Type of data to fill.
	 * @param templatefile The template file (Optionnal). If no file name is given, a default template is loaded.
	 * @param formatter An array describing special formatting rules to apply on some fields.
	 * @param data Data to render.
	 * @param format_func Global format function to call on $data
	 */
	function renderTable( $type, $templatefile='', $formatter=array(), $data=null, $format_func=null )
	{
		global $machines, $datasource, $text, $lang, $config;

		// Give a default template file if needed
		if ( empty($templatefile) )
			$templatefile = "$type.tpl";

		$template = tmplInit(array("template" => $templatefile));
		$template->set_block('template', 'row', 'rows');

		// Retrieve data if needed
		if ( $data==null && !empty($type) )
		{
			// Retrieve objects to fill
			$data = & $datasource->read($type, $machines);
			
			$canfirstappear = true;
		}
		else
			$canfirstappear = false;
				
		$sortable = array();

		// get fields descriptions
		if ($type == "Custom" && $data[0]) 
		{
			$trad = $data[0]->m_Desc;
			foreach ($trad as $key => $array)
			{
				$template->set_var('TIT_'.strtoupper($key), ucfirst($array[$lang]));				
			}

		}

		if (true)
		{
			// Prepare sort process 
			if ( ! array_key_exists("sort$type", $_GET) )
				$sort = 'Host';
			else
				$sort = $_GET["sort$type"];
				
			if ( ! array_key_exists("reverse$type", $_GET) )
				$reverse = false;
			else
				$reverse = $_GET["reverse$type"]=='true';

			// modify data before displaying

			if ($format_func != null) {
				call_user_func_array($format_func, array( & $data ));
			}

			// add empty entries 
			if ($config['showempty']) {
				// could be improved by caching the $all array
				$all = array();
				foreach ($machines as $k => $d) {
					$host = $d->getName();
					$all[] = $host;
				}
				$some = array();
				foreach ($data as $k => $d) {
					$host = $d->getHost();
					$some[] = $host->getName();			
				}
				$fill = array_diff($all, $some);
				foreach ($fill as $host) { 
					$object = new $type;
					$machine = new Machine();
					$machine->setName( $host );

					// Update host<=>component link
					$object->setHost(& $machine);
					//$host->m_Components[$type][] = & $object;
					$data[] = & $object;
					unset($machine);
					unset($object);
				}
			}
				
			// Sort data with parameters given in the query string
			sortObjects($data, $sort, $reverse);
	
			// This code prevents the program from losing machine and sort informations while changing sort on the current table.
			$params = array();
			foreach ( $_GET as $key => $value )	
				if ( $key!="reverse$type" && $key!="sort$type" )	
					$params[] = $key .'='. $value;
	
			if ( empty($params) )
				$query = $_ENV['SCRIPT_NAME'] .'?';
			else
				$query = $_ENV['SCRIPT_NAME'] .'?'. join('&', $params) .'&';


			// For each data
			for ( $i=0 ; $i<count($data) ; $i++ )
			{
				$object = & $data[$i];
				// Retrieve parameters, including host name
				$host = & $object->getHost();
	
				$properties = $object->getProperties();
				$properties['Host'] = $host->getName();

				$firstapparition = $object->getFirstApparition();
								
				if ( empty($firstapparition) )
					$properties['FirstApparition'] = 'N/A';
				else
					$properties['FirstApparition'] = $firstapparition;
 
				// For each properties
				foreach ( $properties as $property => $value )
				{

					// The first time, update sort options in the template
					if ( $i==0 )
					{
						$pattern = "SORT_". strtoupper($property);

						if ( $sort==$property )
						{
							if ( ! $reverse )
							{
								$url = $query . "sort$type=$property&reverse$type=true";
								$template->set_var($pattern, '<a href='. $url .'><img src="images/triangle_asc.png"/></a>');
							}
							else
							{
								$url = $query . "sort$type=$property&reverse$type=false";
								$template->set_var($pattern, '<a href='. $url .'><img src="images/triangle_desc.png"/></a>');
							}
						}
						else
						{
							$url = $query . "sort$type=$property";
							$template->set_var($pattern, '<a href='. $url .'><img src="images/triangle_none.png"/></a>');
						}
					}

					// Graphs
					if (extension_loaded('gd')) 
					  {
					    $urlg = 'graphs.cgi?'. join('&', $params) .'&' . "type=$type&field=$property";
					    $template->set_var( "GRAPH_". strtoupper($property),
							    '<a href='. $urlg .'><img src="images/graph.png" alt="Graph it!"/></a>'
								);
					  } else {
					    $template->set_var( "GRAPH_". strtoupper($property), "");
					  }

					if ( !empty($value) )

						$sortable[$property] = 1;

					// Set a special class for sorted column
					if ( $sort==$property )
						$tdclass = "sorted";
	
					else
						$tdclass = "";
	
					$template->set_var(strtoupper($property) .'_CLASS', $tdclass);
					
					// Perform special formatting operations if needed
					if ( $value!="" && array_key_exists($property, $formatter) )
					{
						switch ($formatter[$property])
						{
							case 'Number':
								$value = formatNumber($value);
								break;
							case 'MegaByte':
								$value = formatBytes($value,2);
								break;
							case 'KiloByte':
								$value = formatBytes($value,1);
								break;
							case 'Byte':
								$value = formatBytes($value);
								break;
							case 'YesNo':
								$value = $value==1 ? $text{'yes'} : $text{'no'};
								break;
							default:
								call_user_func($formatter[$property], array( &$value ));
								break;
						}
					}
	
					// Fill the current property in the table
					$template->set_var(strtoupper($property), $value);
					$delprop[] = strtoupper($property);
				}
	
				$parity = $i%2==0 ? 'pair' : 'impair';
				$template->set_var('ROWCLASS', $parity);
				$template->set_var('HOSTL', '<a href="'.$_SERVER['PHP_SELF'].'?host='.$properties['Host'].'">'.$properties['Host'].'</a>');
	
				// Parse the current row
				$template->parse('rows', 'row', true); 
				
				// reset props
				foreach ($delprop as $p)
					$template->set_var(strtoupper($p), "");
				unset($delprop);
			}			
		}
		
		// If there is no data to display
		if ( $data==null )
		{
			// Make the template fields blanks
			$undefineds = $template->get_undefined("template");
			
			$columncount = 0;
			foreach ($undefineds as $undefined)
				if ( eregi('^SORT', $undefined) )
				{
					$template->set_var($undefined, '');
					$columncount++;
				}

			// And print a message
			$template->set_var('rows', "<tr><td colspan=\"$columncount\">${text[no_informations]}</td></tr>");
		}

		// Set the CSV download link
		$downloadurl = 'csv.cgi?mac='. $_GET['mac'] .'&type='. $type .'&group='. $_GET['group'].'&profile='. $_GET['profile'];
		$template->set_var('DONWLOAD_URL', $downloadurl);

		$undefineds = $template->get_undefined("template");

		if ( !empty($undefineds) )

			foreach ($undefineds as $undefined)
	
				$template->set_var($undefined, '');

		// Display the template
		$template->parse('out', 'template', 'template');
		$template->p('out');
	}

	/**
	 * Display a nice graph from data
	 * 
	 * @param type Type of data.
	 * @param sort Field
	 */
	function renderGraph( $type, $sort)
	{
		global $machines, $datasource, $text;

		$id = "$type $sort";
		// Retrieve data if needed
		if ( $data==null && !empty($type) )
		{
			// Retrieve objects to fill
			$data = & $datasource->read($type, $machines);
			$canfirstappear = true;
		}
		else
			$canfirstappear = false;
				
		$sortable = array();

		// If there is no data to display
		if ( $data==null )
		{

		}
		else
		{			
			$chart = new PieChart(1000, 550);

			// For each data count the occurence
			$occ = array();
			for ( $i=0 ; $i<count($data) ; $i++ )
			{
				$object = & $data[$i];
				ereg("([^0-9]+)([0-9]*)$", $sort, $match);
				$realfield = $match[1];
				$subfield = $match[2];
				$properties = $object->getProperty($realfield);
				if ($subfield != "") {
					$d = split("\|", $properties);
					$d = trim($d[$subfield]);
				} else {
					$d = $properties;
				}
				$div = 1;
				$mod = 0;
				$suffix = "";
				switch($id) {
				case "BootGeneral TotalMem":
					$div = 1024;
					$mod = 64;
					$suffix = " MB";
					break;
				case "BootGeneral Freq":
					$div = 1;
					$mod = 200;
					$suffix = " Mhz";
					break;
				case "BootDisk Capacity":
					$div = 1000;
					$mod = 20;
					$suffix = " GB";
					break;
				}

				// filter data in ranges
				if ($div != 1) {
					$d /= $div;
					$d = round($d);
				}
				if ($mod) {
					$d /= $mod;
					$d = round($d);
					$d *= $mod;
					if ($d != 0) $d = ($d-$mod+1)."-".$d;
					
				}
				if ($suffix != "") {
					$d = $d.$suffix;
				}
				$occ[$d] ++;
			}
			
			foreach($occ as $key => $value)
			  $chart->addPoint(new Point("$key ($value)", $value));

			$title = $object->getDesc("this").", ".$object->getDesc($sort);
			$chart->setTitle(ucfirst($title));
			header("Content-type: image/png");
			@$chart->render();

		}
	}
	
	/**
	 * Sort objects agree to paramaters.
	 * 
	 * @param data Data to sort.
	 * @param field The field on which the sort shall occurs.
	 * @param reverse Tells if the sort shall be inversed.
	 */
	function sortObjects(&$data, $field='Host', $reverse=false)
	{
		global $currentsortfield, $currentsortreverse;

		$currentsortfield = $field;
		$currentsortreverse = $reverse;

		usort($data, "sortFunction");
	}
	
	/**
	 * Internal function used to sort. See usort php function for more informations.
	 * 
	 * @param a The first object to compare.
	 * @param b The second object to compare.
	 * @return An indice telling which of the 2 objects is the greater.
	 */
	function sortFunction(&$a, &$b)
	{
		global $currentsortfield, $currentsortreverse;

		$numeric = 0;

		if ( $currentsortfield=='Host' )
		{
			$hosta = & $a->getHost();
			$hostb = & $b->getHost();

			$vala = $hosta->getName();
			$valb = $hostb->getName();
		}
		elseif ( $currentsortfield=='FirstApparition' )
		{
			$vala = $a->getFirstApparition();
			$valb = $b->getFirstApparition();
		}
		else
		{
			$vala = $a->getProperty($currentsortfield);
			$valb = $b->getProperty($currentsortfield);
		}

		if ( $currentsortfield == 'ExecutableSize' ||
		     $currentsortfield == 'TotalSpace' ||
		     $currentsortfield == 'FreeSpace' ||
		     $currentsortfield == 'FileCount'
		     )
		{
			$numeric = 1;
		}

		// Empty fields are always in the bottom
		if ( empty($vala) )
			return 1;
		else if ( empty($valb) )
			return -1;

		if ( $numeric ) {
			$ret = ( $vala < $valb ) ? -1 : 1 ;
			if ( $vala == $valb ) $ret = 0;
		}
		else {
			$ret = strcasecmp($vala,$valb);
		}
		
		if ( $currentsortreverse )
			$ret *= -1;

		return $ret;
	}

	/**
	 * Formats an integer in a size-friendly format.
	 * 
	 * @param size The integer to format.
	 * @param begin The original size type (0 for bytes, 1 for kilobytes, 2 for Megabytes etc).
	 * @return The formatted integer.
	 */
	function formatBytes($size, $begin=0)
	{
		global $text;

		if ( $size==-1 )

			return $size;

		$units = explode(',', $text['size_units'] );

		for ( $i=$begin ; $i<count($units) ; $i++ )
		
			if ( $size>1024 )
				$size /= 1024;

			else
				break;
				
		# bug in number format ?
		#if ( is_float($size) )
		#	$size = number_format( $size , 1, $text['thousand_separator'], $text['number_comma']) .' '. $units[$i];
		#else
			$size = number_format($size, 0, $text['thousand_separator'], $text['number_comma']) .' '. $units[$i];
		
		return $size;
	}

	/**
	 * Formats a number in the french form.
	 * 
	 * @param number The integer to format.
	 * @return The formatted number.
	 */
	function formatNumber($number)
	{
		global $text;

		return number_format($number, 0, $text['thousand_separator'], $text['number_comma']);
	}

	/**
	 * Convert an hexadecimal number to a textual partition type description
	 * 
	 * @param value parameters
	 */
	function formatPart($value)
	{
		global $parttype;
		
		$value[0] = $parttype[intval($value[0], 16)];
	}
	
	/**
	 * Displays an error message whenever a required field is leave empty by the user.
	 * 
	 * @param fieldname The name of the empty field.
	 */
	function errorFieldEmpty($fieldname)
	{
		global $erroroccured;
		
		$erroroccured = true;

		$template = tmplInit(array('template' => 'FieldEmpty.tpl'));

		$template->set_var('FIELD_NAME', $fieldname);

		// Display the template
		$template->pparse("out", "template", "template");
	}
	
	/**
	 * Tells if one or more errors has already occured. An error is said when errorFieldEmpty is called.
	 * 
	 * @return True if an error occured, false otherwise.
	 */
	function errorOccured()
	{
		global $erroroccured;
		
		return $erroroccured;
	}

	/**
	 * Tests if a machine is currently connected to the network
	 *
	 * @param machine The machine name to test the presence.
	 * @return True if the machine is connected, false otherwise.
	 */
	function isConnected($machine)
	{
		// Try to open a socket
		$fh = @fsockopen($machine, 22);

		// Return the opening result
		if ( $fh===false )

			return false;
		else
		{
			fclose($fh);
			return true;
		}
	}

	/**
	 *
	 */
	function & findOrCreateObject(&$data, $host, $type)
	{
		// find function
		$found = 0;
		foreach($data as $id => $obj) {
			if (get_class($obj) == strtolower($type)) {
				$h = $obj->getHost();
				$h = $h->getName();
				if ($h == $host) 
				{
					$found = 1;
					break;
				}
			}
		}

		if (!$found) {
			// create a new object
			$machine = new Machine();
                	$machine->setName($host); 

			$obj = new $type();
			$obj->setHost($machine);
			
			$data[] = & $obj;
		} else {
			// copy the object and turn it to a reference so that the call
			// will be able to modify the object and not a copy...
			$obj2 = $obj;
			unset($data[$id]);
			$data[] = & $obj2;
			return($obj2);
		}
		
		//print "<pre>";
		//print_r($obj);
		return($obj);
	}

	/**
	 *
	 */
	function getMacForMachine(&$machine)
	{
		$ether = etherLoad();
		normalize_machine_names($ether);

		foreach ( $ether as $mac=>$info )
		{
			$name = $machine->getName();

			if ( eregi("[:/]$name$", $info['name']) )

				return $mac;
		}

		return '';
	}
	
	/**
	 * Reverse a date (should be in lbs_common ?)
	 *
	 * @param data string containing a date like DD/MM/YYYY
	 * @return returns YYYY-MM-DD.
	 */
	function dateReverseToSQL($data)
	{
		global $reversedate;
		if (!$reversedate) return $data;

		$ret = ereg_replace("([0-9]{1,2})/([0-9]{1,2})/([0-9]{4})", "\\3-\\2-\\1", $data);
		return $ret;
	}

	/**
	 * Reverse a date (should be in lbs_common ?)
	 *
	 * @param data string containing a date like YYYY-MM-DD
	 * @return returns DD/MM/YYYY.
	 */
	function dateReverseFromSQL($data)
	{
		global $reversedate;
		if (!$reversedate) return $data;

		$ret = ereg_replace("([0-9]{4})-([0-9]{1,2})-([0-9]{1,2})", "\\3/\\2/\\1", $data);
		return $ret;
	}
	
?>
