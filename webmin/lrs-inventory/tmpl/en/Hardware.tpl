<link rel='StyleSheet' href='/lrs-inventory/css/main.css' type='text/css' media='screen' />

<h2>Hardware</h2>

<p>

	<div id="processor-informations">
	
		<div class="download-informations">
			<a href="{DONWLOAD_URL}">
				<img src="images/csv.png" title="Download these informations in CSV format" alt="Download these informations in CSV format"/>
			</a>
		</div>
	
		<h3>Processor (OCS)</h3>
		
		<table>
		
			<tr>
				<th>Client {SORT_HOST}</th>
				<th>Processor type {SORT_PROCESSORTYPE}</th>
				<th>Frequency {SORT_PROCESSORFREQUENCY}</th>
				<th>Number {SORT_PROCESSORCOUNT}</th>
				<th>Appearance {SORT_FIRSTAPPARITION}</th>
			</tr>
			
			<!-- BEGIN row -->
			
			<tr class="{ROWCLASS}">
				<td class="{HOST_CLASS}">{HOSTL}</td>
				<td class="{PROCESSORTYPE_CLASS}">{PROCESSORTYPE}</td>
				<td class="{PROCESSORFREQUENCY_CLASS}">{PROCESSORFREQUENCY}</td>
				<td class="{PROCESSORCOUNT_CLASS}">{PROCESSORCOUNT}</td>
				<td class="{FIRSTAPPARITION_CLASS}">{FIRSTAPPARITION}</td>
			</tr>
			
			<!-- END row -->
			
		</table>
	
	</div>

</p>