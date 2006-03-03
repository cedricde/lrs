<p>

	<div id="general-informations">
	
		<div class="download-informations">
			<a href="{DONWLOAD_URL}">
				<img src="images/csv.png" title="Download these informations in CSV format" alt="Download these informations in CSV format"/>
			</a>
		</div>
	
		<h3>Warranty</h3>

		<table>
		
			<tr>
				<th>Client {SORT_HOST}</th>
				<th>{TIT_BUYDATE} {SORT_BUYDATE}</th>
				<th>{TIT_DELIVERYDATE} {SORT_DELIVERYDATE}</th>
				<th>{TIT_WORKINGDATE} {SORT_WORKINGDATE}</th>
				<th>{TIT_WARRANTYEND} {SORT_WARRANTYEND}</th>
				<th>{TIT_SUPPORTEND} {SORT_SUPPORTEND}</th>
				<th>{TIT_BUYVALUE} {SORT_BUYVALUE}</th>
				<th>{TIT_RESIDUALVALUE} {SORT_RESIDUALVALUE}</th>
			</tr>
			
			<!-- BEGIN row -->
			
			<tr class="{ROWCLASS}" onClick="document.location='custom.cgi?host={HOST}';">
				<td class="{HOST_CLASS}">{HOSTL}</td>
				<td class="{BUYDATE_CLASS}">{BUYDATE}</td>
				<td class="{DELIVERYDATE_CLASS}">{DELIVERYDATE}</td>
				<td class="{WORKINGDATE_CLASS}">{WORKINGDATE}</td>
				<td class="{WARRANTYEND_CLASS}">{WARRANTYEND}</td>
				<td class="{SUPPORTEND_CLASS}">{SUPPORTEND}</td>
				<td class="{BUYVALUE_CLASS}">{BUYVALUE}</td>
				<td class="{RESIDUALVALUE_CLASS}">{RESIDUALVALUE}</td>
			</tr>

			<!-- END row -->
			
		</table>
	
	</div>

</p>