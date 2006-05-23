<p>

	<div id="general-informations">

		<div class="download-informations">
			<a href="{DONWLOAD_URL}">
				<img src="images/csv.png" title="Download these informations in CSV format" alt="Download these informations in CSV format"/>
			</a>
		</div>

		<h3>General information (OCS)</h3>

		<table>
		
			<tr>
				<th>Client {SORT_HOST}</th>
				<th>Brand {SORT_CHIPVENDOR}</th>
				<th>Model {SORT_CHIPSET}</th>
				<th>Version </th>
				<th>Serial {SORT_SERIAL}</th>
				<th>UUID </th>
				<th>Chassis {SORT_TYPEMACHINE}</th>
				<th>Appearance {SORT_FIRSTAPPARITION}</th>
			</tr>
			
			<!-- BEGIN row -->
			
			<tr class="{ROWCLASS}">
				<td class="{HOST_CLASS}">{HOSTL}</td>
				<td class="{CHIPVENDOR_CLASS}">{CHIPVENDOR}</td>
				<td class="{CHIPSET_CLASS}">{CHIPSET}</td>
				<td class="{CLASS}"></td>
				<td class="{SERIAL_CLASS}">{SERIAL}</td>
				<td class="{CLASS}"></td>
				<td class="{TYPEMACHINE_CLASS}">{TYPEMACHINE}</td>
				<td class="{FIRSTAPPARITION_CLASS}">{FIRSTAPPARITION}</td>
			</tr>			
			<!-- END row -->			
		</table>	
	</div>
</p>
