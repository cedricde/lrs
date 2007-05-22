#!/var/lib/lrs/php
<?php
#
# $Id$
#
# Linbox Rescue Server
# Copyright (C) 2005  Linbox FAS
#

	include_once('commons.php');
	include_once('classes/Components/Custom.php');
	include_once('filters.php');

	print perl_exec("./lbs_header.cgi", array("lrs-inventory custom", $text{'title_custom'}, "custom")); 

	$machine = & $machines[0];

	$driver = $datasource->getDefaultSourceDriver();
	$types = $driver->getFields('Custom'); 
	# SQL types for new fields
	$newtypes = array(
			array("t"=>"int", "en"=>"Integer", "fr"=>"Entier"),
			array("t"=>"float", "en"=>"Float", "fr"=>"Flottant"),
			array("t"=>"double", "en"=>"Float double precision", "fr"=>"Flottant double pr&eacute;cision"),
			array("t"=>"varchar(32)", "en"=>"String (32)", "fr"=>"Cha&icirc;ne (32)"),
			array("t"=>"varchar(255)", "en"=>"String (255)", "fr"=>"Cha&icirc;ne (255)"),
			array("t"=>"date", "en"=>"Date", "fr"=>"Date"),
			  
			);

	//$datasource->readCustomFields($machine);

	// If an action has been chosen
	if ( array_key_exists('ac',$_GET) )
	{
		switch ($_GET['ac'])
		{
			// A field has to be delete
			case 'delete':
				$driver->delCustomField( $_GET['field'] );
				break;

			// A new field has to be registered
			case 'add':

				if ( empty($_GET['field']) )
					errorFieldEmpty('Field name');

				if ( empty($_GET['value']) )
					errorFieldEmpty('Field value');

				if ( ! errorOccured() ) {
					// Fill the custom field
					$driver->addCustomField($_GET['field'], $_GET['value']);
				}

				break;

			case 'update':

				$customfields = & $machine->getCustomFields();
				$data = & $datasource->read("Custom", $machine);
				$cust = & $data[0];
				// Check if default fields have been filled
				if (!$cust) {
					$cust = new Custom();
					$cust->setHost($machine);
				}
				$props = $cust->getProperties();
				foreach ($props as $key=>$value) {
					// In this case, save it in the database
					$get = $_GET["N_".$key];
					//if ($get == "") $get = "null";
					$cust->setProperty($key , FilterToSQL($get, 
								$types[$key]['Type']));
				}
				$datasource->write($data);

		}

		// Save all custom field modifications
		//$datasource->saveCustomFields($machine);
	}

	$template = tmplInit(array('template' => 'Custom.tpl'));
	$template->set_block('template', 'row', 'rows');
	$template->set_block('row', 'candelete', 'delme');
	
	$empty = new Custom();		// empty object to find default	fields
	$i=0;

	$template->set_var('MACHINE_NAME', $machine->getName());
	$template->set_var('MACHINE', $_GET['mac']);
	
	//$customfields = $machine->getCustomFields();

	$data = & $datasource->read("Custom", $machine);
	$cust = $data[0];
	
	// Display all fields
	if (!$cust) $cust = $empty;
	$props = $cust->getProperties();
	foreach ( $props as $key => $value )
	{
		$deleteurl = 'custom.cgi?ac=delete&mac='. $_GET['mac'] .'&field='. $key;
		
		$size = $types[$key]['Length'];
		if ($size < 16) $size = 16;
		if ($size > 64) $size = 64;
		
		$template->set_var('FIELD', ucfirst($cust->getDesc($key)));
		$template->set_var('FIELDN', "N_".$key);
		$template->set_var('VALUE', FilterFromSQL($value, $types[$key]['Type']));
		$template->set_var('SIZE', $size);
		
		$parity = $i%2==0 ? 'pair' : 'impair';
		$template->set_var('ROWCLASS', $parity);
		$template->set_var('delme', '');

		// can delete non standard fields only
		if (!array_key_exists( $key, $empty->m_Properties)) {
			$template->set_var('DELETE_URL', $deleteurl);
			$template->parse('delme', 'candelete');
		}
		$template->parse('rows', 'row', true);
		
		$i++;
	}

	$select = "";
	foreach ( $newtypes as $arr ) {
		$select .= "<option value='".$arr['t']."'>".$arr[$lang]."</option>";
	}
	$template->set_var('SELECT', $select);

	// Display the template
	$template->pparse("out", "template", "template");

	print perl_exec("lbs_footer.cgi");

?>
