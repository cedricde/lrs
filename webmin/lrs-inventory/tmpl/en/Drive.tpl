<link rel='StyleSheet' href='/lrs-inventory/css/main.css' type='text/css' media='screen' />

<p>

	<div id="drive-informations">

		<div class="download-informations">
			<a href="{DONWLOAD_URL}">
				<img src="images/csv.png" title="Download these informations in CSV format" alt="Download these informations in CSV format"/>
			</a>
		</div>

		<h3>Windows logical drives</h3>
		
		<table>
		
			<tr>
				<th>Client {SORT_HOST}</th>
				<th>Letter {SORT_DRIVELETTER}</th>
				<th>Type {SORT_DRIVETYPE}</th>
				<th>Name {SORT_VOLUMENAME}</th>
				<th>File system {SORT_FILESYSTEM}</th>
				<th>Size {SORT_TOTALSPACE}</th>
				<th>Free space {SORT_FREESPACE}</th>
				<th>File count {SORT_FILECOUNT}</th>
				<th>Appearance {SORT_FIRSTAPPARITION}</th>
			</tr>
			
			<!-- BEGIN row -->
			
			<tr class="{ROWCLASS}">
				<td class="{HOST_CLASS}">{HOSTL}</td>
				<td class="{DRIVELETTER_CLASS}">{DRIVELETTER}</td>
				<td class="{DRIVETYPE_CLASS}">{DRIVETYPE}</td>
				<td class="{VOLUMENAME_CLASS}">{VOLUMENAME}</td>
				<td class="{FILESYSTEM_CLASS}">{FILESYSTEM}</td>
				<td class="{TOTALSPACE_CLASS}">{TOTALSPACE}</td>
				<td class="{FREESPACE_CLASS}">{FREESPACE}</td>
				<td class="{FILECOUNT_CLASS}">{FILECOUNT}</td>
				<td class="{FIRSTAPPARITION_CLASS}">{FIRSTAPPARITION}</td>
			</tr>
			
			<!-- END row -->
			
		</table>
	
	</div>

</p>