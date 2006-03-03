<p>

	<div id="drive-informations">

		<div class="download-informations">
			<a href="{DONWLOAD_URL}">
				<img src="images/csv.png" title="Télécharger ces informations au format CSV" alt="Télécharger ces informations au format CSV"/>
			</a>
		</div>

		<h3>Partitions détectées au boot</h3>
		
		<table>
		
			<tr>
				<th>Client {SORT_HOST}</th>
				<th>Disque {SORT_DISK}</th>
				<th>Partition {SORT_NUM}</th>
				<th>Type {SORT_TYPE}</th>
				<th>Capacité {SORT_LENGTH}</th>
				<th>Apparition {SORT_FIRSTAPPARITION}</th>
			</tr>
			
			<!-- BEGIN row -->
			
			<tr class="{ROWCLASS}">
				<td class="{HOST_CLASS}">{HOSTL}</td>
				<td class="{DISK_CLASS}">{DISK}</td>
				<td class="{NUM_CLASS}">{NUM}</td>
				<td class="{TYPE_CLASS}">{TYPE}</td>
				<td class="{LENGTH_CLASS}">{LENGTH} Mo</td>
				<td class="{FIRSTAPPARITION_CLASS}">{FIRSTAPPARITION}</td>
			</tr>
			
			<!-- END row -->
			
		</table>
	
	</div>

</p>