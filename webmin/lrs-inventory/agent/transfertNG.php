<?php
#
# $Id$
#
# Linbox Rescue Server
# Copyright (C) 2005  Linbox FAS
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

	$QUERY;
	$DEVICEID;
	$DATA;

	include_once('../classes/DataSource.php');

	// Load data source
	$datasource = & DataSource::getDefaultDataSource();

	// Read compressed data
	$data = "";
	$stdin = fopen('php://input','r');
	while (!feof($stdin)) {
	    $data .= fread($stdin, 8192);
	}
	fclose($stdin);
	// Uncompress it
	$DATA = gzuncompress($data);
	
	system("rm /tmp/${_SERVER[REMOTE_ADDR]}.tmp -f");
	
	// Retrieve query and sender
	ereg("<QUERY>([a-zA-Z0-9_-]+)</QUERY>", $DATA, $matches);
	$QUERY = $matches[1];
	
	ereg('<DEVICEID>([a-zA-Z0-9_-]+)</DEVICEID>', $DATA, $matches);
	$DEVICEID = $matches[1];
		
	//exec("echo \"$DATA\" >>/tmp/log");
	//$DEBUG = true;

	if ( $QUERY=='PROLOG' ) {
		// Always send the inventory
		$resp = '<?xml version="1.0" encoding="utf-8" ?><REPLY><RESPONSE>SEND</RESPONSE></REPLY>';
	}
	else if ( $QUERY=='INVENTORY' )
	{
		// Extract inventory data
		ereg('<CONTENT>(.+)<\/CONTENT>', $DATA, $matches);
		$INVENTORY = '<?xml version="1.0" encoding="utf-8" ?><Inventory>'. $matches[1] .'</Inventory>';
		$resp = '<?xml version="1.0" encoding="utf-8" ?><REPLY><RESPONSE>no_account_update</RESPONSE></REPLY>';

		// Store data on the server
		// Parse data
		$machines = & $datasource->readMachine( array($DEVICEID), null, 'OcsNG' );

		for ( $i=0 ; $i<count($machines) ; $i++ )
		{
			$machine = & $machines[$i];
			if ($machine->getName() != "") {
				foreach ( array_keys($machine->m_Components) as $type ) {
					$datasource->write($machine->m_Components[$type]);
				}
			}
		}

	}

	print gzcompress($resp);
	
?>
