<input 
	type="hidden"
	name="repository_path_destination"					
	value="{REPOSITORY_PATH_DESTINATION}"
/>
<!-- BEGIN REPOSITORY_CREATE_DIRECTORY_CHECKED --><!-- checked="checked" --><!-- END REPOSITORY_CREATE_DIRECTORY_CHECKED -->
<input
	type="hidden"
	name="repository_create_directory"
	value="1"
/>
<!-- BEGIN REPOSITORY_START_SCRIPT_CHECKED --><!-- checked="checked" --><!-- END REPOSITORY_START_SCRIPT_CHECKED -->
<input 
	type="hidden"
	name="repository_start_script"
	value="1"
/>

<div id="lsc-repository-actions"> <!-- REPOSITORY ACTIONS -->
	<!-- BEGIN ACTION_ON_HOST -->
	<h3 class="box-title">Actions sur le poste client <strong>"{REPOSITORY_ACTION_HOSTNAME}"</strong> :</h3>
	<!-- END ACTION_ON_HOST -->
	<!-- BEGIN ACTION_GROUP_ONLY -->
	<h3 class="box-title">Actions sur le groupe de postes clients qui appartiennent au groupe <strong>"{GROUP_NAME}"</strong> :</h3>
	<!-- END ACTION_GROUP_ONLY -->
	<!-- BEGIN ACTION_PROFILE_ONLY -->
	<h3 class="box-title">Actions sur le groupe de postes clients qui appartiennent au profil <strong>"{PROFILE_NAME}"</strong> :</h3>
	<!-- END ACTION_PROFILE_ONLY -->
	<!-- BEGIN ACTION_GROUP_AND_PROFILE -->
	<h3 class="box-title">Actions sur le groupe de postes clients <strong>"{GROUP_NAME}"</strong> du profil <strong>"{PROFILE_NAME}"</strong> :</h3>
	<!-- END ACTION_GROUP_AND_PROFILE -->
	<div class="box">
		<table class="form" style="width:100%">
		<tr><td>
			<table style="width:100%">
			<tr>
			<td style="width:5px;"><div style="white-space:nowrap;">Description de l'action :</div></td><td>
			<input
				type="text"
				name="repository_command_title"
				value="{REPOSITORY_COMMAND_TITLE}"
				style="width:100%";
			/>
			<!-- <em style="font-size:x-small">(exemple : "Installation d'Open Office")</em>-->
			</td>
			</tr>
			</table>
		</td></tr>
		<tr><td>
			<table style="width:100%">
			<tr>
			<td style="width:5px;"><div style="white-space:nowrap;">Date de d&eacute;marrage de la commande :</div></td><td>
			<input
				type="text"
				name="repository_start_date"
				id="repository_start_date"
				size="20"
				value="d&egrave;s que possible"
				readonly="readonly"
			/>
			<input 
				type="image"
				src="images/calendar.gif"
				id="repository_start_date_button"
			/></td><td>
			ou <a href="javascript:;" onclick="javascript:document.getElementById('repository_start_date').value='d?s que possible';">d&egrave;s que possible</a>
			</td>
			</tr>
			<tr>
			<td style="width:5px;"><div style="white-space:nowrap;">Date limite d'ex&eacute;cution de la commande :</div></td><td>
			<input
				type="text"
				name="repository_end_date"
				id="repository_end_date"
				size="20"
				readonly="readonly"
				value="aucune"
			/>
			<input 
				type="image"
				src="images/calendar.gif"
				id="repository_end_date_button"
			/></td><td>
			ou <a href="javascript:;" onclick="javascript:document.getElementById('repository_end_date').value='aucune';">aucune</a>
			</td>
			</tr>
			<tr>
			<td style="width:5px;white-space:nowrap;">R&eacute;p&eacute;tition :</td><td>
				<select name="repeat">
				<option value="0">Aucune</option>
				<option value="1">Chaque heure</option>
				<option value="24">Chaque jour</option>
				<option value="168">Chaque semaine</option>
				</select>
			</td>
			</tr>

			</table>
		</td></tr>
		<tr><td>
			<table style="width:100%">
			<tr>
			<td style="width:5px;"><div style="white-space:nowrap;">Passer les param&ecirc;tres suivants au fichier &agrave; ex&eacute;cuter :</div></td><td>
			<input 
				type="text"
				name="repository_parameters"
				value=""
				style="width:100%";
			/>
			</td>
			</tr>
			</table>
		</td></tr>
		<tr>
			<td>
			<input 
				<!-- BEGIN REPOSITORY_DELETE_FILES_CHECKED -->checked="checked"<!-- END REPOSITORY_DELETE_FILES_CHECKED -->
				type="checkbox"
				name="repository_delete_file_after_execute_successful"
				value="1"
				style="border:none;"
			/>
			Supprimer les fichiers apr&egrave;s ex&eacute;cution avec succ&egrave;s
			</td>
		</tr>
		<tr>
			<td>
			<input 
				<!-- BEGIN REPOSITORY_INVENTORY_CHECKED -->checked="checked"<!-- END REPOSITORY_INVENTORY_CHECKED -->
				type="checkbox"
				name="repository_inventory"
				value="1"
				style="border:none;"
			/>
			Lancer l'agent d'inventaire apr&egrave;s l'ex&eacute;cution de la commande
			</td>
		</tr>
		<tr>
			<td>
			<input 
				<!-- BEGIN REPOSITORY_WAKE_ON_LAN_CHECKED -->checked="checked"<!-- END REPOSITORY_WAKE_ON_LAN_CHECKED -->
				type="checkbox"
				name="repository_wake_on_lan"
				value="1"
				style="border:none;"
			/>
			Si un poste client n'est pas accessible &eacute;mettre une requ&ecirc;te "Wake On Lan"
			</td>
		</tr>
		<tr>
			<td>
			Nombre maximal de tentatives de connexion :
			<input 
				type="text"
				name="repository_max_connection_attempt"
				value="{MAX_CONNECTION_ATTEMPT}"
				size="3"
			/>.
			D&eacute;lai entre deux tentatives de connexion :
			<input 
				type="text"
				name="repository_next_connection_delay"
				value="{NEXT_CONNECTION_DELAY}"
				size="5"
			/>
			minutes
			</td>
		</tr>
		<tr>
			<td>Syst&egrave;me d'exploitation: {OS}
			</td>
		</tr>
		<tr>
			<td>
			<div style="text-align:center">
			<input 
				type="submit" 
				name="repository_launch_action"
				value="Lancer l'action" 
			/>
			</div>
			</td>
		</tr>
		</table>
	</div>
</div> <!-- REPOSITORY ACTIONS -->
