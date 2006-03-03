<link rel='StyleSheet' href='/lrs-inventory/css/main.css' type='text/css' media='screen' />

<p>

	<div id="software-informations">

		<div class="download-informations">
			<a href="{DONWLOAD_URL}">
				<img src="images/csv.png" title="Télécharger ces informations au format CSV" alt="Télécharger ces informations au format CSV"/>
			</a>
		</div>

		<h3>Logiciels installés</h3>
		
		<table>
		
			<tr>
				<th>Client {SORT_HOST}</th>
				<th>Application {SORT_PRODUCTNAME} {GRAPH_PRODUCTNAME}</th>
				<th>Editeur {SORT_COMPANY} {GRAPH_COMPANY}</th>
				<th>Version {SORT_PRODUCTVERSION}</th>
				<th>Taille {SORT_EXECUTABLESIZE}</th>
				<th>Chemin {SORT_PRODUCTPATH}</th>
				<th>Apparu le {SORT_FIRSTAPPARITION}</th>
			</tr>
			
			<!-- BEGIN row -->
			
			<tr class="{ROWCLASS}">
				<td class="{HOST_CLASS}">{HOSTL}</td>
				<td class="{PRODUCTNAME_CLASS}">{PRODUCTNAME}</td>
				<td class="{COMPANY_CLASS}">{COMPANY}</td>
				<td class="{PRODUCTVERSION_CLASS}">{PRODUCTVERSION}</td>
				<td class="{EXECUTABLESIZE_CLASS}">{EXECUTABLESIZE}</td>
				<td class="{PRODUCTPATH_CLASS}">{PRODUCTPATH}/{APPLICATION}</td>
				<td class="{FIRSTAPPARITION_CLASS}" nowrap="nowrap">{FIRSTAPPARITION}</td>
			</tr>
			
			<!-- END row -->
			
		</table>
	
	</div>

</p>