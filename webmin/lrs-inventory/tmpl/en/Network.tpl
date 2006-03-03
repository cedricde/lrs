<link rel='StyleSheet' href='/lrs-inventory/css/main.css' type='text/css' media='screen' />

<h2>Network informations</h2>

<p>

	<div id="network-informations">

		<div class="download-informations">
			<a href="{DONWLOAD_URL}">
				<img src="images/csv.png" title="Download these informations in CSV format" alt="Download these informations in CSV format"/>
			</a>
		</div>

		<h3>Network interfaces</h3>
		
		<table>
		
			<tr>
				<th>Client {SORT_HOST}</th>
				<th>Network card {SORT_CARDTYPE} {GRAPH_CARDTYPE}</th>
				<th>State {SORT_STATE}</th>
				<th>IP address {SORT_IP}</th>
				<th>Network mask {SORT_SUBNETMASK}</th>
				<th>Gateway {SORT_GATEWAY}</th>
				<th>MAC address {SORT_MACADDRESS}</th>
				<th>Appearance {SORT_FIRSTAPPARITION}</th>
			</tr>
			
			<!-- BEGIN row -->
			
			<tr class="{ROWCLASS}">
				<td class="{HOST_CLASS}">{HOSTL}</td>
				<td class="{CARDTYPE_CLASS}">{CARDTYPE}</td>
				<td class="{STATE_CLASS}">{STATE}</td>
				<td class="{IP_CLASS}">{IP}</td>
				<td class="{SUBNETMASK_CLASS}">{SUBNETMASK}</td>
				<td class="{GATEWAY_CLASS}">{GATEWAY}</td>
				<td class="{MACADDRESS_CLASS}">{MACADDRESS}</td>
				<td class="{FIRSTAPPARITION_CLASS}">{FIRSTAPPARITION}</td>
			</tr>
			
			<!-- END row -->
			
		</table>
	
	</div>

</p>