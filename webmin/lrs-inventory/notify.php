#!/var/lib/lrs/php
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
#
	include_once('classes/DataSource.php');

	$datasource = & DataSource::getDefaultDataSource();

	// Retrieve all machines
	$machines = & $datasource->readMachine();

	// Retrieve today and yesterday date
	$today     = date('Y-m-d', time());
	$yesterday = date('Y-m-d', time() - (24 * 60 * 60));

	$mail = '';

	// For each types to inspect
	//$types = array('Software','Hardware','Network','Printer','Drive','VideoCard');
	$types = array('Bios','Controller','Drive','Hardware','Input','Memory','Modem','Monitor','Network','Port','Printer','Software','Sound','Storage','VideoCard');

	foreach ( $types as $type )
	{
		$typedisplayed = false;

		// Read yesterday type components
		$datasource->read($type, $machines, $yesterday);
	
		$components = array();
	
		// Store them in an array
		for ( $i=0 ; $i<count($machines) ; $i++ )
		{
			$machine = & $machines[$i];
	
			$oldcomponents[ $machine->getName() ] = $machine->getComponents($type);
		}

		// Read today type components
		$datasource->read($type, $machines, $today);

		// For each machines
		for ( $i=0 ; $i<count($machines) ; $i++ )
		{
			$namedisplayed = false;

			$machine = & $machines[$i];

			$new = & $machine->getComponents($type);
			$old = & $oldcomponents[ $machine->getName() ];

			// Make diffs to retrieve added and deleted components between the 2 inventories
			$add = & diff($new, $old);
			$del = & diff($old, $new);

			// Put all addition informations in a string
			foreach ( $add as $comp )
			{
				if ( ! $namedisplayed )
				{
					if ( ! $typedisplayed )
					{
						$mail .= $type ."\n\n";
						$typedisplayed = true;
					}

					$host = & $comp->getHost();
					$mail .= "  ". $host->getName() ."\n";

					$namedisplayed = true;
				}

				$mail .= "  + ". $comp->toString() ."\n";
			}

			// Put all remove informations in a string
			foreach ( $del as $comp )
			{
				if ( ! $namedisplayed )
				{
					if ( ! $typedisplayed )
					{
						$mail .= $type ."\n\n";
						$typedisplayed = true;
					}

					$host = & $comp->getHost();
					$mail .= "  ". $host->getName() ."\n";

					$namedisplayed = true;
				}				
				$mail .= "  - ". $comp->toString() ."\n";
			}

			if ( $namedisplayed )

				$mail .= "\n";
		}
	}

	// If changes occur
	if ( !empty($mail) ) {
		// Send a them by mail
		mail('ocsinventory@localhost', '[LRS Inventory] changes', $mail);
		//echo $mail;
	}

	// Make a diff between 2 arrays
	function & diff(&$a, &$b)
	{
		$diffs = array();

		$lena = count($a);
		$lenb = count($b);	

		# filter out some data
		$filter = array ("Date", "SwapSpace", "FreeSpace", "FileCount", "User");
		foreach ($filter as $prop) {
			for ( $i=0 ; $i<$lena ; $i++ )
				unset($a[$i]->m_Properties{$prop}); // = "";
			for ( $i=0 ; $i<$lenb ; $i++ )
				unset($b[$i]->m_Properties{$prop}); // = "";
		}

		// For each components in a
		for ( $i=0 ; $i<$lena ; $i++ )
		{
			$c1 = & $a[$i];

			$find = false;

			// Search for it in b
			for ( $j=0 ; $j<$lenb && $find==false; $j++ )
			{
				$c2 = & $b[$j];
				
				if ( $c1->equals($c2) ) {
					$find = true;
				}
			}

			// If the component is in not the 2 arrays
			if ( ! $find )

				// Put it in the differences array
				$diffs[] = & $c1;

		}

		return $diffs;
	}
?>
