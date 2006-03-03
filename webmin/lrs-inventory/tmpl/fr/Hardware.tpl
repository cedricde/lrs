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
				<th>Type de processeur {SORT_PROCESSORTYPE}</th>
				<th>Fréquence {SORT_PROCESSORFREQUENCY}</th>
				<th>Nombre {SORT_PROCESSORCOUNT}</th>
				<th>Apparition {SORT_FIRSTAPPARITION}</th>
			</tr>
			
			<!-- BEGIN row -->
			
			<tr class="{ROWCLASS}">
				<td class="{HOST_CLASS}">{HOSTL}</td>
				<td class="{PROCESSORTYPE_CLASS}">{PROCESSORTYPE}</td>
				<td class="{PROCESSORFREQUENCY_CLASS}">{PROCESSORFREQUENCY}</td>
				<td class="{PROCESSORCOUNT_CLASS}">{PROCESSORCOUNT}</td>
				<td class="{FIRSTAPPARITION_CLASS}">{FIRSTAPPARITION}</td>
			</tr>
			
			<!-- END row -->
			
		</table>
	
	</div>

</p>