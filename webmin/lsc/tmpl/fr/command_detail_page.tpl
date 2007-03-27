<style type="text/css">
	@import url("css/lsc2.css");
</style>
{where_I_m_connected}
<div class="lsc">
<p>> <a href="{SCRIPT_NAME}?mac={MAC}&profile={PROFILE}&group={GROUP}">Retour à la liste d'état des commandes</a></p>


<h3>Cette commande est appliquée sur les postes clients suivants :</h3>

<table class="table-horizontal" style="width:100%">
<thead>
	<tr>
		<th>Nom du poste client</th>
		<th>Etat</th>
		<th>Transfert</th>
		<th>Exécution</th>
		<th>Suppression</th>
		<th colspan="3" style="width:5em;">Actions</th>
	</tr>
</thead>
<tbody>
	<!-- BEGIN HOSTS_LIST_ROW -->
	<tr class={ROW_CLASS}>
		<td class="center-column">{HOST_LIST_HOSTNAME}</td>
		<td class="center-column">{HOST_LIST_CURRENT_STATE}</td>
		<td class="center-column"><img src="images/{HOST_LIST_UPLOADED_ICON}" /> {HOST_LIST_UPLOADED}</td>
		<td class="center-column"><img src="images/{HOST_LIST_EXECUTED_ICON}" /> {HOST_LIST_EXECUTED}</td>
		<td class="center-column"><img src="images/{HOST_LIST_DELETED_ICON}" /> {HOST_LIST_DELETED}</td>
		<td><a href="{SCRIPT_NAME}?mac={MAC}&profile={PROFILE}&group={GROUP}&id_command_on_host={HOST_LIST_ID_COMMAND_ON_HOST}"><img title="Voir le détail de la commande {COMMAND_TITLE} sur le poste client {HOST_LIST_HOSTNAME}" src="images/detail.gif" /></a></td>
		<td class="center-column">
			<!-- BEGIN BUTTON_PAUSE --><a 
			href="{SCRIPT_NAME}?mac={MAC}&profile={PROFILE}&group={GROUP}&id_command={ID_COMMAND}&id_command_on_host_pause={HOST_LIST_ID_COMMAND_ON_HOST}&action=pause"
			title="Mettre pause la commande {COMMAND_TITLE} sur le poste client {HOST_LIST_HOSTNAME}"
			><img src="images/stock_media-pause.png" /></a><!-- END BUTTON_PAUSE -->
			<!-- BEGIN BUTTON_PLAY --><a 
			href="{SCRIPT_NAME}?mac={MAC}&profile={PROFILE}&group={GROUP}&id_command={ID_COMMAND}&id_command_on_host_play={HOST_LIST_ID_COMMAND_ON_HOST}&action=play"
			title="Relancer la commande {COMMAND_TITLE} sur le poste client {HOST_LIST_HOSTNAME}"
			><img src="images/stock_media-play.png" /></a><!-- END BUTTON_PLAY -->
		</td><td class="center-column">
			<!-- BEGIN BUTTON_STOP --><a
			href="{SCRIPT_NAME}?mac={MAC}&profile={PROFILE}&group={GROUP}&id_command={ID_COMMAND}&id_command_on_host_stop={HOST_LIST_ID_COMMAND_ON_HOST}&action=stop"
			title="Stopper la commande \"{COMMAND_TITLE}\" sur le poste client \"{HOST_LIST_HOSTNAME}\""
			><img src="images/stock_media-stop.png " /></a><!-- END BUTTON_STOP -->
		</td>
	</tr>
	<!-- END HOSTS_LIST_ROW -->
</tbody>
</table>

<h3>Détail de la commande : "{COMMAND_TITLE}"</h3>
<table class="table-vertical" style="line-height:2em;">
	<tr class="row-odd">
		<th style="text-align:right;">Date de création :</th>
		<td>{COMMAND_DATE_CREATED}</td>
	</tr>
	<tr class="row-even">
		<th style="text-align:right;">Utilisateur qui a lancé la commande :</th>
		<td>{COMMAND_WEBMIN_USER}</td>
	</tr>
	<tr class="row-odd">
		<th style="text-align:right;">Fichier à exécuter :</th>
		<td>{COMMAND_START_FILE}</td>
	</tr>
	<tr class="row-even">
		<th style="text-align:right;">Paramètre à passer au fichier exécutable :</th>
		<td>{COMMAND_PARAMETERS}</td>
	</tr>
	<tr class="row-odd">
		<th style="text-align:right;">Répertoire destination :</th>
		<td>{COMMAND_PATH_DESTINATION}</td>
	</tr>
	<tr class="row-even">
		<th style="text-align:right;">Répertoire source du dépot de fichiers :</th>
		<td>{COMMAND_PATH_SOURCE}</td>
	</tr>
	<tr class="row-odd">
		<th style="text-align:right;">Création du répertoire destination :</th>
		<td>{COMMAND_CREATE_DIRECTORY}</td>
	</tr>
	<tr class="row-even">
		<th style="text-align:right;">Lancement du script :</th>
		<td>{COMMAND_START_SCRIPT}</td>
	</tr>
	<tr class="row-odd">
		<th style="text-align:right;">Lancement de l'agent d'inventaire :</th>
		<td>{COMMAND_START_INVENTORY}</td>
	</tr>
	<tr class="row-even">
		<th style="text-align:right;">Lancement d'une requête "Wake On Lan" <br />si la connexion est impossible :</th>
		<td>{COMMAND_WAKE_ON_LAN}</td>
	</tr>
	<tr class="row-odd">
		<th style="text-align:right;">Nombre de tentatives de connexion :</th>
		<td>{COMMAND_MAX_CONNECTION_ATTEMPT}</td>
	</tr>
	<tr class="row-even">
		<th style="text-align:right;">Délai entre deux tentatives de connexion :</th>
		<td>{COMMAND_NEXT_CONNECTION_DELAY}</td>
	</tr>
	<tr class="row-odd">
		<th style="text-align:right;">Date de démarrage de la commande :</th>
		<td>{COMMAND_START_DATE}</td>
	</tr>
	<tr class="row-even">
		<th style="text-align:right;">Date d'expiration de la commande :</th>
		<td>{COMMAND_END_DATE}</td>
	</tr>
	<tr class="row-odd">
		<th style="text-align:right;">Destination de la commande :</th>
		<td>{COMMAND_TARGET}</td>
	</tr>
</table>
	
<h3>Liste des fichiers à copier :</h3>

<!-- BEGIN FILES_LIST_SECTION -->
<table class="table-horizontal">
<thead>
	<tr>
		<th style="width:3em;"></th>
		<th>Nom du fichier</th>
	</tr>
</thead>
<tbody>
	<!-- BEGIN FILES_LIST_ROW -->
	<tr class="{ROW_CLASS}">
		<td class="center-column">{FILE_LIST_INDEX}</td>
		<td class="center-column">{FILE_LIST_FILENAME}</td>
	</tr>
	<!-- END FILES_LIST_ROW -->
</tbody>
</table>
<!-- END FILES_LIST_SECTION -->
<!-- BEGIN FILES_LIST_EMPTY -->
Aucun fichier à copier.
<!-- END FILES_LIST_EMPTY -->

</div>
