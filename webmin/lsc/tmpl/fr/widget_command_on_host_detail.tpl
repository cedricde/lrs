<div id="lsc-command-on-host-detail"> <!-- COMMAND ON HOST DETAIL -->
	<p>�tat de la commande :</p>
	<table>
	<thead>
		<tr>
			<th>�tat courrant</th>
			<th>�tat du transfert</th>
			<th>�tat de l'ex�cution</th>
			<th>�tat de la suppression</th>
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

	<p>Description de la commande :</p>
	<table>
		<tr>
			<th>Nom de la machine</th>
			<td>{COMMAND_HOSTNAME}</td>
		</tr>
		<tr>
			<th>Date de cr�ation :</th>
			<td>{COMMAND_DATE_CREATED}</td>
		</tr>
		<tr>
			<th>Fichier � ex�cuter :</th>
			<td>{COMMAND_START_FILE}</td>
		</tr>
		<tr>
			<th>Param�tre � passer au fichier ex�cutable :</th>
			<td>{COMMAND_PARAMETERS}</td>
		</tr>
		<tr>
			<th>R�pertoire destination :</th>
			<td>{COMMAND_PATH_DESTINATION}</td>
		</tr>
		<tr>
			<th>R�pertoire source du d�pot de fichiers :</th>
			<td>{COMMAND_PATH_SOURCE}</td>
		</tr>
		<tr>
			<th>Cr�ation du r�pertoire destination :</th>
			<td>{COMMAND_CREATE_DIRECTORY}</td>
		</tr>
		<tr>
			<th>Lancement du script :</th>
			<td>{COMMAND_START_SCRIPT}</td>
		</tr>
		<tr>
			<th>Date de d�marrage de la commande :</th>
			<td>{COMMAND_START_DATE}</td>
		</tr>
		<tr>
			<th>Date d'expiration de la commande :</th>
			<td>{COMMAND_END_DATE}</td>
		</tr>
	</table>

	
	<p>Liste des fichiers � copier :</p>
	{files_list}

	<p>Historique de la commande sur la machine : {COMMAND_HOSTNAME}</p>
	{command_on_host_history}
</div> <!-- COMMAND DETAIL -->

