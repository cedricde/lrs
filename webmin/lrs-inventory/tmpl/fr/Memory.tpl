<p>

	<div id="memory-informations">
	
		<div class="download-informations">
			<a href="{DONWLOAD_URL}">
				<img src="images/csv.png" title="T�l�charger ces informations au format CSV" alt="T�l�charger ces informations au format CSV"/>
			</a>
		</div>
	
		<h3>M�moire d�tect�e par l'OS</h3>
		
		<table>
		
			<tr>
				<th>Client {SORT_HOST}</th>
				<th>M�moire RAM {SORT_RAMTOTAL} {GRAPH_RAMTOTAL}</th>
				<th>M�moire tampon {SORT_SWAPSPACE}</th>
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