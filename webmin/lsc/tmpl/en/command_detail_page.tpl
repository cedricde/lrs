<style type="text/css">
	@import url("css/lsc2.css");
</style>
{where_I_m_connected}
<div class="lsc">
<p>> <a href="{SCRIPT_NAME}?mac={MAC}&profile={PROFILE}&group={GROUP}">Return to commands states list page</a></p>


<h3>This command apply on these hosts :</h3>

<table class="table-horizontal" style="width:100%">
<thead>
	<tr>
		<th>Host name</th>
		<th>State</th>
		<th>Upload</th>
		<th>Execution</th>
		<th>Delete</th>
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
		<td><a href="{SCRIPT_NAME}?mac={MAC}&profile={PROFILE}&group={GROUP}&id_command_on_host={HOST_LIST_ID_COMMAND_ON_HOST}"><img title="Show command {COMMAND_TITLE} on {HOST_LIST_HOSTNAME} detail" src="images/detail.gif" /></a></td>
		<td class="center-column">
			<!-- BEGIN BUTTON_PAUSE --><a 
			href="{SCRIPT_NAME}?mac={MAC}&profile={PROFILE}&group={GROUP}&id_command={ID_COMMAND}&id_command_on_host_pause={HOST_LIST_ID_COMMAND_ON_HOST}&action=pause"
			title="Pause command {COMMAND_TITLE} on {HOST_LIST_HOSTNAME}"
			><img src="images/stock_media-pause.png" /></a><!-- END BUTTON_PAUSE -->
			<!-- BEGIN BUTTON_PLAY --><a 
			href="{SCRIPT_NAME}?mac={MAC}&profile={PROFILE}&group={GROUP}&id_command={ID_COMMAND}&id_command_on_host_play={HOST_LIST_ID_COMMAND_ON_HOST}&action=play"
			title="Start command {COMMAND_TITLE} on {HOST_LIST_HOSTNAME}"
			><img src="images/stock_media-play.png" /></a><!-- END BUTTON_PLAY -->
		</td><td class="center-column">
			<!-- BEGIN BUTTON_STOP --><a
			href="{SCRIPT_NAME}?mac={MAC}&profile={PROFILE}&group={GROUP}&id_command={ID_COMMAND}&id_command_on_host_stop={HOST_LIST_ID_COMMAND_ON_HOST}&action=stop"
			title="Stop command \"{COMMAND_TITLE}\" on \"{HOST_LIST_HOSTNAME}\""
			><img src="images/stock_media-stop.png " /></a><!-- END BUTTON_STOP -->
		</td>
	</tr>
	<!-- END HOSTS_LIST_ROW -->
</tbody>
</table>

<h3>"{COMMAND_TITLE}" task detail</h3>
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
		<th style="text-align:right;">Start "Wake On Lan" query<br />if connection fails :</th>
		<td>{COMMAND_WAKE_ON_LAN}</td>
	</tr>
	<tr class="row-odd">
		<th style="text-align:right;">Number of attempt :</th>
		<td>{COMMAND_MAX_CONNECTION_ATTEMPT}</td>
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
</div>
