#!/var/lib/lrs/php
<?php

	// Assuming script is always run as root
	// (necessary for using the distant control class)
	$_ENV['REMOTE_USER'] = 'root';

	include_once('request/ssh.inc.php');
	include_once('functions.php');
	include_once('classes/DataSource.php');

	include_once('/usr/share/webmin/lbs_common/lbs_common.php');

	// Load LBS configuration
	initLbsConf('/etc/lbs.conf');

	$ether = etherLoad();

	$machines = array();

	// Retrieve all machine names to retrieve informations
	$fh = fopen('toproceed.txt', 'r');
	while ( !feof($fh) )
	{
		$name = trim ( fgets($fh, 4096) );

		if ( !empty($name) )

			$machines[] = $name;
	}
	fclose($fh);

	$machinestmp = $machines;

	// For each machines
	for ( $i=count($machines)-1 ; $i>=0 ; $i-- )
	{
		$machine = $machines[$i];

		// If the machine is available
		if ( isConnected($machine) )
		{
			$mac = '';

			// Find the corresponding mac address
			foreach ($ether as $cmac=>$info)

				if ( eregi("[\:\/]$machine$", $info['name'] ) )

					$mac = $cmac;

			// If a machine/mac address has been found
			if ( !empty($mac) )
			{
				// Create a SSH session
				$ssh = new LSC_Session($mac);

				// Execute the inventory
				$command = "C:/Progra~1/LRSInv~1/lrs-inventory.exe";
	
				$ssh->LSC_cmdAdd($command);
				$results = $ssh->LSC_cmdFlush();

				// The current machine has been processed
				unset($machinestmp[$i]);

			}

		}

	}

	// Store the unreachable machines
	$fh = fopen('toproceed.txt', 'w');
	fputs( $fh, join("\n", $machinestmp) );
	fclose($fh);

?>