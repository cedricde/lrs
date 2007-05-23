<?
#
# $Id$
# Import LRS-Inventory data into the GLPI database.
#
# Linbox Rescue Server
# Copyright (C) 2007  Ludovic Drolez, Linbox FAS
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

# LRS paths init
include_once(dirname(__FILE__).'/../../lbs_common/lbs_common.php');
$config = lib_read_file("/etc/webmin/lrs-inventory/config");

# GLPI init
$NEEDED_ITEMS=array("computer", "device", "link", "monitor", "enterprise", "printer", "peripheral");
include ("_relpos.php");
include ($phproot . "/config/based_config.php");
include ($phproot . "/inc/includes.php");
include ($phproot . "/inc/search.class.php");
$db = new DB;

# LRS Inventory init
error_reporting(E_ALL);
include_once(dirname(__FILE__).'/../classes/DataSource.php');
$datasource = & DataSource::getDefaultDataSource();

/**
 * Import a dropdown from OCS table.
 *
 * This import a new dropdown if it doesn't exist.
 *
 *@param $dpdTable string : Name of the glpi dropdown table.
 *@param $dpdRow string : Name of the glinclude ($phproot . "/glpi/includes_devices.php");pi dropdown row.
 *@param $value string : Value of the new dropdown.
 *
 *@return integer : dropdown id.
 *
 **/
function ocsImportDropdown($dpdTable,$dpdRow,$value) {
	global $db,$cfg_glpi;

	if (empty($value)) return;

	$query2 = "SELECT * 
		FROM ".$dpdTable." 
		WHERE $dpdRow='".$value."'";
	$result2 = $db->query($query2);
	if($db->numrows($result2) == 0) {
		if (in_array($dpdTable,$cfg_glpi["dropdowntree_tables"])&&$dpdRow=="name"){
			$query3 = "INSERT INTO ".$dpdTable." (".$dpdRow.",completename) 
				VALUES ('".$value."','".$value."')";
		} else {
			$query3 = "INSERT INTO ".$dpdTable." (".$dpdRow.") 
				VALUES ('".$value."')";
		}
		$db->query($query3);
		return $db->insert_id();
	} else {
		$line2 = $db->fetch_array($result2);
		return $line2["ID"];
	}

}

/**
 * Import general config of a new enterprise
 *
 * This function create a new enterprise in GLPI with some general datas.
 *
 *@param $name : name of the enterprise.
 *
 *@return integer : inserted enterprise id.
 *
 **/
function ocsImportEnterprise($name) {
	global $db;
	if (empty($name)) return;
	$query = "SELECT ID 
		FROM glpi_enterprises 
		WHERE name = '".$name."'";
	$result = $db->query($query);
	if ($db->numrows($result)>0){
		$enterprise_id  = $db->result($result,0,"ID");
	} else {
		$entpr = new Enterprise;
		$entpr->fields["name"] = $name;
		$enterprise_id = $entpr->addToDB();
	}
	return($enterprise_id);
}

/**
 * Add a new device.
 *
 * Add a new device if doesn't exist.
 *
 *@param $device_type integer : device type identifier.
 *@param $dev_array array : device fields.
 *@param $new new device flag returned.
 *
 *@return integer : device id.
 *
 **/
function ocsAddDevice($device_type, $dev_array, &$new) {

	global $db;
	
	$new = 0;
	if (! isset($dev_array["designation"])) return "";
	$query = "SELECT ID 
		FROM ".getDeviceTable($device_type)." 
		WHERE designation='".$dev_array["designation"]."'";
	$result = $db->query($query);
	if($db->numrows($result) == 0) {
		$dev = new Device($device_type);
		foreach($dev_array as $key => $val) {
			$dev->fields[$key] = $val;
		}
		$new = 1;
		return($dev->addToDB());
	} else {
		$line = $db->fetch_array($result);
		return $line["ID"];
	}

}

/**
 * Get the GLPI computer ID
 *
 * @param $name computer name
 */
