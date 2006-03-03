<p>

	<div id="memory-informations">
	
		<div class="download-informations">
			<a href="{DONWLOAD_URL}">
				<img src="images/csv.png" title="Download these informations in CSV format" alt="Download these informations in CSV format"/>
			</a>
		</div>
	
		<h3>Memory detected by the OS</h3>
		
		<table>
		
			<tr>
				<th>Client {SORT_HOST}</th>
				<th>RAM {SORT_RAMTOTAL} {GRAPH_RAMTOTAL}</th>
				<th>SWAP space {SORT_SWAPSPACE}</th>
				<th>Appearance {SORT_FIRSTAPPARITION}</th>
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