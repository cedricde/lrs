<link rel='StyleSheet' href='/lrs-inventory/css/main.css' type='text/css' media='screen' />

<p>

	<div id="os-informations">

		<div class="download-informations">
			<a href="{DONWLOAD_URL}">
				<img src="images/csv.png" title="Télécharger ces informations au format CSV" alt="Télécharger ces informations au format CSV"/>
			</a>
		</div>

		<h3>Système d'exploitation</h3>

		<table>
		
			<tr>
				<th>Client {SORT_HOST}</th>
				<th>Système d'exploitation {SORT_OPERATINGSYSTEM} {GRAPH_OPERATINGSYSTEM}</th>
				<th>Version {SORT_VERSION} {GRAPH_VERSION}</th>
				<th>Build {SORT_BUILD}</th>
				<th>Enregistré à {SORT_REGISTEREDNAME}</th>
				<th>Entreprise {SORT_REGISTEREDCOMPANY}</th>
				<th>Numéro de série {SORT_OSSERIALNUMBER}</th>
				<th>Apparition {SORT_FIRSTAPPARITION}</th>
			</tr>
			
			<!-- BEGIN row -->
			
			<tr class="{ROWCLASS}">
				<td class="{HOST_CLASS}">{HOSTL}</td>
				<td class="{OPERATINGSYSTEM_CLASS}">{OPERATINGSYSTEM}</td>
				<td class="{VERSION_CLASS}">{VERSION}</td>
				<td class="{BUILD_CLASS}">{BUILD}</td>
				<td class="{REGISTEREDNAME_CLASS}">{REGISTEREDNAME}</td>
				<td class="{REGISTEREDCOMPANY_CLASS}">{REGISTEREDCOMPANY}</td>
				<td class="{OSSERIALNUMBER_CLASS}">{OSSERIALNUMBER}</td>
				<td class="{FIRSTAPPARITION_CLASS}">{FIRSTAPPARITION}</td>
			</tr>
			
			<!-- END row -->
			
		</table>
	
	</div>

</p>