<p>

	<div id="drive-informations">

		<div class="download-informations">
			<a href="{DONWLOAD_URL}">
				<img src="images/csv.png" title="Download these informations in CSV format" alt="Download these informations in CSV format"/>
			</a>
		</div>

		<h3>Partitions detected at boot</h3>
		
		<table>
		
			<tr>
				<th>Client {SORT_HOST}</th>
				<th>Disk {SORT_DISK}</th>
				<th>Number {SORT_NUM}</th>
				<th>Type {SORT_TYPE}</th>
				<th>Capacity {SORT_LENGTH}</th>
				<th>Appearance {SORT_FIRSTAPPARITION}</th>
			</tr>
			
			<!-- BEGIN row -->
			
			<tr class="{ROWCLASS}">
				<td class="{HOST_CLASS}">{HOSTL}</td>
				<td class="{DISK_CLASS}">{DISK}</td>
				<td class="{NUM_CLASS}">{NUM}</td>
				<td class="{TYPE_CLASS}">{TYPE}</td>
				<td class="{LENGTH_CLASS}">{LENGTH} MiB</td>
				<td class="{FIRSTAPPARITION_CLASS}">{FIRSTAPPARITION}</td>
			</tr>
			
			<!-- END row -->
			
		</table>
	
	</div>

</p>