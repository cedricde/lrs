#!/var/lib/lrs/php -q
<?
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

include_once('../../../classes/DataSource.php');
include_once('/usr/share/webmin/lbs_common/lbs_common.php');

initLbsConf('/etc/lbs.conf');
$ether = etherLoad(1);

// get the client name from the MAC addr
$file = $argv[1];
$mac = "";
if (preg_match("/\/(..)(..)(..)(..)(..)(..)\.ini/", $file, $m)) {
	$mac = $m[1].":".$m[2].":".$m[3].":".$m[4].":".$m[5].":".$m[6];
}
$name = $ether[$mac]['name'];
preg_match("/([^\/:]+)$/", $name, $m);
$machine = $m[1];

if ($machine == "")
{
	echo("Unknown mac address '$mac'\n");
	exit(1);
}


$datasource = & DataSource::getDefaultDataSource();

// Assuming Ocs3 Source is always a CsvDriver-derivated class
$csvdriver = & $datasource->getSourceDriver('Ini');

// Read data sent by the client
$machines = & $datasource->readMachine( array($machine), null, 'Ini' );
$data = & $datasource->read("any", $machines, null, 'Ini');
// Store them on the default storage location

//print_r($machines);
//print_r($data);

$datasource->write($data);




?>
