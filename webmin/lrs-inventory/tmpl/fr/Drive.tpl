<link rel='StyleSheet' href='/lrs-inventory/css/main.css' type='text/css' media='screen' />

<p>

	<div id="drive-informations">

		<div class="download-informations">
			<a href="{DONWLOAD_URL}">
				<img src="images/csv.png" title="Télécharger ces informations au format CSV" alt="Télécharger ces informations au format CSV"/>
			</a>
		</div>

		<h3>Lecteurs et disques logiques Windows</h3>
		
		<table>
		
			<tr>
				<th>Client {SORT_HOST}</th>
				<th>Lettre {SORT_DRIVELETTER}</th>
				<th>Type {SORT_DRIVETYPE}</th>
				<th>Nom {SORT_VOLUMENAME}</th>
				<th>Système de fichier {SORT_FILESYSTEM}</th>
				<th>Taille {SORT_TOTALSPACE}</th>
				<th>Espace libre {SORT_FREESPACE}</th>
				<th>Nombre de fichiers {SORT_FILECOUNT}</th>
				<th>Apparition {SORT_FIRSTAPPARITION}</th>
			</tr>
			
			<!-- BEGIN row -->
			
			<tr class="{ROWCLASS}">
				<td class="{HOST_CLASS}">{HOSTL}</td>
				<td class="{DRIVELETTER_CLASS}">{DRIVELETTER}</td>
				<td class="{DRIVETYPE_CLASS}">{DRIVETYPE}</td>
				<td class="{VOLUMENAME_CLASS}">{VOLUMENAME}</td>
				<td class="{FILESYSTEM_CLASS}">{FILESYSTEM}</td>
				<td class="{TOTALSPACE_CLASS}">{TOTALSPACE}</td>
				<td class="{FREESPACE_CLASS}">{FREESPACE}</td>
				<td class="{FILECOUNT_CLASS}">{FILECOUNT}</td>
				<td class="{FIRSTAPPARITION_CLASS}">{FIRSTAPPARITION}</td>
			</tr>
			
			<!-- END row -->
			
		</table>
	
	</div>

</p>