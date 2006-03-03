<p>

	<div id="pci-informations">

		<div class="download-informations">
			<a href="{DONWLOAD_URL}">
				<img src="images/csv.png" title="Download these informations in CSV format" alt="Download these informations in CSV format"/>
			</a>
		</div>

		<h3>PCI peripherals</h3>

		<table>
		
			<tr>
				<th>Client {SORT_HOST}</th>
				<th>Vendor {SORT_VENDOR} {GRAPH_VENDOR}</th>
				<th>Device {SORT_DEVICE}</th>
				<th>Class {SORT_CLASS}</th>
				<th>Type {SORT_TYPE}</th>
				<th>Bus {SORT_BUS}</th>				
				<th>Appearance {SORT_FIRSTAPPARITION}</th>
			</tr>
			
			<!-- BEGIN row -->
			
			<tr class="{ROWCLASS}">
				<td class="{HOST_CLASS}">{HOSTL}</td>
				<td class="{VENDOR_CLASS}">{VENDOR}</td>
				<td class="{DEVICE_CLASS}">{DEVICE}</td>
				<td class="{CLASS_CLASS}">{CLASS}</td>
				<td class="{TYPE_CLASS}">{TYPE}</td>
				<td class="{BUS_CLASS}">{BUS}</td>
				<td class="{FIRSTAPPARITION_CLASS}">{FIRSTAPPARITION}</td>
			</tr>
			<!-- END row -->
		</table>
	</div>
</p>
