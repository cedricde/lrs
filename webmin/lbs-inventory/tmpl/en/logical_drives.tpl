<!-- BEGIN drives -->
<DIV style="float: left; width: 30%" class="text">

<table border="0" cellspacing="1px" cellpadding="0px" class="noborder" width=100%>
<th rowspan={DRIVES_ROWSPAN} align="center" class="noborder"><h2> {TYPE_DRIVE} {MOUNT_POINT}</h2> </th> 
<!-- BEGIN device -->
	<tr class="noborder" > 
	<td align="top left" class="fond_designation" border="0">   
	<table  class="noborder" style="text-align: left;"> 
		<tr> <th class="noborder">  Type </th>				<td class="noborder">: {DRIVE_TYPE} </td> </tr>
		<tr> <th class="noborder">  Filesystem </th>			<td class="noborder">: {FILE_SYSTEM} </td> </tr>
		<tr> <th class="noborder">  Total Space (MB)  </th>	<td class="noborder">: {TOTAL_SPACE} </td> </tr>
		<tr> <th class="noborder">  Free Space (MB) </th>	<td class="noborder">: {FREE_SPACE} </td> </tr>
		<tr> <th class="noborder">  % Free </th>		<td class="noborder">: {PERCENT_FREE} </td> </tr>
		<tr> <th class="noborder">  Number of Files   </th>	<td class="noborder">: {FILE_NUMBER} </td> </tr>
		<tr> <th class="noborder">  Volume Name </th>		<td class="noborder">: {VOLUME_NAME} </td> </tr>
		<tr> <th class="noborder">  Manufacturer </th>		<td class="noborder">: {MANUFACTURER} </td> </tr>
		<tr> <th class="noborder">  Reference	</th>		<td class="noborder">: {REFERENCE} </td> </tr>
	</table>		      
	</td> 
</tr></table>
</DIV>
<!-- END device -->
<!-- END drives -->
<DIV style="float: left; width=30%" class="text">
	<!-- BEGIN hd_total -->
<table border="0" cellspacing="1px" cellpadding="0px" class="noborder">
	<th align="center"> <h2> HDD Total </h2> </th>
	 <tr class="fond_recapitulatif"> 
	 <td align="left" class="fond_designation">  
	 <table class="noborder"style="text-align: left;">
	<!-- total espace disque disponible -->
		<tr> <th class="noborder"> Total Space (MB)</th>	<td class="noborder">: {TOTAL_SPACE} </td> </tr>
		<tr> <th class="noborder"> Free Space (MB)</th>		<td class="noborder">: {FREE_SPACE} </td> </tr>
		<tr> <th class="noborder"> % Free </th>			<td class="noborder">: {PERCENT_SPACE} </td> </tr>
		<tr> <th class="noborder"> Number of files </th>	<td class="noborder">: {NUMBER_FILES} </td> </tr>
	</tr>
	<!-- END hd_total -->
	</table>
</td> 
</table>
</DIV>
<DIV style="clear: both"></DIV>
<!-- BEGIN disk -->
<DIV style="float: left; width: 47%" class="text">  
<table border="0" cellspacing="1px" cellpadding="3px" align="top left" class="noborder" width=100%>
	<tr>
	<th class="noborder" align="center" > <h2> DISK {DISK_NUMBER} </h2></th>
	</tr>
	<tr>
	<td class="fond_designation">
	<table border="0" cellspacing="4px" cellpadding="0px" align="top" class="noborder">  
		<tr class="noborder" align="left">
			<th> Name </th>			<td class="noborder" align="left" width=22%>: {NAME} &nbsp; </td>
			<th> Cylinders </th>		<td class="noborder" align="left" width=32%>: {CYL} &nbsp;</td>
			<th> Heads</th>			<td class="noborder" align="left" width=42%>: {HEAD}</td>
		</tr>

		<!-- BEGIN partition -->
		<!-- BEGIN designation -->
		<tr class="fond_designation" align="left">
			<th> Sectors </th>             <td class="noborder">: {SECTOR} &nbsp;</td>
			<th> Capacity </th>		<td class="noborder">: {CAPACITY} MB </td>
		</tr>
		<tr><td colspan=6 class=noborder style="height: 1px; background-color:#f8c9bc"></td> </tr>
		<!-- END designation -->
		<tr class="fond_designation" align="left">
			<th> Partition </th> 		<td class="noborder">: {NUMBER}</td>
			<th > Type </th>		<td class="noborder">: {TYPE} &nbsp;</td>
			<th > Size</th>			<td class="noborder">: {LENGTH} MB</td>

		</tr>
		<!-- END partition -->

	</table>
	</td>
	</tr>
</table>
</DIV>
<!-- END disk -->

<!-- BEGIN vide -->
<!-- END vide -->

<!-- BEGIN no_lbs -->
<DIV style="float: left;" class="text">
<table border=0 width="100%" cellspacing="1px" cellpadding="0px" class="noborder">
	<tr class="fond_normal" align="center">
	<td width="100%" align="center" class="noborder">
		<b>  No information about the partitions of hard disks is available. <br>
		To obtain this informations <a href="{DOC_LINK}">install the LRS</a>
		</b>
	</td>
	</tr>
</table> 
</DIV>
<DIV style="clear: both;">&nbsp;
<!-- END no_lbs -->
<!-- BEGIN csv_file -->
<DIV style="clear: both;">&nbsp;
<br><br>
<div><font size="-1">  Download this data, CSV format: {CSV_LINK} </font></div>
</DIV>
<!-- END csv_file -->

