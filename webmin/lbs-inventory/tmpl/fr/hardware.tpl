<!-- section processeur -->
<!-- BEGIN cpu -->
<!-- BEGIN processeur -->
<DIV style="float: left; width: 47%;" class="text">
<table border=0 cellspacing="0px" cellpadding="0px" class="noborder" width=100%>
<tr>
<th> <h2 align="center">Processeur </h2> </th>
</tr>
<tr>
<td align="center" class="fond_designation">
	<table class="noborder" style="text-align: left;" class="text">
		<tr> <th> Nb processeurs </th> 		<td class="noborder">: {CPU_NUMBER} </td></tr>
		<tr> <th> Type </th>			<td class="noborder">: {CPU_TYPE_PROC} </td></tr>
		<tr> <th> Vitesse </th>			<td class="noborder">: {CPU_SPEED} </td></tr>
		<tr> <th> Vendeur </th>			<td class="noborder">:  {CPU_VENDOR} </td></tr>
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
<th><h2 align="center"> M&eacute;moire </h2></th>
</tr>
<tr>
<td align="center" class="fond_designation">
	<table class="noborder" style="text-align: left;" class="text">
		<tr> <th> Emplacements vides </th>		<td class="noborder">: {EMPTY_SLOTS} </td></tr>
		<tr> <th> Emplacements </th>			<td class="noborder">: {TOTAL_SLOTS} </td></tr>
		<tr> <th> RAM totale</th>			<td class="noborder">: {TOTAL_MEM} MB</td></tr>
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
		<tr> <th> Type RAM </th>             		 <td class="noborder">: {TYPE_RAM} </td></tr>
		<tr> <th> Capacit&eacute; en Mo</th>		 <td class="noborder">: {CAPACITY} </td></tr>
		<tr> <th> Fr&eacute;quence </th>		 <td class="noborder">: {FREQ} </td></tr>
		<tr> <th> Num&eacute;ro de slot </th>		 <td class="noborder">: {SLOT_NUMBER} </td></tr>
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
		<tr> <th> Taille du swap</th>	<td class="noborder">: {SWAP_SIZE} MB </td></tr>
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
		<tr> <th> Puce </th>				<td class="noborder">: {CG_CHIPSET} </td></tr>	
		<tr> <th> Description </th>			<td class="noborder">: {CG_DESCRIPTION} </td></tr>
		<tr> <th> M&eacute;moire </th>			<td class="noborder">: {CG_MEMORY} </td></tr>
		<tr> <th> R&eacute;solution d'&eacute;cran</th>	<td class="noborder">: {CG_RESOLUTION} </td></tr>
		<tr> <th> Vendeur </th>				<td class="noborder">: {CG_VENDOR} </td></tr>
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
<th> <h2 align="center"> Carte Son </h2> </th>
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
<th> <h2 align="center"> Classe PCI: '{PCIBUS_CLASS}' </h2> </th>
</tr>
<tr>
<td align="center" class="fond_designation">
	<table class="noborder" style="text-align: left;" class="text">
		<tr> <th> Puce </th>			<td class="noborder">: {PCIBUS_CHIPSET} </td></tr>
		<tr> <th> Vendeur </th>			<td class="noborder">: {PCIBUS_VENDOR} </td></tr>
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
	        <tr> <th> Disponibilité </th>   <td class="noborder">: {PCI_AVAILABILITY} </td></tr>
	        <tr> <th> Etat </th> <td class="noborder">: {PCI_STATE} </td></tr>
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
	<b> Aucune informations disponible sur les bus PCI, ISA, IDE, USB.
	<br>
	Installez le LRS pour ces informations
	<br><br>
	</b>
</td>
</tr>
</table>
</DIV>
<!-- END no_lbs -->

<DIV style="clear: both"></DIV>

<!-- BEGIN csv_file -->
<div><font size="-1"> Récupérer ces données au format CSV: {CSV_CAT}: {CSV_LINK} </font></div> 
<!-- END csv_file -->
