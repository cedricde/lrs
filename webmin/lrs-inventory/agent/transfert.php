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

include_once('../classes/DataSource.php');

session_save_path("/tmp");
session_id("lrsinventoryphpsession");	// global session hack
@session_start();			// Will complain for not being able to send cookies

$id = $_SERVER['REMOTE_ADDR'];

	if ( $_SERVER['REQUEST_METHOD']=='GET' )
	{
		$transacid = md5( rand() );
		$_SESSION[$id."fichier"] = $_GET['fichier'];
	}
	elseif ( $_SERVER['REQUEST_METHOD']=='POST' )
	{
		// Load data source
		$datasource = & DataSource::getDefaultDataSource();

		$file = $_POST["fullpath"];

		if (empty($file)) {
			$file = $_SESSION[$id."fichier"];
		}
		
		// Find the correct type of data sent
		ereg('([a-zA-Z0-9]*)[\\//]+([a-zA-Z0-9_-]+)\.csv$', $file, $matches);
		$directory = $matches[1];
		$machine = $matches[2];
		
		$smachine = ereg_replace('-[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{2}-[0-9]{2}-[0-9]{2}$', '', $machine);

		// try to determine if it's a new inventory or not
		$nid = $id.$smachine;
		$invid = array();
		if ( $_SESSION[$nid."lastreceived"] ) {
			if ( time() - $_SESSION[$nid."lastreceived"] < 60 ) {
				// last request < 60seconds => same inventory
				$invid = $_SESSION[$nid."invid"];
			}
		}
		if (empty($invid)) {
			$_SESSION[$nid."invid"] = array();
		}		
		$_SESSION[$nid."lastreceived"] = time();

		// Assuming Ocs3 Source is always a CsvDriver-derivated class
		$csvdriver = & $datasource->getSourceDriver('Ocs3');
		$type = $csvdriver->getTypeForDirectory($directory);

		if ( !empty($type) )
		{
			// Read data sent by the client
			$machines = & $datasource->readMachine( array($machine), null, 'Ocs3' );
			$data = & $datasource->read($type, $machines, null, 'Ocs3');
			$driver = & $datasource->getDefaultSourceDriver();
			// Store them on the default storage location
			$driver->setInvId($invid);
			$datasource->write($data);
			$invid = $driver->getInvId();
			if ( ! $_SESSION[$nid."invid"] ) {
				$_SESSION[$nid."invid"] = $invid;
			}
		}

		// Ok
		print "ok - $type read";
	}

?>
