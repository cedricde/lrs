<!-- BEGIN pc -->
<div style="text-align: center;" class="noborder">
        <h1 align="center">{PC_NAME}</h1>
        <h2 align="center">{PC_DESCRIPTION}</h2> 
</div>
<!-- END pc -->

<div class="leftcolumn">

<!-- BEGIN manufacturer -->
<DIV style="width: 99%;" class="text">
<table border="0" cellspacing="1px" cellpadding="0px" class="noborder" width=100%>
<th align="center" class="noborder"> <h2>General informations</h2> </th>
<tr class="noborder">
<td align="center" class="fond_designation">
        <table class="noborder" style="text-align: left;">
                <tr><th class="noborder">Name</th>                      <td class="noborder">: {MANUFACTURER_NAME} </td></tr>
                <tr><th class="noborder">Model</th>                     <td class="noborder">: {MANUFACTURER_MODEL}</td></tr>
                <tr><th class="noborder">Serial number</th>   		  <td class="noborder">: {MANUFACTURER_SERIAL_NUMBER} </td></tr>
                <tr><th class="noborder">Type of the Machine</th>       <td class="noborder">: {MANUFACTURER_TYPE} </td></tr>
                <tr><th class="noborder">UUID</th>			<td class="noborder">: {MANUFACTURER_UUID} </td></tr>
        </table>
</td>
</tr>
</table>
</DIV>
<!-- END manufacturer -->

<!-- BEGIN os -->
<DIV style="width: 99%" class="text">
<table border="0" cellspacing="1px" cellpadding="0px" class="noborder" width=100%> 
<th aligne="center" class="noborder"><h2>Operating System</h2> </th>
<tr class="noborder">
<td align="center" class="fond_designation">
        <table class="noborder" style="text-align: left;">
                <tr><th class="noborder">Operating system </th>     <td class="noborder">: {OS_NAME}</td></tr>
                <tr><th class="noborder">OS Version </th>           <td class="noborder">: {OS_VERSION}</td></tr>
                <tr><th class="noborder">Comments</th>                  <td class="noborder">: {OS_COMMENTS}</td></tr>
        </table>
</td>
</tr>
</table>
</DIV>
<!-- END os -->

<!-- BEGIN bios -->
<DIV style="width: 99%" class="text">
<table border="0" cellspacing="1px" cellpadding="0px" class="noborder" width=100%> 
<th aligne="center" class="noborder"><h2>BIOS</h2></th>
<tr class="noborder">
<td align="center" class="fond_designation">
        <table class="noborder" style="text-align: left;">
                <tr><th class="noborder">Manufacturer</th>	<td class="noborder">: {BIOS_MANUFACTURER}</td></tr>
                <tr><th class="noborder">Version</th>		<td class="noborder">: {BIOS_VERSION}</td></tr>
                <tr><th class="noborder">Date</th>		<td class="noborder">: {BIOS_DATE}</td></tr>
        </table>
</td>
</tr>
</table>
</DIV>
<!-- END bios -->

</div>


<div class="rightcolumn">

<DIV style="width: 99%" class="text">
<!-- BEGIN garantie -->
<table border="0" cellspacing="1px" cellpadding="0px" class="noborder" width=100%>
 <th class="noborder"><h2 align="center"><a href="formulaire_garantie.cgi{GARANTIE_OPTIONS}" target="_self">Guarantee </a></h2></th>
 <tr>
<td align="center" class="fond_designation">
        <table class="noborder" style="text-align: left;">
                <tr><th class="noborder">Purchase date</th>           <td class="noborder">: {GARANTIE_DATE_ACHAT}</td></tr>
                <tr><th class="noborder">Manuf. guarantee</th>  <td class="noborder">: {GARANTIE_CONSTRUCTEUR}</td></tr>
                <tr><th class="noborder">Guarantee duration</th>     <td class="noborder">: {GARANTIE_DUREE}</td></tr>
                <tr><th class="noborder">Comments</th>                  <td class="noborder">: {GARANTIE_COMMENTAIRES}</td></tr>
        </table>
</td>
</tr>
</table>
</DIV>
<!-- END garantie -->

<!-- BEGIN geo -->
<DIV style="width: 99%" class="text">
<table border="0" cellspacing="1px" cellpadding="0px" class="noborder" width=100%>
<th> <h2 align="center"><a href="site_geo.cgi{GEO_OPTIONS}" target="_self">Geographical location</a></h2></th>
 <tr>
<td align="center" class="fond_designation">
        <table class="noborder" style="text-align: left;">
                <tr><th class="noborder">Location</th>                     <td class="noborder">: {SITUATION_GEOGRAPHIQUE}</td></tr>
                <tr><th class="noborder">Nearest phone</th>             <td class="noborder">: {NUMERO_TEL_PROCHE}</td></tr>
        </table>
</td>
</tr>
</table>
</DIV>
<!-- END geo -->
</div>



<!-- BEGIN csv_file -->
<DIV style="clear: both" class="text">
<br />
        <div><small>Download this data, CSV format: {CSV_LINK} </small></div>
	<p>
        <div><small>These informations were updated on :
                <ul>
                        <li>{LAST_DATE_OCS} by the Inventory module</li>
                        <li>{LAST_DATE_LRS} by the System module </li>
                </ul>
	</small>
	</div>
</DIV>
<!-- END csv_file -->
