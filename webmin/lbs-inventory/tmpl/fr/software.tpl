<table width="100%" border=0 cellspacing="0px" cellpadding="0px" class="noborder">

<tr class="noborder" height="15px" style="background-color: #fce6e0"> <!-- Ligne des désignations -->
	<!-- BEGIN options -->
	<th> Nom de Fichier</h2> </th>
	<th> Version du Fichier </h2></th>
	<th> Application </h2></th>
	<th> Vendeur </h2></th>
	<th> Taille </h2></th>
	<th> Chemin d'Accès</h2> </th>
	<!-- END options -->
</tr>

<!-- BEGIN software -->
<tr class="noborder" align="center" style="background-color: {SOFTWARE_BGCOLOR}"> <!-- une ligne par software -->
	<td class="noborder"> {FILE_NAME} </td>
	<td class="noborder"> {FILE_VERSION} </td>
	<td class="noborder"> {APPLICATION} </td>
	<td class="noborder"> {VENDOR} </td>
	<td class="noborder"> {SIZE} </td>
	<td class="noborder"> {PATH} </td>
</tr>
<!-- END software -->
</table>

<br>
<br>

<!-- BEGIN vide -->
<!-- END vide -->
<!-- BEGIN summary -->

<table width="100%" border=0 class="noborder">

<tr>
<!--         <th class="noborder" rowspan=2> Total </th > -->
       <td class="noborder"><h4> Nombre d'Ex&eacute;cutables: {NUMBER_APPLICATION} </h4></td>
       <td class="noborder"><h4> Espace disque utilis&eacute; par les ex&eacute;cutables:  {DISK_SPACE_USED} </h4></td>
</tr>
<!-- END summary -->
</table>
<br>
<br>
<!-- BEGIN csv_file -->
<div><font size="-1"> Récupérer ces données au format CSV: {CSV_CAT}: {CSV_LINK} </font></div> 
<!-- END csv_file -->
