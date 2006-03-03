#!/var/lib/lrs/php
<?php

//
include_once('commons.php');

print perl_exec("./lbs_header.cgi", array("lrs-inventory disk", $text{'title_disk'}, "disk"));

renderTable('Drive', null, array('TotalSpace'=>'MegaByte' , 'FreeSpace'=>'MegaByte' , 'FileCount'=>'Number') );
renderTable('BootDisk');
renderTable('BootPart', null, array('Type'=>'formatPart'));
	
print perl_exec("lbs_footer.cgi");

?>
