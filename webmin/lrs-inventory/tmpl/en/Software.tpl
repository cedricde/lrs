<link rel='StyleSheet' href='/lrs-inventory/css/main.css' type='text/css' media='screen' />

<p>

	<div id="software-informations">

		<div class="download-informations">
			<a href="{DONWLOAD_URL}">
				<img src="images/csv.png" title="Download these informations in CSV format" alt="Download these informations in CSV format"/>
			</a>
		</div>

		<h3>Installed software</h3>
		
		<table>
		
			<tr>
				<th>Client {SORT_HOST}</th>
				<th>Application {SORT_PRODUCTNAME} {GRAPH_PRODUCTNAME}</th>
				<th>Editor {SORT_COMPANY} {GRAPH_COMPANY}</th>
				<th>Vendor {SORT_PRODUCTVERSION}</th>
				<th>Size {SORT_EXECUTABLESIZE}</th>
				<th>Path {SORT_PRODUCTPATH}</th>
				<th>Comment {SORT_COMMENTS}</th>
				<th>Appearance {SORT_FIRSTAPPARITION}</th>
			</tr>
			
			<!-- BEGIN row -->
			
			<tr class="{ROWCLASS}">
				<td class="{HOST_CLASS}">{HOSTL}</td>
				<td class="{PRODUCTNAME_CLASS}">{PRODUCTNAME}</td>
				<td class="{COMPANY_CLASS}">{COMPANY}</td>
				<td class="{PRODUCTVERSION_CLASS}">{PRODUCTVERSION}</td>
				<td class="{EXECUTABLESIZE_CLASS}">{EXECUTABLESIZE}</td>
				<td class="{PRODUCTPATH_CLASS}">{PRODUCTPATH}/{APPLICATION}</td>
				<td class="{COMMENTS_CLASS}">{COMMENTS}</td>
				<td class="{FIRSTAPPARITION_CLASS}">{FIRSTAPPARITION}</td>
			</tr>
			
			<!-- END row -->
			
		</table>
	
	</div>

</p>