<link rel='StyleSheet' href='/lrs-inventory/css/main.css' type='text/css' media='screen' />

<p>

	<div id="bios-informations">

		<div class="download-informations">
			<a href="{DONWLOAD_URL}">
				<img src="images/csv.png" title="Télécharger ces informations au format CSV" alt="Télécharger ces informations au format CSV"/>
			</a>
		</div>

		<h3>BIOS</h3>

		<table>
		
			<tr>
				<th>Client {SORT_HOST}</th>
				<th>Vendeur {SORT_BIOS0}</th>
				<th>Version {SORT_BIOS1}</th>
				<th>S&eacute;rie {SORT_BIOS2}</th>
				<th>Apparition {SORT_FIRSTAPPARITION}</th>
			</tr>
			
			<!-- BEGIN row -->
			<tr class="{ROWCLASS}">
				<td class="{HOST_CLASS}">{HOSTL}</td>
				<td class="{BIOS0_CLASS}">{BIOS0}</td>
				<td class="{BIOS1_CLASS}">{BIOS1}</td>
				<td class="{BIOS2_CLASS}">{BIOS2}</td>
				<td class="{FIRSTAPPARITION_CLASS}">{FIRSTAPPARITION}</td>
			</tr>
			<!-- END row -->
			
		</table>
	
	</div>

</p>