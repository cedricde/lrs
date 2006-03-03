<link rel='StyleSheet' href='/lrs-inventory/css/main.css' type='text/css' media='screen' />

<p>

	<div id="os-informations">

		<div class="download-informations">
			<a href="{DONWLOAD_URL}">
				<img src="images/csv.png" title="Download these informations in CSV format" alt="Download these informations in CSV format"/>
			</a>
		</div>

		<h3>Operating system</h3>

		<table>
		
			<tr>
				<th>Client {SORT_HOST}</th>
				<th>Operating system {SORT_OPERATINGSYSTEM} {GRAPH_OPERATINGSYSTEM}</th>
				<th>Version {SORT_VERSION} {GRAPH_VERSION}</th>
				<th>Build {SORT_BUILD}</th>
				<th>Registered to {SORT_REGISTEREDNAME}</th>
				<th>Enterprise {SORT_REGISTEREDCOMPANY}</th>
				<th>Serial number {SORT_OSSERIALNUMBER}</th>
				<th>Appearance {SORT_FIRSTAPPARITION}</th>
			</tr>
			
			<!-- BEGIN row -->
			
			<tr class="{ROWCLASS}">
				<td class="{HOST_CLASS}">{HOSTL}</td>
				<td class="{OPERATINGSYSTEM_CLASS}">{OPERATINGSYSTEM}</td>
				<td class="{VERSION_CLASS}">{VERSION}</td>
				<td class="{BUILD_CLASS}">{BUILD}</td>
				<td class="{REGISTEREDNAME_CLASS}">{REGISTEREDNAME}</td>
				<td class="{REGISTEREDCOMPANY_CLASS}">{REGISTEREDCOMPANY}</td>
				<td class="{OSSERIALNUMBER_CLASS}">{OSSERIALNUMBER}</td>
				<td class="{FIRSTAPPARITION_CLASS}">{FIRSTAPPARITION}</td>
			</tr>
			
			<!-- END row -->
			
		</table>
	
	</div>

</p>