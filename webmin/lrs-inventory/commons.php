<?php

	include_once('lbs-inventory.php');
	include_once('functions.php');

	// Init configuration
	lib_init_config();

	// Load data source
	$datasource = & DataSource::getDefaultDataSource();

	// Load LBS configuration
	initLbsConf('/etc/lbs.conf');

	// default language in $lang
	$lang = "en";
	if ( $gconfig["lang"] ) $lang = $gconfig["lang"];
	if ( $gconfig["lang_".$remote_user] ) $lang = $gconfig["lang_".$remote_user];		

	// date should be reversed ?
	$reversedate = ($lang == "fr");	
	
	// And get all machine informations
	$ether = etherLoad();

	// Filter machines to display
	if ( $_GET['profile'] == "" ) $_GET['profile'] = "all";
	
	if ( !empty($_GET['mac']) ) {
		foreach ( $ether as $mac=>$infos )
		{
			if ( $mac!=$_GET['mac'] )
				unset( $ether[$mac] );
		}
	}
	elseif ( !empty($_GET['group']) ) {
		filter_machines_names('',$_GET['group'],&$ether);
	}
	elseif ( !empty($_GET['profile']) || $_GET['profile'] == "all" ) {
		$prof = $_GET['profile'];
		if ( $prof == "all" ) $prof = ""; // bug in filter_machines_names ?
		filter_machines_names($prof,'',&$ether);
	}

	// Get all MAC addresses
	$macaddresses = array();

	if ( !empty($_GET['host']) ) {
		// yes readMachine() also accepts host names
		$macaddresses[] = $_GET['host'];
		$machinenames[] = $_GET['host'];
	} else {
		foreach ( $ether as $mac=>$infos )
		{
			$name = ereg_replace('^.*[\:\/]','',$infos['name']);

			$machinenames[] =  $name;
			$macaddresses[] = $mac;
		}
	}	

	// special case: get everything which is in the database
	if (($_GET['group'] == "") && ($_GET['profile'] == "all") 
	    && ($_GET['mac'] == "") && ($_GET['host'] == "")) {
		$macaddresses[] = "*ALL*";
	}

	// Read machine objects
	$machines = $datasource->readMachine( $macaddresses );

	// Add missing machines
	// (Those which aren't in the data source)

	// So first, retrieve all read machine names
	$readnames = array();

	for ( $i=0 ; $i<count($machines) ; $i++ )
	{
		$machine = & $machines[$i];

		$readnames[] = $machine->getName();

		unset($machine);
	}

	// And check if machines has been read
	if ( $machinenames ) {
		foreach ( $machinenames as $name )
		{
			// If not
			if ( ! in_array($name, $readnames) )
			{
				// Add it to the machine list
				$machine = new Machine();
				$machine->setName($name);
				$machines[] = & $machine;

				unset($machine);
			}
		}
	}

	$DefaultCustomFields = array('Location','Phone','BuyDate','WarrantyEnd','Comments');

	$erroroccured = false;
	
	$machines_clean = $machines;

?>
