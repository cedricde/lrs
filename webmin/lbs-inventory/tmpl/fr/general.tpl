<!-- BEGIN pc -->
<div style="text-align: center;" class="noborder">
        <h1 align="center">Machine {PC_NAME}</h1>
        <h2 align="center">{PC_DESCRIPTION}</h2> 
</div>
<!-- END pc -->

<div class="leftcolumn">

<!-- BEGIN manufacturer -->
<DIV style="width: 99%;" class="text">
<table border="0" cellspacing="1px" cellpadding="0px" class="noborder" width=100%>
<th align="center" class="noborder"> <h2>Informations générales</h2> </th>
<tr class="noborder">
<td align="center" class="fond_designation">
        <table class="noborder" style="text-align: left;">
                <tr><th class="noborder">Fabriquant</th>                        <td class="noborder">: {MANUFACTURER_NAME} </td></tr>
                <tr><th class="noborder">Mod&egrave;le</th>                     <td class="noborder">: {MANUFACTURER_MODEL}</td></tr>
                <tr><th class="noborder">Num&eacute;ro de s&eacute;rie</th>     <td class="noborder">: {MANUFACTURER_SERIAL_NUMBER} </td></tr>
                <tr><th class="noborder">Type de Machine</th>                   <td class="noborder">: {MANUFACTURER_TYPE} </td></tr>
                <tr><th class="noborder">UUID</th>				<td class="noborder">: {MANUFACTURER_UUID} </td></tr>
        </table>
</td>
</tr>
</table>
</DIV>
<!-- END manufacturer -->

<!-- BEGIN os -->
<DIV style="width: 99%" class="text">
<table border="0" cellspacing="1px" cellpadding="0px" class="noborder" width=100%> 
<th aligne="center" class="noborder"><h2>Système d'exploitation</h2>
<tr class="noborder">
<td align="center" class="fond_designation">
        <table class="noborder" style="text-align: left;">
                <tr><th class="noborder">Nom</th>               <td class="noborder">: {OS_NAME}</td></tr>
                <tr><th class="noborder">Version du SE</th>     <td class="noborder">: {OS_VERSION}</td></tr>
                <tr><th class="noborder">Commentaires</th>      <td class="noborder">: {OS_COMMENTS}</td></tr>
        </table>
</td>
</tr>
</table>
</DIV>
<!-- END os -->

<!-- BEGIN bios -->
<DIV style="width: 99%" class="text">
<table border="0" cellspacing="1px" cellpadding="0px" class="noborder" width=100%> 
<th aligne="center" class="noborder"><h2>BIOS</h2>
<tr class="noborder">
<td align="center" class="fond_designation">
        <table class="noborder" style="text-align: left;">
                <tr><th class="noborder">Fabriquant</th>	<td class="noborder">: {BIOS_MANUFACTURER}</td></tr>
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
<!-- BEGIN garantie -->
<DIV style="width: 99%" class="text">
<table border="0" cellspacing="1px" cellpadding="0px" class="noborder" width=100%>
 <th class="noborder"><h2 align="center"><a href="formulaire_garantie.cgi{GARANTIE_OPTIONS}" target="_self">Garantie </a></h2></th>
 <tr>
<td align="center" class="fond_designation">
        <table class="noborder" style="text-align: left;">
                <tr><th class="noborder">Date d'achat</th>              <td class="noborder">: {GARANTIE_DATE_ACHAT}</td></tr>
                <tr><th class="noborder">Garantie fabriquant</th>       <td class="noborder">: {GARANTIE_CONSTRUCTEUR}</td></tr>
                <tr><th class="noborder">Garantie revendeur</th>        <td class="noborder">: {GARANTIE_DUREE}</td></tr>
                <tr><th class="noborder">Commentaire</th>               <td class="noborder">: {GARANTIE_COMMENTAIRES}</td></tr>
        </table>
</td>
</tr>
</table>
</DIV>
<!-- END garantie -->

<!-- BEGIN geo -->
<DIV style="width: 99%" class="text">
<table border="0" cellspacing="1px" cellpadding="0px" class="noborder" width=100%>
<th> <h2 align="center"><a href="site_geo.cgi{GEO_OPTIONS}" target="_self">Situation g&eacute;ographique </a></h2></th>
 <tr>
<td align="center" class="fond_designation">
        <table class="noborder" style="text-align: left;">
                <tr><th class="noborder">Lieu</th>                                      <td class="noborder">: {SITUATION_GEOGRAPHIQUE}</td></tr>
                <tr><th class="noborder">T&eacute;l&eacute;phone le plus proche</th>    <td class="noborder">: {NUMERO_TEL_PROCHE}</td></tr>
        </table>
</td>
</tr>
</table>
</DIV>
<!-- END geo -->
</div>

<!-- BEGIN csv_file -->
<DIV style="clear: both" class="text">
<br /><br />
        <div><small> Récupérer ces données au format CSV: {CSV_LINK} </small></div>
	<p>
        <div><small>Ces informations ont été mises à jour :
                <ul>
                        <li>le {LAST_DATE_OCS} par le module Inventaire</li>
                        <li>le {LAST_DATE_LRS} par le module Système</li>
                </ul>
        </small></div>
</DIV>
<!-- END csv_file -->
