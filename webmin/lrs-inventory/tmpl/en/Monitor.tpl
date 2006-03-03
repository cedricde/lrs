<p>

	<div id="monitor-informations">

		<div class="download-informations">
			<a href="{DONWLOAD_URL}">
				<img src="images/csv.png" title="Download these informations in CSV format" alt="Download these informations in CSV format"/>
			</a>
		</div>

		<h3>Monitors</h3>
		
		<table>
		
			<tr>
				<th>Client {SORT_HOST}</th>
				<th>Category {SORT_STAMP}</th>
				<th>Description {SORT_DESCRIPTION}</th>
				<th>Type {SORT_TYPE}</th>
				<th>Appearance {SORT_FIRSTAPPARITION}</th>
			</tr>
			
			<!-- BEGIN row -->
			
			<tr class="{ROWCLASS}">
				<td class="{HOST_CLASS}">{HOSTL}</td>
				<td class="{STAMP_CLASS}">{STAMP}</td>
				<td class="{DESCRIPTION_CLASS}">{DESCRIPTION}</td>
				<td class="{TYPE_CLASS}">{TYPE}</td>
				<td class="{FIRSTAPPARITION_CLASS}">{FIRSTAPPARITION}</td>
			</tr>

			<!-- END row -->
			
		</table>
	
	</div>

</p>