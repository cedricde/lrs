	<div id="sound-informations">

		<div class="download-informations">
			<a href="{DONWLOAD_URL}">
				<img src="images/csv.png" title="Télécharger ces informations au format CSV" alt="Télécharger ces informations au format CSV"/>
			</a>
		</div>

		<h3>Contrôleurs son</h3>
		
		<table>
		
			<tr>
				<th>Client {SORT_HOST}</th>
				<th>Nom {SORT_NAME}</th>
				<th>Description {SORT_DESCRIPTION}</th>
				<th>Apparition {SORT_FIRSTAPPARITION}</th>
			</tr>
			
			<!-- BEGIN row -->
			
			<tr class="{ROWCLASS}">
				<td class="{HOST_CLASS}">{HOSTL}</td>
				<td class="{NAME_CLASS}">{NAME}</td>
				<td class="{DESCRIPTION_CLASS}">{DESCRIPTION}</td>
				<td class="{FIRSTAPPARITION_CLASS}">{FIRSTAPPARITION}</td>
			</tr>
			
			<!-- END row -->
			
		</table>
	
	</div>

</p>