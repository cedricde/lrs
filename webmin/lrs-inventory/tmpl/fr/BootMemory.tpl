<p>

	<div id="memory-informations">
	
		<div class="download-informations">
			<a href="{DONWLOAD_URL}">
				<img src="images/csv.png" title="Télécharger ces informations au format CSV" alt="Télécharger ces informations au format CSV"/>
			</a>
		</div>
	
		<h3>Mémoire détectée au boot</h3>
		
		<table>
		
			<tr>
				<th>Client {SORT_HOST}</th>
				<th>Mémoire totale {SORT_TOTALMEM} {GRAPH_TOTALMEM}</th>
				<th>Mémoire basse {SORT_LOWMEM}</th>
				<th>Mémoire haute {SORT_HIGHMEM}</th>
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