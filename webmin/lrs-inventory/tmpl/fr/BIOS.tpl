<link rel='StyleSheet' href='/lrs-inventory/css/main.css' type='text/css' media='screen' />

<p>

	<div id="bios-informations">

		<div class="download-informations">
			<a href="{DONWLOAD_URL}">
				<img src="images/csv.png" title="Télécharger ces informations au format CSV" alt="Télécharger ces informations au format CSV"/>
			</a>
		</div>

		<h3>BIOS (OCS)</h3>

		<table>
		
			<tr>
				<th>Client {SORT_HOST}</th>
				<th>Vendeur {SORT_BIOSVENDOR}</th>
				<th>Version {SORT_BIOSVERSION}</th>
				<th>S&eacute;rie {SORT_CHIPSERIAL}</th>
				<th>Apparition {SORT_FIRSTAPPARITION}</th>
			</tr>
			
			<!-- BEGIN row -->
			
			<tr class="{ROWCLASS}">
				<td class="{HOST_CLASS}">{HOSTL}</td>
				<td class="{BIOSVENDOR_CLASS}">{BIOSVENDOR}</td>
				<td class="{BIOSVERSION_CLASS}">{BIOSVERSION}</td>
				<td class="{CHIPSERIAL_CLASS}">{CHIPSERIAL}</td>
				<td class="{FIRSTAPPARITION_CLASS}">{FIRSTAPPARITION}</td>
			</tr>
			
			<!-- END row -->
			
		</table>
	
	</div>

</p>