	<div id="sound-informations">

		<div class="download-informations">
			<a href="{DONWLOAD_URL}">
				<img src="images/csv.png" title="Télécharger ces informations au format CSV" alt="Télécharger ces informations au format CSV"/>
			</a>
		</div>

		<h3>Cartes graphiques</h3>
		
		<table>
		
			<tr>
				<th>Client {SORT_HOST}</th>
				<th>Modèle {SORT_MODEL}</th>
				<th>Chipset {SORT_CHIPSET}</th>
				<th>Mémoire {SORT_VRAMSIZE}</th>
				<th>Résolution {SORT_RESOLUTION}</th>
				<th>Apparition {SORT_FIRSTAPPARITION}</th>
			</tr>
			
			<!-- BEGIN row -->
			
			<tr class="{ROWCLASS}">
				<td class="{HOST_CLASS}">{HOSTL}</td>
				<td class="{MODEL_CLASS}">{MODEL}</td>
				<td class="{CHIPSET_CLASS}">{CHIPSET}</td>
				<td class="{VRAMSIZE_CLASS}">{VRAMSIZE}</td>
				<td class="{RESOLUTION_CLASS}">{RESOLUTION}</td>
				<td class="{FIRSTAPPARITION_CLASS}">{FIRSTAPPARITION}</td>
			</tr>
			
			<!-- END row -->
			
		</table>
	
	</div>

</p>