<p>

	<div id="memory-informations">
	
		<div class="download-informations">
			<a href="{DONWLOAD_URL}">
				<img src="images/csv.png" title="Télécharger ces informations au format CSV" alt="Télécharger ces informations au format CSV"/>
			</a>
		</div>
	
		<h3>Mémoire détectée par l'OS</h3>
		
		<table>
		
			<tr>
				<th>Client {SORT_HOST}</th>
				<th>Mémoire RAM {SORT_RAMTOTAL} {GRAPH_RAMTOTAL}</th>
				<th>Mémoire tampon {SORT_SWAPSPACE}</th>
				<th>Apparition {SORT_FIRSTAPPARITION}</th>
			</tr>
			
			<!-- BEGIN row -->
			
			<tr class="{ROWCLASS}">
				<td class="{HOST_CLASS}">{HOSTL}</td>
				<td class="{RAMTOTAL_CLASS}">{RAMTOTAL}</td>
				<td class="{SWAPSPACE_CLASS}">{SWAPSPACE}</td>
				<td class="{FIRSTAPPARITION_CLASS}">{FIRSTAPPARITION}</td>
			</tr>
			
			<!-- END row -->
			
		</table>
	
	</div>

</p>