function getComputer($name)
{
	global $db;
	
	$q = "SELECT ID FROM glpi_computers WHERE name='$name'";
	$result = $db->query($q);
	if ($db->numrows($result) == 0) {
		$comp = new Computer();
		$comp->fields["name"] = $name;
		return $comp->addToDB();
	} else {
		$line = $db->fetch_array($result);
		return $line["ID"];
	}
}

/**
 * Get one inventory item for client $name of type $type 
 *
 * @param $name client name
 * @param $type inventory type
 */
function getInvLine($name, $type)
{
	global $datasource;
	
	$dr = $datasource->getSourceDriver("");
	$dr->forceUse();
	$machines = & $datasource->readMachine( array($name));
	$data = & $datasource->read($type, $machines);
	$object = & $data[0];
	$props = $object->getProperties();
	return $props;
}

/**
 * Get all inventory items for client $name of type $type 
 *
 * @param $name client name
 * @param $type inventory type
 */
function getInvLines($name, $type)
{
	global $datasource;
	
	$dr = $datasource->getSourceDriver("");
	$dr->forceUse();
	$machines = & $datasource->readMachine( array($name));
	$data = & $datasource->read($type, $machines);
	return $data;
}

/**
 * Remove array keys which have an empty value
 *
 * @param $var the array
 */
function arrayClean(&$var)
{
	foreach ($var as $key => $value) {
		if ($value == "" || $value == "N/A") unset($var[$key]);
		else $var[$key] = utf8_encode($value);
	}
}

/**
 * Calls compdevice_add but 1st checks that the link does not exists
 * If the link exists update the specificity
 *
 * @param $var the array
 */
function compdeviceAdd($cID, $device_type, $dID, $specificity='',$dohistory=1)
{
	global $db;
	
	if ($dID == "") return;
	
	$q = "SELECT ID FROM glpi_computer_device WHERE device_type=$device_type
		AND FK_device=$dID AND FK_computers=$cID";
	if ($specificity != "") {
		$q .= "	AND specificity=\"$specificity\"";
	}
	DEBUGI($q);
	$result = $db->query($q);
	if ($db->numrows($result) == 0) {
		$id = compdevice_add($cID, $device_type, $dID, $specificity,$dohistory);
	} else {
		$line = $db->fetch_array($result);
		$id = $line["ID"];
		//if ($specificity != "")
		//	update_device_specif($specificity, $id, 1);
	}
	return $id;
}

/**
 * Get the id of a GLPI object 
 *
 * @param $table the DB table
 * @param $where_array array containing the attributes for the WHERE search
 * @return the id or "" if nothing found
 */
function getGlpiId($table, $where_array)
{
	global $db;
	
	$ret = "";
	$q = "SELECT ID FROM $table WHERE ";
	$and = "";
	foreach ($where_array as $k => $v) {
		$q .= " $and $k='".$v."'";
		$and = "AND";
	}
	DEBUGI("periph: $q");
	$result = $db->query($q);
	if ($db->numrows($result) >= 1) {
		$line = $db->fetch_array($result);
		$ret = $line["ID"];
	}
	return $ret;
}

/**
 *
 * Makes a direct connection. Calls Connect() only if the connection
 * does not already exist.
 *
 *
 * @param $sID connection source ID.
 * @param $cID computer ID (where the sID would be connected).
 * @param $type connection type.
 */
function periphConnect($sID, $cID, $type) {
	global $db;
	
	$id = getGlpiID("glpi_connect_wire", 
		array("type" => $type, "end1" => $sID, "end2" => $cID));
	DEBUGI("periph: $id");
	if ($id != "") return $id;
	return Connect($sID, $cID, $type);
	
}

/**
 * Check if some fields have been manually modified in GLPI
 * If so, those fields are not over-writen.
 *
 * @param $compid computer id
 * @param $type device type
 * @param $array changed values by the LRS-Inventory
 * @param $fields array of fields, which should be checked.
 */

