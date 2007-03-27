<div id="lsc-commands-states-list">
	<!-- BEGIN COMMANDS_STATES_LIST -->
	<div style="border: 1px solid #FF3300;padding:0;margin:0;">
	<table>
		<thead>
			<tr>
				<th class="target-column">Cible</th>
				<th class="number-of-host">Nombre de<br /> machines</th>
				<th class="title-column">Titre de<br />la commande</th>
				<th class="date-created-column">Date de création<br /> de la commande</th>
				<th class="start-date-column">Date de<br /> lancement</th>
				<th class="end-date-column">Date d'expiration<br /> du lancement</th>
				<th class="current-states-column">Etat</th>
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
					<a href="command_detail.cgi?mac={MAC}&profile={PROFILE}&group={GROUP}&id_command={ID_COMMAND}">Voir le détail de la commande</a>
				</td>
			</tr>
			<!-- END COMMANDS_STATES_ROW -->
		</tbody>
	</table>
	</div>
	<!-- END COMMANDS_STATES_LIST -->
	<!-- BEGIN COMMANDS_STATES_LIST_EMPTY -->
	Aucune commande planifié, en cours d'exécution ou terminé.
	<!-- END COMMANDS_STATES_LIST_EMPTY -->
</div>
