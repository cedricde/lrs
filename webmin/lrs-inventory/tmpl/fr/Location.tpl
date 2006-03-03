<p>

	<div id="location-informations">
	
		<div class="download-informations">
			<a href="{DONWLOAD_URL}">
				<img src="images/csv.png" title="Télécharger ces informations au format CSV" alt="Télécharger ces informations au format CSV"/>
			</a>
		</div>
	
		<h3>Localisations</h3>
		
		<table>
		
			<tr>
				<th>Client {SORT_HOST}</th>
				<th>{TIT_DEPARTMENT} {SORT_DEPARTMENT}</th>
				<th>{TIT_LOCATION} {SORT_LOCATION}</th>
				<th>{TIT_PHONE} {SORT_PHONE}</th>
				<th>{TIT_COMMENTS} {SORT_COMMENTS}</th>
			</tr>
			
			<!-- BEGIN row -->
			
			<tr class="{ROWCLASS}" onClick="document.location='custom.cgi?host={HOST}&id='+event.target.id;">
				<td class="{HOST_CLASS}">{HOSTL}</td>
				<td class="{DEPARTMENT_CLASS}" id="department">{DEPARTMENT}</td>
				<td class="{LOCATION_CLASS}" id="location">{LOCATION}</td>
				<td class="{PHONE_CLASS}" id="phone">{PHONE}</td>
				<td class="{COMMENTS_CLASS}" id="comments">{COMMENTS}</td>
			</tr>
			
			<!-- END row -->
			
		</table>
	
	</div>

</p>