function checkUpdated($compid, $type, & $array, $fields)
{
	global $db, $SEARCH_OPTION;

	foreach($fields as $field) {
		$ids = "";
		foreach($SEARCH_OPTION[$type] as $k => $v) {
			if ($v['linkfield'] == $field) $ids=$k;
		}
		if ($ids == "") continue;
		
		$q = "SELECT ID, new_value FROM glpi_history WHERE FK_glpi_device=$compid 
			AND device_type=$type AND id_search_option=$ids ORDER BY ID DESC LIMIT 1";
		$result = $db->query($q);
		if ($db->numrows($result) > 0) {
			$line = $db->fetch_array($result);
			DEBUGI($line);
			if (trim($line[1]) != "" && $line[1] != "&nbsp;") {
				$array[$field] = "";
			}
		}
	}
}


// debug
function DEBUGI($var)
{
	//print_r($var);
}

/**
 *
 */
function import($mach) 
{
	global $datasource;
	
	// Computer name import
	$props = getInvLine("$mach", "Hardware");
	$bios = getInvLine("$mach", "Bios");
	DEBUGI($props);
	DEBUGI($bios);
	$compid = getComputer("$mach");
	$dohistory = 0;		// if 1, need to implement mergeocsarray()
	
	// From Hardware table
	$compupdate["ID"] = $compid;
	$compupdate["ocs_import"] = 1;
	$compupdate["os"] = ocsImportDropdown('glpi_dropdown_os','name', $props["OperatingSystem"]);
	$compupdate["os_version"] = ocsImportDropdown('glpi_dropdown_os_version','name',$props["Version"]);
	$compupdate["domain"] = ocsImportDropdown('glpi_dropdown_domain','name',$props["Workgroup"]);
	$compupdate["contact"] = $props["User"];
	$compupdate["os_sp"] = ocsImportDropdown('glpi_dropdown_os_sp','name',$props["Build"]);
	$compupdate["comments"]="";
	if (!empty($props["Description"]) && $props["Description"] != "N/A") 
		$compupdate["comments"] .= $props["Description"]."\r\n";
	$compupdate["comments"] .= "Swap: ".$props["SwapSpace"];
	// From Bios table
	$compupdate["serial"] = $bios["Serial"];
	$compupdate["model"] = ocsImportDropdown('glpi_dropdown_model','name',$bios["Chipset"]);
	$compupdate["type"] = ocsImportDropdown('glpi_type_computers','name',$bios["TypeMachine"]);
	$compupdate["FK_glpi_enterprise"] = ocsImportEnterprise($bios["ChipVendor"]);
	
	checkUpdated($compid, COMPUTER_TYPE, $compupdate, 
		array("FK_glpi_enterprise", "os", "os_version", "domain", "contact", 
		      "os_sp", "serial", "model", "type")); 

	DEBUGI($compupdate);
	arrayClean($compupdate);
	$comp=new Computer();
	$comp->update($compupdate,$dohistory);
	
	// processor
	for($i = 0;$i < $props["ProcessorCount"]; $i++) {
		unset($dev);
		$dev["designation"] = $props["ProcessorType"];
		$dev["specif_default"] = $props["ProcessorFrequency"];
		arrayClean($dev);
		$devid = ocsAddDevice(PROCESSOR_DEVICE, $dev, $new);
		$lnkid = compdeviceAdd($compid, PROCESSOR_DEVICE, $devid, $props["ProcessorFrequency"]+$i, $dohistory);
	}
	
	// network card import test
	$datasource->m_ClassPrefix="My";
	foreach (getInvLines("$mach", "Network") as $inv) {;
		$net = $inv->getProperties();
		DEBUGI($net);
		unset($network);
		$network["designation"] = $net["CardType"];
		$network["bandwidth"] =  $net["Bandwidth"];
		arrayClean($network);
		$netid = ocsAddDevice(NETWORK_DEVICE, $network, $new);
		//we need compdevice_del ?
		$lnkid = compdeviceAdd($compid, NETWORK_DEVICE, $netid, $net["MACAddress"], $dohistory);
	}
	
	// memory 
	foreach (getInvLines("$mach", "Memory") as $inv) {;
		$data = $inv->getProperties();
		DEBUGI($data);
		unset($dev);
		$dev["designation"] = $data["ExtendedDescription"];
		$dev["specif_default"] = $data["Size"];
		$dev["frequence"] =  $data["Frequency"];
		$dev["type"] = ocsImportDropdown("glpi_dropdown_ram_type","name", $data["ChipsetType"]);
		arrayClean($dev);
		$devid = ocsAddDevice(RAM_DEVICE, $dev, $new);
		DEBUGI("$devid $new");
		$lnkid = compdeviceAdd($compid, RAM_DEVICE, $devid, $data["Size"], $dohistory);
	}
	
	// hard disks
	foreach (getInvLines("$mach", "Storage") as $inv) {;
		$data = $inv->getProperties();
		if (empty($data["DiskSize"]) || $data["DiskSize"]<=1000) continue;
		DEBUGI($data);
		unset($dev);
		$dev["designation"] = $data["VolumeName"];
		if ($dev["designation"] == "") $dev["designation"] = $data["Model"];
		$dev["specif_default"] = $data["DiskSize"];
		$dev["FK_glpi_enterprise"] = ocsImportEnterprise($data["Manufacturer"]);
		arrayClean($dev);
		$devid = ocsAddDevice(HDD_DEVICE, $dev, $new);
		$lnkid = compdeviceAdd($compid, HDD_DEVICE, $devid, $data["DiskSize"], $dohistory);
	}
	
	// other storage drives
	foreach (getInvLines("$mach", "Storage") as $inv) {;
		$data = $inv->getProperties();
		if (!empty($data["DiskSize"]) || $data["DiskSize"] > 1000) continue;
		DEBUGI($data);
		unset($dev);
		$dev["designation"] = $data["VolumeName"];
		if ($dev["designation"] == "") $dev["designation"] = $data["Model"];
		$dev["specif_default"] = $data["Model"];
		$dev["FK_glpi_enterprise"] = ocsImportEnterprise($data["Manufacturer"]);
		arrayClean($dev);
		$devid = ocsAddDevice(DRIVE_DEVICE, $dev, $new);
		$lnkid = compdeviceAdd($compid, DRIVE_DEVICE, $devid, $data["Model"], $dohistory);
	}
	
	// modems
	foreach (getInvLines("$mach", "Modem") as $inv) {;
		$data = $inv->getProperties();
		DEBUGI($data);
		unset($dev);
		$dev["designation"] = $data["Vendor"];
		if ($dev["designation"] == "") $dev["designation"] = "Modem";
		$dev["comment"] = $data["Type"]."\r\n".$data["ExpandedDescription"];
		$dev["specif_default"] = $data["Model"];
		arrayClean($dev);
		$devid = ocsAddDevice(PCI_DEVICE, $dev, $new);
		$lnkid = compdeviceAdd($compid, PCI_DEVICE, $devid, $data["Model"], $dohistory);
	}
	
	// comm ports
	foreach (getInvLines("$mach", "Port") as $inv) {;
		$data = $inv->getProperties();
		DEBUGI($data);
		unset($dev);
		$dev["designation"] = $data["Type"];
		if ($data["Caption"] != "None") 
			$dev["designation"] .= " ".$data["Caption"];
		else if ($data["Stamp"] != "Not Specified") 
			$dev["designation"] .= " ".$data["Stamp"];
		$dev["comment"] = $data["Description"];
		arrayClean($dev);
		$devid = ocsAddDevice(PCI_DEVICE, $dev, $new);
		$lnkid = compdeviceAdd($compid, PCI_DEVICE, $devid, "", $dohistory);
	}
	
	// video card
	foreach (getInvLines("$mach", "VideoCard") as $inv) {;
		$data = $inv->getProperties();
		DEBUGI($data);
		unset($dev);
		$dev["designation"] = $data["Model"]." ".$data["Chipset"];
		$dev["ram"] = $data["VRAMSize"];
		$dev["comment"] = $data["Resolution"];
		arrayClean($dev);
		$devid = ocsAddDevice(GFX_DEVICE, $dev, $new);
		$lnkid = compdeviceAdd($compid, GFX_DEVICE, $devid, $dev["ram"], $dohistory);
	}
	
	// sound card
	foreach (getInvLines("$mach", "Sound") as $inv) {;
		$data = $inv->getProperties();
		DEBUGI($data);
		unset($dev);
		$dev["designation"] = $data["Manufacturer"]." ".$data["Description"];
		arrayClean($dev);
		$devid = ocsAddDevice(SND_DEVICE, $dev, $new);
		$lnkid = compdeviceAdd($compid, SND_DEVICE, $devid, "", $dohistory);
	}
	
	
	// Peripherals
	// monitor
	unset($Monitor);
	foreach (getInvLines("$mach", "Monitor") as $inv) {;
		$moni = $inv->getProperties();
		DEBUGI($moni);
		unset($mon);
		$mon["name"] = $moni["Stamp"];
		if (empty($mon["name"])) $mon["name"] = $moni["Type"];
		if (empty($mon["name"])) $mon["name"] = $moni["Manuf"];
		$mon["FK_glpi_enterprise"] = ocsImportEnterprise($moni["Manuf"]);
		$mon["comments"] = $moni["Description"];
		$mon["serial"] = "n/a";
		if ($moni["Serial"] != "") $mon["serial"] = $moni["Serial"];
		$mon["date_mod"] = date("Y-m-d H:i:s");
		$mon["is_global"] = "0";
		arrayClean($mon);
		$monid = getGlpiId("glpi_monitors", 
			array(
				"name" => $mon["name"], 
				"serial" => $mon["serial"],
				"is_global" => $mon["is_global"]
				));
		if ($monid == "") {
			$m = new Monitor;
			$m->fields = $mon;
			$monid = $m->addToDB();
		}
		$connID = periphConnect($monid, $compid, MONITOR_TYPE);
	}
	
	// printers
	foreach (getInvLines("$mach", "Printer") as $inv) {;
		$data = $inv->getProperties();
		DEBUGI($data);
		unset($dev);
		$dev["name"] = $data["Name"];
		if (empty($dev["name"])) $dev["name"] = $data["Driver"];
		$dev["comments"] = $data["Port"]."\r\n".$data["Driver"];
		$dev["date_mod"] = date("Y-m-d H:i:s");
		$dev["is_global"] = "1";
		arrayClean($dev);
		$devid = getGlpiId("glpi_printers", 
			array(
				"name" => $dev["name"],
				"is_global" => $dev["is_global"]
				));
		if ($devid == "") {
			$m = new Printer;
			$m->fields = $dev;
			$devid = $m->addToDB();
		}
		$connID = periphConnect($devid, $compid, PRINTER_TYPE);
	}
	
	// inputs
	foreach (getInvLines("$mach", "Input") as $inv) {;
		$data = $inv->getProperties();
		DEBUGI($data);
		unset($dev);
		$dev["name"] = $data["StandardDescription"];
		$dev["brand"] = ""; // $data["Manufacturer"];
		$dev["comments"] = $data["Connector"]."\r\n".$data["ExpandedDescription"];
		$dev["type"] = ocsImportDropdown("glpi_type_peripherals", "name", $data["Type"]);
		$dev["date_mod"] = date("Y-m-d H:i:s");
		$dev["is_global"] = "0";
		arrayClean($dev);
		$devid = getGlpiId("glpi_peripherals", 
			array( "name" => $dev["name"] ));
		if ($devid == "") {
			$m = new Peripheral;
			$m->fields = $dev;
			$devid = $m->addToDB();
		}
		$connID = periphConnect($devid, $compid, PERIPHERAL_TYPE);
	}
}

if (isset($argv[1]) && $config["glpi_sync"]) 
    import($argv[1]);
else
    print "Error: no host given on command line or GLPI sync disabled.\n";
?>
