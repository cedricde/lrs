<p>

	<div id="mem-informations">
	
		<div class="download-informations">
			<a href="{DONWLOAD_URL}">
				<img src="images/csv.png" title="Télécharger ces informations au format CSV" alt="Télécharger ces informations au format CSV"/>
			</a>
		</div>
	
		<h3>Barettes mémoire</h3>
		
		<table>
		
			<tr>
				<th>Client {SORT_HOST}</th>
				<th>Utilisée {SORT_USED}</th>
				<th>Capacité {SORT_CAPACITY}</th>
				<th>Emplacement {SORT_LOCATION}</th>
				<th>Type {SORT_FORM}</th>
				<th>Détails {SORT_TYPE}</th>
				<th>Apparition {SORT_FIRSTAPPARITION}</th>
			</tr>
			
			<!-- BEGIN row -->
			
			<tr class="{ROWCLASS}">
				<td class="{HOST_CLASS}">{HOSTL}</td>
				<td class="{USED_CLASS}">{USED}</td>
				<td class="{CAPACITY_CLASS}">{CAPACITY}</td>
				<td class="{LOCATION_CLASS}">{LOCATION}</td>
				<td class="{FORM_CLASS}">{FORM}</td>
				<td class="{TYPE_CLASS}">{TYPE}</td>
				<td class="{FIRSTAPPARITION_CLASS}">{FIRSTAPPARITION}</td>
			</tr>
			
			<!-- END row -->
			
		</table>
	
	</div>

</p>