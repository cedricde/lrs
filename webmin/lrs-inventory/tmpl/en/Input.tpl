
<p>

	<div id="input-informations">

		<div class="download-informations">
			<a href="{DONWLOAD_URL}">
				<img src="images/csv.png" title="Download these informations in CSV format" alt="Download these informations in CSV format"/>
			</a>
		</div>
	
		<h3>Input peripherals</h3>
		
		<table>
		
			<tr>
				<th>Client {SORT_HOST}</th>
				<th>Type {SORT_TYPE}</th>
				<th>Description {SORT_STANDARDDESCRIPTION}</th>
				<th>Extended description {SORT_EXPANDEDDESCRIPTION}</th>
				<th>Connector {SORT_CONNECTOR}</th>
				<th>Appearance {SORT_FIRSTAPPARITION}</th>
			</tr>
			
			<!-- BEGIN row -->
			
			<tr class="{ROWCLASS}">
				<td class="{HOST_CLASS}">{HOSTL}</td>
				<td class="{TYPE_CLASS}">{TYPE}</td>
				<td class="{STANDARDDESCRIPTION_CLASS}">{STANDARDDESCRIPTION}</td>
				<td class="{EXPANDEDDESCRIPTION_CLASS}">{EXPANDEDDESCRIPTION}</td>
				<td class="{CONNECTOR_CLASS}">{CONNECTOR}</td>
				<td class="{FIRSTAPPARITION_CLASS}">{FIRSTAPPARITION}</td>
			</tr>
			
			<!-- END row -->
			
		</table>
	
	</div>

</p>