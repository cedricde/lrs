<div class="lsc-command-on-host-history">
	<table>
	<thead>
		<tr>
			<th>Date</th>
			<th>État</th>
			<th>Sortie standard</th>
			<th>Sortie d'erreur</th>
		</tr>
	</thead>
	<tbody>
		<!-- BEGIN COMMAND_ON_HOST_HISTORY_ROW -->
		<tr class="{ROW_CLASS}">
			<td class="date-column">{DATE}</td>
			<td class="state-column">{STATE}</td>
			<td class="stdout-column"><a href="command_on_host_history_detail.cgi?mac={MAC}&pwd={PWD}&repository_pwd={REPOSITORY_PWD}&id_command_history={ID_COMMAND_HISTORY}">{STDOUT}</a></td>
			<td class="stderr-column"><a href="command_on_host_history_detail.cgi?mac={MAC}&pwd={PWD}&repository_pwd={REPOSITORY_PWD}&id_command_history={ID_COMMAND_HISTORY}">{STDERR}</a></td>
		</tr>
		<!-- END COMMAND_ON_HOST_HISTORY_ROW -->
	</tbody>
	</table>
</div>
