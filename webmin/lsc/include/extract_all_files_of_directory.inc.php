<?php
require_once(dirname(__FILE__)."/clean_path.inc.php");

function return_all_files_of_directory_recursive($path_source, $path_append)
{
	$return_var=array();
	
	if ($handle = opendir($path_source)) {
		while($file=readdir($handle)) {
			if (($file==".") || ($file=="..")) continue;
			if (is_dir($path_source."/".$file)) {
				$return_var=array_merge(
					$return_var, 
					return_all_files_of_directory_recursive(
						$path_source."/".$file,
						$path_append."/".$file
					)
				);
			} else {
				array_push($return_var, clean_path($path_append."/".$file));
			}
		}
		
		closedir($handle);
	}
	return($return_var);
}
?>
