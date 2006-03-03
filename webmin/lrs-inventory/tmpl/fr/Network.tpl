<link rel='StyleSheet' href='/lrs-inventory/css/main.css' type='text/css' media='screen' />

<h2>Informations réseau</h2>

<p>

	<div id="network-informations">

		<div class="download-informations">
			<a href="{DONWLOAD_URL}">
				<img src="images/csv.png" title="Télécharger ces informations au format CSV" alt="Télécharger ces informations au format CSV"/>
			</a>
		</div>

		<h3>Interfaces réseau</h3>
		
		<table>
		
			<tr>
				<th>Client {SORT_HOST}</th>
				<th>Carte réseau {SORT_CARDTYPE} {GRAPH_CARDTYPE}</th>
				<th>Etat {SORT_STATE}</th>
				<th>Adresse IP {SORT_IP}</th>
				<th>Masque de sous-réseau {SORT_SUBNETMASK}</th>
				<th>Passerelle {SORT_GATEWAY}</th>
				<th>Adresse MAC {SORT_MACADDRESS}</th>
				<th>Apparition {SORT_FIRSTAPPARITION}</th>
			</tr>
			
			<!-- BEGIN row -->
			
			<tr class="{ROWCLASS}">
				<td class="{HOST_CLASS}">{HOSTL}</td>
				<td class="{CARDTYPE_CLASS}">{CARDTYPE}</td>
				<td class="{STATE_CLASS}">{STATE}</td>
				<td class="{IP_CLASS}">{IP}</td>
				<td class="{SUBNETMASK_CLASS}">{SUBNETMASK}</td>
				<td class="{GATEWAY_CLASS}">{GATEWAY}</td>
				<td class="{MACADDRESS_CLASS}">{MACADDRESS}</td>
				<td class="{FIRSTAPPARITION_CLASS}">{FIRSTAPPARITION}</td>
			</tr>
			
			<!-- END row -->
			
		</table>
	
	</div>

</p>