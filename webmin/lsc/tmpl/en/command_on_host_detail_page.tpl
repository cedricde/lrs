<style type="text/css">
	@import url("css/lsc2.css");
</style>
{where_I_m_connected}
<div class="lsc">
<!-- BEGIN LOCATION_ALL_COMMANDS -->
<p>> <a href="all_commands.cgi?mac={MAC}&profile={PROFILE}&group={GROUP}">Return to commands states list page</a> 
> <a href="all_commands.cgi?mac={MAC}&profile={PROFILE}&group={GROUP}&id_command={ID_COMMAND}">Command view</a></p>
<!-- END LOCATION_ALL_COMMANDS -->
<!-- BEGIN LOCATION_COMMANDS_ON_HOST -->
<p><a href="commands_states.cgi?mac={MAC}&profile={PROFILE}&group={GROUP}">Return to "{HOSTNAME}" commands states list page</a></p>
<!-- END LOCATION_COMMANDS_ON_HOST -->
<!-- BEGIN LOCATION_COMMANDS_ON_HOST_GROUP_MODE -->
<p>> <a href="{SCRIPT_NAME}?mac={MAC}&profile={PROFILE}&group={GROUP}">Return to commands states list page</a> > <a href="commands_states.cgi?mac={MAC}&profile={PROFILE}&group={GROUP}&id_command={ID_COMMAND}">Command "{COMMAND_TITLE}" view</a></p>
<!-- END LOCATION_COMMANDS_ON_HOST_GROUP_MODE -->

<h3>Command state "{COMMAND_TITLE}" on "{HOSTNAME}"</h3>

<div style="text-align:center">
	<!-- BEGIN BUTTON_PAUSE --><a 
	href="{SCRIPT_NAME}?mac={MAC}&profile={PROFILE}&group={GROUP}&id_command_on_host={ID_COMMAND_ON_HOST}&id_command_on_host_pause={ID_COMMAND_ON_HOST}&action=pause"
	title="Pause {COMMAND_TITLE} command on {HOSTNAME}"
	><img src="images/stock_media-pause.png" /></a><!-- END BUTTON_PAUSE -->
	<!-- BEGIN BUTTON_PLAY --><a 
	href="{SCRIPT_NAME}?mac={MAC}&profile={PROFILE}&group={GROUP}&id_command_on_host={ID_COMMAND_ON_HOST}&id_command_on_host_play={ID_COMMAND_ON_HOST}&action=play"
	title="Start {COMMAND_TITLE} command on {HOSTNAME}"
	><img src="images/stock_media-play.png" /></a><!-- END BUTTON_PLAY -->
	<!-- BEGIN BUTTON_STOP --><a
	href="{SCRIPT_NAME}?mac={MAC}&profile={PROFILE}&group={GROUP}&id_command_on_host={ID_COMMAND_ON_HOST}&id_command_on_host_stop={ID_COMMAND_ON_HOST}&action=stop"
	title="Stop {COMMAND_TITLE} command on {HOSTNAME}"
	><img src="images/stock_media-stop.png " /></a><!-- END BUTTON_STOP -->
</div>

<div style="text-align:center">
	<p><img src="images/{CURRENT_STATE_ICON}" /> {CURRENT_STATE}</p>
</div>
<hr style="width:10%;" />
<div style="text-align:center">
	<p><img src="images/{UPLOADED_ICON}" /> Upload {UPLOADED}</p>
	<p><img src="images/{EXECUTED_ICON}" /> Execute {EXECUTED}</p>
	<p><img src="images/{DELETED_ICON}" /> Delete {DELETED}</p>
</div>

<h3>"{COMMAND_TITLE}" command detail</h3>

<table class="table-vertical" style="line-height:2em;">
	<tr class="row-even">
		<th style="text-align:right;">Command target :</th>
		<td>{COMMAND_TARGET}</td>
	</tr>
	<tr class="row-odd">
		<th style="text-align:right;">Creation date :</th>
		<td>{COMMAND_DATE_CREATED}</td>
	</tr>
	<tr class="row-even">
		<th style="text-align:right;">User command creator :</th>
		<td>{COMMAND_WEBMIN_USER}</td>
	</tr>
	<tr class="row-odd">
		<th style="text-align:right;">Execute file :</th>
		<td>{COMMAND_START_FILE}</td>
	</tr>
	<tr class="row-even">
		<th style="text-align:right;">Execution arguments :</th>
		<td>{COMMAND_PARAMETERS}</td>
	</tr>
	<tr class="row-odd">
		<th style="text-align:right;">Destination directory :</th>
		<td>{COMMAND_PATH_DESTINATION}</td>
	</tr>
	<tr class="row-even">
		<th style="text-align:right;">Source directory (repository) :</th>
		<td>{COMMAND_PATH_SOURCE}</td>
	</tr>
	<tr class="row-odd">
		<th style="text-align:right;">Create destination directory :</th>
		<td>{COMMAND_CREATE_DIRECTORY}</td>
	</tr>
	<tr class="row-even">
		<th style="text-align:right;">Start execute file :</th>
		<td>{COMMAND_START_SCRIPT}</td>
	</tr>
	<tr class="row-odd">
		<th style="text-align:right;">Start inventory agent :</th>
		<td>{COMMAND_START_INVENTORY}</td>
	</tr>
	<tr class="row-even">
		<th style="text-align:right;">Start "Wake On Lan" query<br />if connection fails:</th>
		<td>{COMMAND_WAKE_ON_LAN}</td>
	</tr>
	<tr class="row-odd">
		<th style="text-align:right;">Remaining attempts :</th>
		<td>{ATTEMPTS}/{COMMAND_MAX_CONNECTION_ATTEMPT}</td>
	</tr>
	<tr class="row-even">
		<th style="text-align:right;">Delay between two connections :</th>
		<td>{COMMAND_NEXT_CONNECTION_DELAY}</td>
	</tr>
	<tr class="row-odd">
		<th style="text-align:right;">Command start date :</th>
		<td>{COMMAND_START_DATE}</td>
	</tr>
	<tr class="row-even">
		<th style="text-align:right;">Command expiry date :</th>
		<td>{COMMAND_END_DATE}</td>
	</tr>
	<tr class="row-odd">
		<th style="text-align:right;">Command next run date :</th>
		<td>{COMMAND_RUN_DATE}</td>
	</tr>
</table>
	
<h3>Transferred files list :</h3>

<!-- BEGIN FILES_LIST_SECTION -->
<table class="table-horizontal">
<thead>
	<tr>
		<th style="width:3em;"></th>
		<th>File name</th>
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
<p>Transferred files list empty.</p>
<!-- END FILES_LIST_EMPTY -->

<h3>Command actions history list :</h3>

<!-- BEGIN HISTORY_LIST_ROW -->
<h4><img src="images/{HISTORY_LIST_ICON}"> {HISTORY_LIST_DATE} : {HISTORY_LIST_STATE}</h4>

<table class="table-clean">
	<tr>
		<td style="width:12em;text-align:right">Standard output :</td>
		<td>{HISTORY_LIST_STDOUT}</td>
	</tr>
	<tr>
		<td style="width:12em;text-align:right">Error output :</td>
		<td>{HISTORY_LIST_STDERR}</td>
	</tr>
</table>

<!-- END HISTORY_LIST_ROW -->
<!-- BEGIN HISTORY_LIST_EMPTY -->
<p>No tasks completed</p>
<!-- END HISTORY_LIST_EMPTY -->
</div>
<a name="bottom"></a>
