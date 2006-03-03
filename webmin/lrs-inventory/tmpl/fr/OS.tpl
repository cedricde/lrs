<link rel='StyleSheet' href='/lrs-inventory/css/main.css' type='text/css' media='screen' />

<p>

	<div id="os-informations">

		<div class="download-informations">
			<a href="{DONWLOAD_URL}">
				<img src="images/csv.png" title="T�l�charger ces informations au format CSV" alt="T�l�charger ces informations au format CSV"/>
			</a>
		</div>

		<h3>Syst�me d'exploitation</h3>

		<table>
		
			<tr>
				<th>Client {SORT_HOST}</th>
				<th>Syst�me d'exploitation {SORT_OPERATINGSYSTEM} {GRAPH_OPERATINGSYSTEM}</th>
				<th>Version {SORT_VERSION} {GRAPH_VERSION}</th>
				<th>Build {SORT_BUILD}</th>
				<th>Enregistr� � {SORT_REGISTEREDNAME}</th>
				<th>Entreprise {SORT_REGISTEREDCOMPANY}</th>
				<th>Num�ro de s�rie {SORT_OSSERIALNUMBER}</th>
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