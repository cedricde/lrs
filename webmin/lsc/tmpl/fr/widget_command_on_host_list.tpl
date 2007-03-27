<div class="lsc-hosts-list">
	<table>
	<thead>
		<tr>
			<th></th>
			<th>Machines</th>
			<th>Adresse IP</th>
			<th>Adresse MAC</th>
			<th>État</th>
			<th>Actions</th>
		</tr>
	</thead>
	<tbody>
		<!-- BEGIN HOSTS_LIST_ROW -->
		<tr class={ROW_CLASS}>
			<td class="index-column" style="text-align:center">{HOSTS_LIST_INDEX}</td>
			<td class="hostname-column" style="text-align:center"><a href="command_on_host_detail.cgi?mac={MAC_AND_DOT}&profile={PROFILE}&group={GROUP}&id_command_on_host={ID_COMMAND_ON_HOST}">{HOSTS_LIST_HOSTNAME}</a></td>
			<td class="ip-column" style="text-align:center"><a href="command_on_host_detail.cgi?mac={MAC_AND_DOT}&profile={PROFILE}&group={GROUP}&id_command_on_host={ID_COMMAND_ON_HOST}">{HOSTS_LIST_IP}</a></td>
			<td class="mac-column" style="text-align:center"><a href="command_on_host_detail.cgi?mac={MAC_AND_DOT}&profile={PROFILE}&group={GROUP}&id_command_on_host={ID_COMMAND_ON_HOST}">{HOSTS_LIST_MAC}</a></td>
			<td class="state-column" style="text-align:center">{HOSTS_LIST_CURRENT_STATES}</a></td>
			<td class="action-column" style="text-align:center"><a href="command_on_host_detail.cgi?mac={MAC_AND_DOT}&profile={PROFILE}&group={GROUP}&id_command_on_host={ID_COMMAND_ON_HOST}">Détail de la commande sur cette machine</a></td>
		</tr>
		<!-- END HOSTS_LIST_ROW -->
	</tbody>
	</table>
</div>
