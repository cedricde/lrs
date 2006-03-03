<?php

$INCLUDE_PATH = dirname(__FILE__)."/";
$DATASOURCECONFIGURATION = $INCLUDE_PATH .'DataSources.xml';
$DEBUG = false;

if ($DEBUG)
{
	function debug($debugcomment)
	{
		if ( is_array($debugcomment) || is_object($debugcomment) )
		{
			print '<pre>';
			print_r($debugcomment);
			print '</pre>';
		}
		else
			print '<li>'. $debugcomment .'</li>';
	}
}
else
{
	function debug($debugcomment)
	{
	}
}
 
?>
