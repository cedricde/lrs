<link rel='StyleSheet' href='/lrs-inventory/css/main.css' type='text/css' media='screen' />

<h2>Périphériques</h2>

<p>

	<div id="printer-informations">

		<div class="download-informations">
			<a href="{DONWLOAD_URL}">
				<img src="images/csv.png" title="Télécharger ces informations au format CSV" alt="Télécharger ces informations au format CSV"/>
			</a>
		</div>

		<h3>Imprimantes</h3>
		
		<table>
		
			<tr>
				<th>Client {SORT_HOST}</th>
				<th>Nom {SORT_NAME}</th>
				<th>Pilote {SORT_DRIVER}</th>
				<th>Port {SORT_PORT}</th>
				<th>Apparition {SORT_FIRSTAPPARITION}</th>
			</tr>
			
			<!-- BEGIN row -->
			
			<tr class="{ROWCLASS}">
				<td class="{HOST_CLASS}">{HOSTL}</td>
				<td class="{NAME_CLASS}">{NAME}</td>
				<td class="{DRIVER_CLASS}">{DRIVER}</td>
				<td class="{PORT_CLASS}">{PORT}</td>
				<td class="{FIRSTAPPARITION_CLASS}">{FIRSTAPPARITION}</td>
			</tr>
			
			<!-- END row -->
			
		</table>
	
	</div>

</p>