<link rel='StyleSheet' href='/lrs-inventory/css/main.css' type='text/css' media='screen' />

<p>

	<div id="bios-informations">

		<div class="download-informations">
			<a href="{DONWLOAD_URL}">
				<img src="images/csv.png" title="Download these informations in CSV format" alt="Download these informations in CSV format"/>
			</a>
		</div>

		<h3>BIOS (OCS)</h3>

		<table>
		
			<tr>
				<th>Client {SORT_HOST}</th>
				<th>Vendor {SORT_BIOSVENDOR}</th>
				<th>Version {SORT_BIOSVERSION}</th>
				<th>Serial {SORT_CHIPSERIAL}</th>
				<th>Appearance {SORT_FIRSTAPPARITION}</th>
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