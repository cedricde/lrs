<p>

	<div id="drive-informations">

		<div class="download-informations">
			<a href="{DONWLOAD_URL}">
				<img src="images/csv.png" title="Télécharger ces informations au format CSV" alt="Télécharger ces informations au format CSV"/>
			</a>
		</div>

		<h3>Disques détectés au boot</h3>
		
		<table>
		
			<tr>
				<th>Client {SORT_HOST}</th>
				<th>Numéro {SORT_NUM}</th>
				<th>Capacité {SORT_CAPACITY} {GRAPH_CAPACITY}</th>
				<th>Cylindres {SORT_CYL}</th>
				<th>Tetes {SORT_HEAD}</th>
				<th>Secteurs {SORT_SECTOR}</th>
				<th>Apparition {SORT_FIRSTAPPARITION}</th>
			</tr>
			
			<!-- BEGIN row -->
			
			<tr class="{ROWCLASS}">
				<td class="{HOST_CLASS}">{HOSTL}</td>
				<td class="{NUM_CLASS}">{NUM}</td>
				<td class="{CAPACITY_CLASS}">{CAPACITY} Mo</td>
				<td class="{CYL_CLASS}">{CYL}</td>
				<td class="{HEAD_CLASS}">{HEAD}</td>
				<td class="{SECTOR_CLASS}">{SECTOR}</td>
				<td class="{FIRSTAPPARITION_CLASS}">{FIRSTAPPARITION}</td>
			</tr>
			
			<!-- END row -->
			
		</table>
	
	</div>

</p>