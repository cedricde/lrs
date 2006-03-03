<link rel='StyleSheet' href='/lrs-inventory/css/main.css' type='text/css' media='screen' />

<h2>Peripherals</h2>

<p>

	<div id="printer-informations">

		<div class="download-informations">
			<a href="{DONWLOAD_URL}">
				<img src="images/csv.png" title="Download these informations in CSV format" alt="Download these informations in CSV format"/>
			</a>
		</div>

		<h3>Printers</h3>
		
		<table>
		
			<tr>
				<th>Client {SORT_HOST}</th>
				<th>Name {SORT_NAME}</th>
				<th>Driver {SORT_DRIVER}</th>
				<th>Port {SORT_PORT}</th>
				<th>Appearance {SORT_FIRSTAPPARITION}</th>
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