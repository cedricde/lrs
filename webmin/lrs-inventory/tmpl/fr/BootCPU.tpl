<link rel='StyleSheet' href='/lrs-inventory/css/main.css' type='text/css' media='screen' />

<h2>Matériel</h2>

<p>

	<div id="processor-informations">
	
		<div class="download-informations">
			<a href="{DONWLOAD_URL}">
				<img src="images/csv.png" title="Télécharger ces informations au format CSV" alt="Télécharger ces informations au format CSV"/>
			</a>
		</div>
	
		<h3>Processeur</h3>
		
		<table>
		
			<tr>
				<th>Client {SORT_HOST}</th>
				<th>Type {SORT_MODEL} {GRAPH_MODEL}</th>
				<th>Fréquence {SORT_FREQ} {GRAPH_FREQ}</th>
				<th>Nombre {SORT_CPUNUM}</th>
				<th>Apparition {SORT_FIRSTAPPARITION}</th>
			</tr>
			
			<!-- BEGIN row -->
			
			<tr class="{ROWCLASS}">
				<td class="{HOST_CLASS}">{HOSTL}</td>
				<td class="{MODEL_CLASS}">{CPUVENDOR} {MODEL}</td>
				<td class="{FREQ_CLASS}">{FREQ}</td>
				<td class="{CPUNUM_CLASS}">{CPUNUM}</td>
				<td class="{FIRSTAPPARITION_CLASS}">{FIRSTAPPARITION}</td>
			</tr>
			
			<!-- END row -->
			
		</table>
	
	</div>

</p>