
<p>

	<div id="input-informations">

		<div class="download-informations">
			<a href="{DONWLOAD_URL}">
				<img src="images/csv.png" title="T�l�charger ces informations au format CSV" alt="T�l�charger ces informations au format CSV"/>
			</a>
		</div>
	
		<h3>P�riph�riques d'entr�e</h3>
		
		<table>
		
			<tr>
				<th>Client {SORT_HOST}</th>
				<th>Type {SORT_TYPE}</th>
				<th>Description {SORT_STANDARDDESCRIPTION}</th>
				<th>Description �tendue {SORT_EXPANDEDDESCRIPTION}</th>
				<th>Connecteur {SORT_CONNECTOR}</th>
				<th>Apparition {SORT_FIRSTAPPARITION}</th>
			</tr>
			
			<!-- BEGIN row -->
			
			<tr class="{ROWCLASS}">
				<td class="{HOST_CLASS}">{HOSTL}</td>
				<td class="{TYPE_CLASS}">{TYPE}</td>
				<td class="{STANDARDDESCRIPTION_CLASS}">{STANDARDDESCRIPTION}</td>
				<td class="{EXPANDEDDESCRIPTION_CLASS}">{EXPANDEDDESCRIPTION}</td>
				<td class="{CONNECTOR_CLASS}">{CONNECTOR}</td>
				<td class="{FIRSTAPPARITION_CLASS}">{FIRSTAPPARITION}</td>
			</tr>
			
			<!-- END row -->
			
		</table>
	
	</div>

</p>