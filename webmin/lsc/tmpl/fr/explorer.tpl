<style type="text/css">
	@import url("css/lsc_main.css");
</style>
{where_I_m_connected}

<div class="lsc">
<h2>Explorateur de fichiers</h2>

{action_message}

<table style="border:0;width:100%;">
	<tr>
	<td style="width:18em;vertical-align:bottom">
		<h3 class="box-title">Arborescence du 
		<span style="white-space:nowrap;">poste client 
		<strong>"{WHERE_I_M_CONNECTED_HOSTNAME}"</strong> :</span></h3>
	</td>
	<td style="vertical-align:bottom">
		<h3 class="box-title">Liste des fichiers du répertoire 
		<strong>"{CURRENT_DIRECTORY_PATH}"</strong> :</h3>
	</td>
	</tr>
	<tr>
	<td style="vertical-align:top">{tree}</td>
	<td style="vertical-align:top">
		<form 
			method="post" 
			action="{SCRIPT_NAME}?mac={MAC}&process=1" 
			enctype="multipart/form-data"
		>
			<input 
				type="hidden" 
				name="MAX_FILE_SIZE" 
				value="300000000" 
			/>
			{file_list_directory}
			<!-- BEGIN FILE_LIST_DIRECTORY_EMPTY -->
			<p><i>Le répertoire ne contient aucun fichier</i></p>
			<!-- END FILE_LIST_DIRECTORY_EMPTY -->
			<div style="height:1em"></div>
			{standard_file_list_directory_actions}
			<div style="height:1em"></div>
		</form>
	</td>
</table>
</div> <!-- lsc -->
