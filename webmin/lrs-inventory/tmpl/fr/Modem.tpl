<p>

	<div id="modem-informations">

		<div class="download-informations">
			<a href="{DONWLOAD_URL}">
				<img src="images/csv.png" title="Télécharger ces informations au format CSV" alt="Télécharger ces informations au format CSV"/>
			</a>
		</div>

		<h3>Modems</h3>
		
		<table>
		
			<tr>
				<th>Client {SORT_HOST}</th>
				<th>Fabriquant {SORT_VENDOR}</th>
				<th>Modèle {SORT_MODEL}</th>
				<th>Description {SORT_EXPANDEDDESCRIPTION}</th>
				<th>Type {SORT_TYPE}</th>
				<th>Apparition {SORT_FIRSTAPPARITION}</th>
			</tr>
			
			<!-- BEGIN row -->
			
			<tr class="{ROWCLASS}">
				<td class="{HOST_CLASS}">{HOSTL}</td>
				<td class="{VENDOR_CLASS}">{VENDOR}</td>
				<td class="{MODEL_CLASS}">{MODEL}</td>
				<td class="{EXPANDEDDESCRIPTION_CLASS}">{EXPANDEDDESCRIPTION}</td>
				<td class="{TYPE_CLASS}">{TYPE}</td>
				<td class="{FIRSTAPPARITION_CLASS}">{FIRSTAPPARITION}</td>
			</tr>
			
			<!-- END row -->
			
		</table>
	
	</div>

</p>