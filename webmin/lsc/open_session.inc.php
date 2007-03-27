<?php

$getmac = $_GET["mac"];
$isgroup = false;
if ($getmac == "") {
	$path = new LSC_Path($_GET["profile"].":".$_GET["group"]."/");
	$first_host = array_shift($path->get_hosts_list());
	$getmac = $first_host["mac"];
	$isgroup = true;
}

if ($getmac != "") {
	/*
	 * Open the session
	 */
	if ($_COOKIE["session"][$getmac]["platform"]!="") {
		$session = new LSC_Session(
			$getmac, 
			"root", 
			false, 
			$_COOKIE["session"][$getmac]["platform"],
			$_COOKIE["session"][$getmac]["homepath"]
		);
	} else {
		$session = new LSC_Session($getmac, "root", !$isgroup);
	}
	
	if ($session->errors == 0) {
		setcookie("session[".$getmac."][platform]", $session->platform, time()+60*60);
		setcookie("session[".$getmac."][homepath]", $session->home, time()+60*60);
	} else {
		if (!$isgroup) {
			include(dirname(__FILE__)."/connection_error.cgi");
			exit();
		}
	}
}
?>
