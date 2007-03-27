<div id="lsc-commands-states-list">
	<!-- BEGIN COMMANDS_STATES_LIST -->
	<div style="border: 1px solid #FF3300;padding:0;margin:0;">
	<table>
		<thead>
			<tr>
				<th class="target-column">Target</th>
				<th class="number-of-host">Number of<br />host</th>
				<th class="title-column">Command<br />title</th>
				<th class="date-created-column">Command create<br />date</th>
				<th class="start-date-column">Start<br />date</th>
				<th class="end-date-column">Expire<br />date</th>
				<th class="current-states-column">State</th>
				<!-- <th class="number-attempt-column">Nombre de<br /> tentatives</th> -->
				<th class="actions-column">Actions</th>
			</tr>
		</thead>
		<tbody>
			<!-- BEGIN COMMANDS_STATES_ROW -->
			<tr class="{ROW_CLASS}">
				<td class="target-column">{TARGET}</td>
				<td class="number-of-host-column">{NUMBER_OF_HOST}</td>
				<td class="title-column">{TITLE}</td>
				<td class="date-created-column">{DATE_CREATED}</td>
				<td class="start-date-column">{START_DATE}</td>
				<td class="end-date-column">{END_DATE}</td>
				<td class="current-states-column">{CURRENT_STATES}</td>
				<!-- <td class="number-attempt-column">{NUMBER_ATTEMPT}</td> -->
				<td class="actions-column">
					<a href="command_detail.cgi?mac={MAC}&profile={PROFILE}&group={GROUP}&id_command={ID_COMMAND}">View command detail</a>
				</td>
			</tr>
			<!-- END COMMANDS_STATES_ROW -->
		</tbody>
	</table>
	</div>
	<!-- END COMMANDS_STATES_LIST -->
	<!-- BEGIN COMMANDS_STATES_LIST_EMPTY -->
	No tasks scheduled, started or done.
	<!-- END COMMANDS_STATES_LIST_EMPTY -->
</div>
