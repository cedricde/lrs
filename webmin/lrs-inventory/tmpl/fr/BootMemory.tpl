<p>

	<div id="memory-informations">
	
		<div class="download-informations">
			<a href="{DONWLOAD_URL}">
				<img src="images/csv.png" title="T�l�charger ces informations au format CSV" alt="T�l�charger ces informations au format CSV"/>
			</a>
		</div>
	
		<h3>M�moire d�tect�e au boot</h3>
		
		<table>
		
			<tr>
				<th>Client {SORT_HOST}</th>
				<th>M�moire totale {SORT_TOTALMEM} {GRAPH_TOTALMEM}</th>
				<th>M�moire basse {SORT_LOWMEM}</th>
				<th>M�moire haute {SORT_HIGHMEM}</th>
				<th>Apparition {SORT_FIRSTAPPARITION}</th>
			</tr>
			
			<!-- BEGIN row -->
			
			<tr class="{ROWCLASS}">
				<td class="{HOST_CLASS}">{HOSTL}</td>
				<td class="{TOTALMEM_CLASS}">{TOTALMEM} Ko</td>
				<td class="{LOWMEM_CLASS}">{LOWMEM} Ko</td>
				<td class="{HIGHMEM_CLASS}">{HIGHMEM} Ko</td>
				<td class="{FIRSTAPPARITION_CLASS}">{FIRSTAPPARITION}</td>
			</tr>
			
			<!-- END row -->
			
		</table>
	
	</div>

</p>