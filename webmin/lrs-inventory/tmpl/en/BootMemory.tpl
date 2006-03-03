<p>

	<div id="memory-informations">
	
		<div class="download-informations">
			<a href="{DONWLOAD_URL}">
				<img src="images/csv.png" title="Download these informations in CSV format" alt="Download these informations in CSV format"/>
			</a>
		</div>
	
		<h3>Memory detected at boot</h3>
		
		<table>
		
			<tr>
				<th>Client {SORT_HOST}</th>
				<th>Total memory {SORT_TOTALMEM} {GRAPH_TOTALMEM}</th>
				<th>Low memory {SORT_LOWMEM}</th>
				<th>High memory {SORT_HIGHMEM}</th>
				<th>Apparition {SORT_FIRSTAPPARITION}</th>
			</tr>
			
			<!-- BEGIN row -->
			
			<tr class="{ROWCLASS}">
				<td class="{HOST_CLASS}">{HOSTL}</td>
				<td class="{TOTALMEM_CLASS}">{TOTALMEM} KB</td>
				<td class="{LOWMEM_CLASS}">{LOWMEM} KB</td>
				<td class="{HIGHMEM_CLASS}">{HIGHMEM} KB</td>
				<td class="{FIRSTAPPARITION_CLASS}">{FIRSTAPPARITION}</td>
			</tr>
			
			<!-- END row -->
			
		</table>
	
	</div>

</p>