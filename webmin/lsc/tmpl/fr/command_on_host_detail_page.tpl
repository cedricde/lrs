<style type="text/css">
	@import url("css/lsc2.css");
</style>
{where_I_m_connected}
<div class="lsc">
<!-- BEGIN LOCATION_ALL_COMMANDS -->
<p>> <a href="all_commands.cgi?mac={MAC}&profile={PROFILE}&group={GROUP}">Retour � la liste d'�tat des commandes</a> 
> <a href="all_commands.cgi?mac={MAC}&profile={PROFILE}&group={GROUP}&id_command={ID_COMMAND}">Visualisation de la commande</a></p>
<!-- END LOCATION_ALL_COMMANDS -->
<!-- BEGIN LOCATION_COMMANDS_ON_HOST -->
<p><a href="commands_states.cgi?mac={MAC}&profile={PROFILE}&group={GROUP}">Retour � la liste des commandes du poste "{HOSTNAME}"</a></p>
<!-- END LOCATION_COMMANDS_ON_HOST -->
<!-- BEGIN LOCATION_COMMANDS_ON_HOST_GROUP_MODE -->
<p>> <a href="{SCRIPT_NAME}?mac={MAC}&profile={PROFILE}&group={GROUP}">Retour � la liste d'�tat des commandes</a> > <a href="commands_states.cgi?mac={MAC}&profile={PROFILE}&group={GROUP}&id_command={ID_COMMAND}">Visualisation de la commande "{COMMAND_TITLE}"</a></p>
<!-- END LOCATION_COMMANDS_ON_HOST_GROUP_MODE -->

<h3>Etat de la commande "{COMMAND_TITLE}" sur le poste "{HOSTNAME}"</h3>

<div style="text-align:center">
	<!-- BEGIN BUTTON_PAUSE --><a 
	href="{SCRIPT_NAME}?mac={MAC}&profile={PROFILE}&group={GROUP}&id_command_on_host={ID_COMMAND_ON_HOST}&id_command_on_host_pause={ID_COMMAND_ON_HOST}&action=pause"
	title="Mettre en pause la commande {COMMAND_TITLE} sur le poste client {HOSTNAME}"
	><img src="images/stock_media-pause.png" /></a><!-- END BUTTON_PAUSE -->
	<!-- BEGIN BUTTON_PLAY --><a 
	href="{SCRIPT_NAME}?mac={MAC}&profile={PROFILE}&group={GROUP}&id_command_on_host={ID_COMMAND_ON_HOST}&id_command_on_host_play={ID_COMMAND_ON_HOST}&action=play"
	title="Red�marrer la commande {COMMAND_TITLE} sur le poste client {HOSTNAME}"
	><img src="images/stock_media-play.png" /></a><!-- END BUTTON_PLAY -->
	<!-- BEGIN BUTTON_STOP --><a
	href="{SCRIPT_NAME}?mac={MAC}&profile={PROFILE}&group={GROUP}&id_command_on_host={ID_COMMAND_ON_HOST}&id_command_on_host_stop={ID_COMMAND_ON_HOST}&action=stop"
	title="Stopper la commande {COMMAND_TITLE} sur le poste client {HOSTNAME}"
	><img src="images/stock_media-stop.png " /></a><!-- END BUTTON_STOP -->
</div>

<div style="text-align:center">
	<p><img src="images/{CURRENT_STATE_ICON}" /> {CURRENT_STATE}</p>
</div>
<hr style="width:10%;" />
<div style="text-align:center">
	<p><img src="images/{UPLOADED_ICON}" /> Transfert {UPLOADED}</p>
	<p><img src="images/{EXECUTED_ICON}" /> Ex�cution {EXECUTED}</p>
	<p><img src="images/{DELETED_ICON}" /> Suppression {DELETED}</p>
</div>

<h3>D�tail de la commande : "{COMMAND_TITLE}"</h3>

<table class="table-vertical" style="line-height:2em;">
	<tr class="row-odd">
		<th style="text-align:right;">Date de cr�ation :</th>
		<td>{COMMAND_DATE_CREATED}</td>
	</tr>
	<tr class="row-even">
		<th style="text-align:right;">Utilisateur qui a lanc� la commande :</th>
		<td>{COMMAND_WEBMIN_USER}</td>
	</tr>
	<tr class="row-odd">
		<th style="text-align:right;">Fichier � ex�cuter :</th>
		<td>{COMMAND_START_FILE}</td>
	</tr>
	<tr class="row-even">
		<th style="text-align:right;">Param�tre � passer au fichier ex�cutable :</th>
		<td>{COMMAND_PARAMETERS}</td>
	</tr>
	<tr class="row-odd">
		<th style="text-align:right;">R�pertoire destination :</th>
		<td>{COMMAND_PATH_DESTINATION}</td>
	</tr>
	<tr class="row-even">
		<th style="text-align:right;">R�pertoire source du d�pot de fichiers :</th>
		<td>{COMMAND_PATH_SOURCE}</td>
	</tr>
	<tr class="row-odd">
		<th style="text-align:right;">Cr�ation du r�pertoire destination :</th>
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
		<th style="text-align:right;">Lancement d'une requ�te "Wake On Lan" <br />si la connexion est impossible :</th>
		<td>{COMMAND_WAKE_ON_LAN}</td>
	</tr>
	<tr class="row-odd">
		<th style="text-align:right;">Nombre de tentatives de connexion :</th>
		<td>{COMMAND_MAX_CONNECTION_ATTEMPT}</td>
	</tr>
	<tr class="row-even">
		<th style="text-align:right;">D�lai entre deux tentatives de connexion :</th>
		<td>{COMMAND_NEXT_CONNECTION_DELAY}</td>
	</tr>
	<tr class="row-odd">
		<th style="text-align:right;">Date de d�marrage de la commande :</th>
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
	
<h3>Liste des fichiers � copier :</h3>

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
Aucun fichier � copier.
<!-- END FILES_LIST_EMPTY -->

<h3>Liste des actions effectu�es par cette commande :</h3>

<!-- BEGIN HISTORY_LIST_ROW -->
<h4><img src="images/{HISTORY_LIST_ICON}"> {HISTORY_LIST_DATE} : {HISTORY_LIST_STATE}</h4>

<table class="table-clean">
	<tr>
		<td style="width:12em;text-align:right">Sortie standard :</td>
		<td>{HISTORY_LIST_STDOUT}</td>
	</tr>
	<tr>
		<td style="width:12em;text-align:right">Sortie d'erreur :</td>
		<td>{HISTORY_LIST_STDERR}</td>
	</tr>
</table>

<!-- END HISTORY_LIST_ROW -->
<!-- BEGIN HISTORY_LIST_EMPTY -->
<p>Cette commande n'a effectu� aucune action.</p>
<!-- END HISTORY_LIST_EMPTY -->
</div>
<a name="bottom"></a>
