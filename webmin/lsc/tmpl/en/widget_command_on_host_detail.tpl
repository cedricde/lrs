<div id="lsc-command-on-host-detail"> <!-- COMMAND ON HOST DETAIL -->
	<p>Command state :</p>
	<table>
	<thead>
		<tr>
			<th>Current state</th>
			<th>Upload state</th>
			<th>Execution state</th>
			<th>Delete state</th>
		</tr>
	</thead>
	<tbody>
		<tr>
			<td>{CURRENT_STATE}</td>
			<td>{CURRENT_UPLOADED}</td>
			<td>{CURRENT_EXECUTED}</td>
			<td>{CURRENT_DELETED}</td>
		</tr>
	</tbody>
	</table>

	<p>Task informations :</p>
	<table>
		<tr>
			<th>Host name</th>
			<td>{COMMAND_HOSTNAME}</td>
		</tr>
		<tr>
			<th>Create date command:</th>
			<td>{COMMAND_DATE_CREATED}</td>
		</tr>
		<tr>
			<th>Execute file :</th>
			<td>{COMMAND_START_FILE}</td>
		</tr>
		<tr>
			<th>Execution arguments :</th>
			<td>{COMMAND_PARAMETERS}</td>
		</tr>
		<tr>
			<th>Destination directory :</th>
			<td>{COMMAND_PATH_DESTINATION}</td>
		</tr>
		<tr>
			<th>Source directory (files repository) :</th>
			<td>{COMMAND_PATH_SOURCE}</td>
		</tr>
		<tr>
			<th>Create destination directory :</th>
			<td>{COMMAND_CREATE_DIRECTORY}</td>
		</tr>
		<tr>
			<th>Start execute file :</th>
			<td>{COMMAND_START_SCRIPT}</td>
		</tr>
		<tr>
			<th>Command start date :</th>
			<td>{COMMAND_START_DATE}</td>
		</tr>
		<tr>
			<th>Command expiry date :</th>
			<td>{COMMAND_END_DATE}</td>
		</tr>
	</table>

	
	<p>Transferred files list :</p>
	{files_list}

	<p>Command actions history list : {COMMAND_HOSTNAME}</p>
	{command_on_host_history}
</div> <!-- COMMAND DETAIL -->

