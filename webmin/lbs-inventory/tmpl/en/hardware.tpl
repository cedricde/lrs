<!-- section processeur -->
<!-- BEGIN cpu -->
<!-- BEGIN processeur -->
<DIV style="float: left; width: 47%;" class="text">
<table border=0 cellspacing="0px" cellpadding="0px" class="noborder" width=100%>
<tr>
<th> <h2 align="center">Processor </h2> </th>
</tr>
<tr>
<td align="center" class="fond_designation">
	<table class="noborder" style="text-align: left;" class="text">
		<tr> <th> Nb of Processors </th> 		<td class="noborder">: {CPU_NUMBER} </td></tr>
		<tr> <th> Type </th>			<td class="noborder">: {CPU_TYPE_PROC} </td></tr>
		<tr> <th> Speed </th>			<td class="noborder">: {CPU_SPEED} </td></tr>
		<tr> <th> Vendor </th>			<td class="noborder">:  {CPU_VENDOR} </td></tr>
	</table>
</td>
</tr>
</table>
</DIV>
<!-- END processeur -->
<!-- END cpu -->
<!-- fin section processeur -->


<!-- section RAM -->
<!-- BEGIN memory -->
<DIV style="float: left; width: 47%" class="text">
<table border=0 cellspacing="0px" cellpadding="0px" class="noborder" width=100%>
<tr>
<th><h2 align="center"> Memory </h2></th>
</tr>
<tr>
<td align="center" class="fond_designation">
	<table class="noborder" style="text-align: left;" class="text">
		<tr> <th> Empty Slots </th>		<td class="noborder">: {EMPTY_SLOTS} </td></tr>
		<tr> <th> Total Slots</th>		<td class="noborder">: {TOTAL_SLOTS} </td></tr>
		<tr> <th> Total RAM</th>		<td class="noborder">: {TOTAL_MEM} MB</td></tr>
	</table>
</td>
</tr>
</table>
</DIV>
<!-- END memory -->

<DIV style="clear: both"></DIV>

<!-- BEGIN slots -->
<DIV style="float: left; width: 47%;" class="text">
<table border=0 cellspacing="0px" cellpadding="0px" class="noborder" width=100%>
<tr class="fond_designation">
<th> <h2 align="center"> RAM: {TYPE_RAM} </h2> </th>
</tr>
<tr>
<td  align="center" class="fond_designation">
	<table class="noborder" style="text-align: left;" class="text">
		<tr> <th> Capacity</th>				 <td class="noborder">: {CAPACITY} MB</td></tr>
		<tr> <th> Frequence </th>	 <td class="noborder">: {FREQ} </td></tr>
		<tr> <th> Number of Slot </th>	 <td class="noborder">: {SLOT_NUMBER} </td></tr>
		<tr> <th> Total RAM </th>                        <td class="noborder">: {TOTAL_RAM} </td></tr>
	</table>
</td>
</tr>
</table>
</DIV>
<!-- END slots -->



<!-- BEGIN swap -->
<DIV style="float: left; width: 47%" class="text">
<table border=0 cellspacing="0px" cellpadding="0px" class="noborder" width=100%>
<tr class="fond_designation">
<th> <h2 align="center"> SWAP </h2> </th>
</tr>
<tr>
<td align="center" class="fond_designation">
	<table class="noborder" style="text-align: left;" class="text">
		<tr> <th> Swap Size</th>	<td class="noborder">: {SWAP_SIZE} MB </td></tr>
	</table>
</td>
</tr>
</table>
</DIV>
<!-- END swap -->
<!-- fin section RAM -->



<!-- section Carte Graphique -->
<!-- BEGIN vga -->
<DIV style="float: left; width: 47%" class="text">
<table border=0 cellspacing="0px" cellpadding="0px" class="noborder" width=100%>
<tr class="fond_designation">
<th> <h2 align="center"> VGA </h2> </th>
</tr>
<tr>
<td align="center" class="fond_designation">
	<table class="noborder" style="text-align: left;" class="text"> 
		<tr> <th> Chipset </th>		<td class="noborder">: {CG_CHIPSET} </td></tr>	
		<tr> <th> Description </th>	<td class="noborder">: {CG_DESCRIPTION} </td></tr>
		<tr> <th> Memory </th>		<td class="noborder">: {CG_MEMORY} </td></tr>
		<tr> <th> Resolution</th>	<td class="noborder">: {CG_RESOLUTION} </td></tr>
		<tr> <th> Vendor </th>		<td class="noborder">: {CG_VENDOR} </td></tr>
	</table>
</td>
</tr>
</table>
</DIV>
<!-- fin section Carte Graphique -->
<!-- END vga -->

<!-- BEGIN sound -->
<DIV style="float: right; width: 47%" class="text">
<table border=0 cellspacing="0px" cellpadding="0px" class="noborder" width=100%>
<tr class="fond_designation">
<th> <h2 align="center"> Sound Card </h2> </th>
</tr>
<tr>
<td align="center" class="fond_designation">
        <table class="noborder" style="text-align: left;" class="text"> 
                <tr> <th> Vendeur </th>                         <td class="noborder">: {CG_VENDOR} </td></tr>
        </table>
</td>
</tr>
</table>
</DIV>
<!-- END sound -->

<DIV style="clear: both"></DIV>

<!-- BEGIN pcibus -->
<DIV style="float: left; width: 47%" class="text">
<table border=0 cellspacing="0px" cellpadding="0px" class="noborder" width=100%>
<tr class="fond_designation">
<th> <h2 align="center"> PCI Class: {PCIBUS_CLASS} </h2> </th>
</tr>
<tr>
<td align="center" class="fond_designation">
	<table class="noborder" style="text-align: left;" class="text">
		<tr> <th> Chipset </th>			<td class="noborder">: {PCIBUS_CHIPSET} </td></tr>
		<tr> <th> Vendor </th>			<td class="noborder">: {PCIBUS_VENDOR} </td></tr>
	</table>
</td>
</tr>
</table>
</DIV>
<!-- END pcibus -->

<DIV style="clear: both">&nbsp;</DIV>

<!-- BEGIN pci -->
<DIV style="float: left; width: 47%" class="text">
<table border=0 cellspacing="0px" cellpadding="0px" class="noborder" width=100%>
<tr class="fond_designation">
<th> <h2 align="center"> {PCI_TYPE}</h2> </th>
</tr>
<tr>
<td align="center" class="fond_designation">
	<table class="noborder" style="text-align: left;" class="text">
	        <tr> <th> Disponibility </th>   <td class="noborder">: {PCI_AVAILABILITY} </td></tr>
	        <tr> <th> State </th> <td class="noborder">: {PCI_STATE} </td></tr>
	</table>
</td>
</tr>
</table>
</DIV>
<!-- END pci -->

<!-- END lbs -->
<!-- BEGIN vide -->
<!-- END vide -->

<!-- BEGIN no_lbs -->
<DIV style="float: left;" class="text">
<table border=0 cellspacing="0px" cellpadding="0px" class="noborder" width=100%>
<tr class="fond_normal" align="center">
<td width="100%" align="center" class="noborder">
	<br>
	<b> No information about  PCI, ISA, IDE, USB buses is avilable.
	<br>
	 To obtain this information install the LRS.
	<br><br>
	</b>
</td>
</tr>
</table>
</DIV>
<!-- END no_lbs -->

<DIV style="clear: both"></DIV>

<!-- BEGIN csv_file -->
<div><font size="-1">  Download this data, CSV format: {CSV_CAT}: {CSV_LINK} </font></div> 
<!-- END csv_file -->
