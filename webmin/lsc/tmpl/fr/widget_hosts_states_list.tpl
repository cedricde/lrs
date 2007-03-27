<div class="lsc-hosts-states-list">
	<table>
	<thead>
		<tr>
			<th></th>
			<th>Machines</th>
			<th>État courrant</th>
			<th>État du transfert</th>
			<th>État de l'exécution</th>
			<th>État de la suppression</th>
			<th>Actions</th>
		</tr>
	</thead>
	<tbody>
		<!-- BEGIN HOSTS_LIST_ROW -->
		<tr class={ROW_CLASS}>
			<td class="index-column">{INDEX}</td>
			<td class="hostname-column">{HOSTNAME}</td>
			<td class="current-state-column">{CURRENT_STATE}</td>
			<td class="uploaded-column">{UPLOADED}</td>
			<td class="executed-column">{EXECUTED}</td>
			<td class="deleted-column">{DELETED}</td>
			<td class="action-column"><a href="command_on_host_detail.cgi?mac={MAC}&pwd={PWD}&repository_pwd={REPOSITORY_PWD}&id_command_on_host={ID_COMMAND_ON_HOST}">Voir le détail</a></td>
		</tr>
		<!-- END HOSTS_LIST_ROW -->
	</tbody>
	</table>
</div>
