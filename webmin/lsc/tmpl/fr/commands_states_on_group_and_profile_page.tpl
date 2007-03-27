<style type="text/css">
	@import url("css/lsc2.css");
</style>
{where_I_m_connected}

<h2>Etat des commandes sur le groupe de machine "{GROUP_AND_PROFILE}"</h2>
<form name="form" method="post" action="{SCRIPT_NAME}?mac={MAC}&profile={PROFILE}&group={GROUP}">
<div style="height:4em;">
<table style="float:right">
	<tr>
		<td>
			<select name="number_command_by_page">
				<option 
					value="10"
					<!-- BEGIN NUMBER_BY_PAGE_10_SELECTED -->selected="selected"<!-- END NUMBER_BY_PAGE_10_SELECTED -->
				>Afficher 10 commandes par page</option>
				<option value="20"
					<!-- BEGIN NUMBER_BY_PAGE_20_SELECTED -->selected="selected"<!-- END NUMBER_BY_PAGE_20_SELECTED -->
				>Afficher 20 commandes par page</option>
				<option value="50"
					<!-- BEGIN NUMBER_BY_PAGE_50_SELECTED -->selected="selected"<!-- END NUMBER_BY_PAGE_50_SELECTED -->
				>Afficher 50 commandes par page</option>
				<option value="100"
					<!-- BEGIN NUMBER_BY_PAGE_100_SELECTED -->selected="selected"<!-- END NUMBER_BY_PAGE_100_SELECTED -->
				>Afficher 100 commandes par page</option>
			</select>
			<input 
				type="image"
				src="images/button_ok.png"
				name="apply_filter_submit"
				value="Appliquer"
				style="vertical-align:bottom"
			/>
		</td>
	</tr>
</table>
</div>

<!-- BEGIN LIST_PAGES -->
<div style="text-align:center;margin-top:1em;margin-bottom:1em;">
	Pages : 
	<!-- BEGIN PAGE_PREVIOUS_HIDE -->
	<a href="{SCRIPT_NAME}?mac={MAC}&profile={PROFILE}&group={GROUP}&page={PAGE_PREVIOUS}"><img title="Page précédente" src="images/previous.png" /></a>
	<!-- END PAGE_PREVIOUS_HIDE -->
	
	<!-- BEGIN LIST_PAGE_COL -->
	<!-- BEGIN PAGE_LINK --><a href="{SCRIPT_NAME}?mac={MAC}&profile={PROFILE}&group={GROUP}&page={PAGE_NUMBER}">{PAGE_LABEL}</a><!-- END PAGE_LINK -->
	<!-- BEGIN PAGE_CURRENT -->{PAGE_LABEL}<!-- END PAGE_CURRENT -->
	<!-- END LIST_PAGE_COL -->

	<!-- BEGIN PAGE_NEXT_HIDE -->
	<a href="{SCRIPT_NAME}?mac={MAC}&profile={PROFILE}&group={GROUP}&page={PAGE_NEXT}"><img title="Page suivante" src="images/next.png" /></a>
	<!-- END PAGE_NEXT_HIDE -->
</div>
<!-- END LIST_PAGES -->

<div id="lsc-commands-states-list">
	<!-- BEGIN COMMANDS_STATES_LIST -->
	<table class="table-horizontal" style="width:100%;">
		<thead>
			<tr>
				<th class="center-column">Titre de<br />la commande</th>
				<th class="center-column">Nombre<br />de<br />postes</th>
				<th class="center-column">Date de création<br />de la commande</th>
				<th class="center-column">Date de<br />lancement</th>
				<th class="center-column">Date d'expiration<br />du lancement</th>
				<th class="center-column" colspan="2">Etat</th>
				<!-- <th class="number-attempt-column">Nombre de<br /> tentatives</th> -->
				<th class="center-column" colspan="3">Actions</th>
			</tr>
		</thead>
		<tbody>                                      
			<!-- BEGIN COMMANDS_STATES_ROW -->
			<tr class="{ROW_CLASS}">
				<td class="center-column">{TITLE}</td>
				<td class="center-column">{NUMBER_OF_HOST}</td>
				<td class="center-column">{DATE_CREATED}</td>
				<td class="center-column">{START_DATE}</td>
				<td class="center-column">{END_DATE}</td>
				<td class="center-column">
					<img src="images/{CURRENT_STATES_ICON}" />
				</td>
				<td class="center-column">
					{CURRENT_STATES}
				</td>
				<td class="center-column">
					<a href="{SCRIPT_NAME}?mac={MAC}&profile={PROFILE}&group={GROUP}&id_command={ID_COMMAND}"><img title="Détail de la commande {TITLE}" src="images/detail.gif" /></a>
				</td>
				<td class="center-column">
					<!-- BEGIN BUTTON_PAUSE --><a 
						href="{SCRIPT_NAME}?mac={MAC}&profile={PROFILE}&group={GROUP}&id_command_pause={ID_COMMAND}&action=pause"
						title="Mettre en pause la commande {TITLE}"
						><img src="images/stock_media-pause.png" /></a><!-- END BUTTON_PAUSE -->
					<!-- BEGIN BUTTON_PLAY --><a 
						href="{SCRIPT_NAME}?mac={MAC}&profile={PROFILE}&group={GROUP}&id_command_play={ID_COMMAND}&action=play"
						title="Redémarrer la commande {TITLE}"
					><img src="images/stock_media-play.png" /></a><!-- END BUTTON_PLAY -->
				</td><td class="center-column">
					<!-- BEGIN BUTTON_STOP --><a
						href="{SCRIPT_NAME}?mac={MAC}&profile={PROFILE}&group={GROUP}&id_command_stop={ID_COMMAND}&action=stop"
						title="Stopper la commande {TITLE}"
					><img src="images/stock_media-stop.png " /></a><!-- END BUTTON_STOP -->
				</td>
			</tr>
			<!-- END COMMANDS_STATES_ROW -->
		</tbody>
	</table>
	<!-- END COMMANDS_STATES_LIST -->
	<!-- BEGIN COMMANDS_STATES_LIST_EMPTY -->
	Aucune commande planifiée, en cours d'exécution ou terminée.
	<!-- END COMMANDS_STATES_LIST_EMPTY -->
</div>
<br />
