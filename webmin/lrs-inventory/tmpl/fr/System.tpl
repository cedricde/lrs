<p>

	<div id="general-informations">

		<div class="download-informations">
			<a href="{DONWLOAD_URL}">
				<img src="images/csv.png" title="Download these informations in CSV format" alt="Download these informations in CSV format"/>
			</a>
		</div>

		<h3>Informations générales</h3>

		<table>
		
			<tr>
				<th>Client {SORT_HOST}</th>
				<th>Marque {SORT_SYSTEM0} {GRAPH_SYSTEM0}</th>
				<th>Modèle {SORT_SYSTEM1}</th>
				<th>Version {SORT_SYSTEM2}</th>
				<th>Série {SORT_SYSTEM3}</th>
				<th>UUID {SORT_SYSTEM4}</th>
				<th>Type {SORT_CHASSIS1}</th>
				<th>Apparition {SORT_FIRSTAPPARITION}</th>
			</tr>
			
			<!-- BEGIN row -->
			
			<tr class="{ROWCLASS}">
				<td class="{HOST_CLASS}">{HOSTL}</td>
				<td class="{SYSTEM0_CLASS}">{SYSTEM0}</td>
				<td class="{SYSTEM1_CLASS}">{SYSTEM1}</td>
				<td class="{SYSTEM2_CLASS}">{SYSTEM2}</td>
				<td class="{SYSTEM3_CLASS}">{SYSTEM3}</td>
				<td class="{SYSTEM4_CLASS}">{SYSTEM4}</td>
				<td class="{CHASSIS1_CLASS}">{CHASSIS1}</td>
				<td class="{FIRSTAPPARITION_CLASS}">{FIRSTAPPARITION}</td>
			</tr>			
			<!-- END row -->			
		</table>	
	</div>
</p>
