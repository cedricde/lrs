#!/var/lib/lrs/php
<?php
//
// $Id$
//
// Hardware information
//

include_once('commons.php');
include_once('filters.php');

print perl_exec("./lbs_header.cgi", array("lrs-inventory hardware", $text{'title_hard'}, "hardware"));

if ($config['genfromocs'] == "1") {
	renderTable('Hardware', null);
} else {
	renderTable('BootGeneral', 'BootCPU.tpl');
}
unset($data);
renderTable('BootMem', 'BootMem.tpl', array('Used'=>'YesNo', 'Capacity'=>'KiloByte'));
renderTable('Hardware', 'Memory.tpl', array('RamTotal'=>'MegaByte' , 'SwapSpace'=>'MegaByte') );
renderTable('BootGeneral', 'BootMemory.tpl');
renderTable('BootGeneral','BootBIOS.tpl', array(), '', "FilterSplitPipe");

renderTable('Sound', 'Sound.tpl');
// for video card information get also PCI information
//$datapci = & $datasource->read('BootPCI', $machines);
renderTable('VideoCard', '', array('VRAMSize'=>'MegaByte'), '', "FilterPCIVC" );

renderTable('BootPCI', 'BootPCI.tpl');

print perl_exec("lbs_footer.cgi");

?>
