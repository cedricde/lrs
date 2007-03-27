<div class="lsc-hosts-states-list">
	<table>
	<thead>
		<tr>
			<th></th>
			<th>Host</th>
			<th>Current state</th>
			<th>Upload state</th>
			<th>Execute state</th>
			<th>Delete state</th>
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
			<td class="action-column"><a href="command_on_host_detail.cgi?mac={MAC}&pwd={PWD}&repository_pwd={REPOSITORY_PWD}&id_command_on_host={ID_COMMAND_ON_HOST}">View detail</a></td>
		</tr>
		<!-- END HOSTS_LIST_ROW -->
	</tbody>
	</table>
</div>
