<?php
require_once(dirname(__FILE__)."/../extract_all_files_of_directory.inc.php");

print_r(
	return_all_files_of_directory_recursive("/home/lsc/repository/", "/")
);
?>
