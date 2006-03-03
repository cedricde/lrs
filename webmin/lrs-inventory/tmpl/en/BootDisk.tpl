<p>

	<div id="drive-informations">

		<div class="download-informations">
			<a href="{DONWLOAD_URL}">
				<img src="images/csv.png" title="Download these informations in CSV format" alt="Download these informations in CSV format"/>
			</a>
		</div>

		<h3>Disks detected at boot</h3>
		
		<table>
		
			<tr>
				<th>Client {SORT_HOST}</th>
				<th>Number {SORT_NUM}</th>
				<th>Capacity {SORT_CAPACITY} {GRAPH_CAPACITY}</th>
				<th>Cylinders {SORT_CYL}</th>
				<th>Heads {SORT_HEAD}</th>
				<th>Sectors {SORT_SECTOR}</th>
				<th>Appearance {SORT_FIRSTAPPARITION}</th>
			</tr>
			
			<!-- BEGIN row -->
			
			<tr class="{ROWCLASS}">
				<td class="{HOST_CLASS}">{HOSTL}</td>
				<td class="{NUM_CLASS}">{NUM}</td>
				<td class="{CAPACITY_CLASS}">{CAPACITY} MiB</td>
				<td class="{CYL_CLASS}">{CYL}</td>
				<td class="{HEAD_CLASS}">{HEAD}</td>
				<td class="{SECTOR_CLASS}">{SECTOR}</td>
				<td class="{FIRSTAPPARITION_CLASS}">{FIRSTAPPARITION}</td>

			</tr>
			
			<!-- END row -->
			
		</table>
	
	</div>

</p>