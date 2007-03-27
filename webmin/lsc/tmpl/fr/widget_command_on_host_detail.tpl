<div id="lsc-command-on-host-detail"> <!-- COMMAND ON HOST DETAIL -->
	<p>État de la commande :</p>
	<table>
	<thead>
		<tr>
			<th>État courrant</th>
			<th>État du transfert</th>
			<th>État de l'exécution</th>
			<th>État de la suppression</th>
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
			<th>Date de création :</th>
			<td>{COMMAND_DATE_CREATED}</td>
		</tr>
		<tr>
			<th>Fichier à exécuter :</th>
			<td>{COMMAND_START_FILE}</td>
		</tr>
		<tr>
			<th>Paramètre à passer au fichier exécutable :</th>
			<td>{COMMAND_PARAMETERS}</td>
		</tr>
		<tr>
			<th>Répertoire destination :</th>
			<td>{COMMAND_PATH_DESTINATION}</td>
		</tr>
		<tr>
			<th>Répertoire source du dépot de fichiers :</th>
			<td>{COMMAND_PATH_SOURCE}</td>
		</tr>
		<tr>
			<th>Création du répertoire destination :</th>
			<td>{COMMAND_CREATE_DIRECTORY}</td>
		</tr>
		<tr>
			<th>Lancement du script :</th>
			<td>{COMMAND_START_SCRIPT}</td>
		</tr>
		<tr>
			<th>Date de démarrage de la commande :</th>
			<td>{COMMAND_START_DATE}</td>
		</tr>
		<tr>
			<th>Date d'expiration de la commande :</th>
			<td>{COMMAND_END_DATE}</td>
		</tr>
	</table>

	
	<p>Liste des fichiers à copier :</p>
	{files_list}

	<p>Historique de la commande sur la machine : {COMMAND_HOSTNAME}</p>
	{command_on_host_history}
</div> <!-- COMMAND DETAIL -->

