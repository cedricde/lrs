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
	<h3 class="box-title">Task options on <strong>"{REPOSITORY_ACTION_HOSTNAME}"</strong> host :</h3>
	<!-- END ACTION_ON_HOST -->
	<!-- BEGIN ACTION_GROUP_ONLY -->
	<h3 class="box-title">Task options on <strong>"{GROUP_NAME}"</strong> group :</h3>
	<!-- END ACTION_GROUP_ONLY -->
	<!-- BEGIN ACTION_PROFILE_ONLY -->
	<h3 class="box-title">Task options on <strong>"{PROFILE_NAME}"</strong> profil :</h3>
	<!-- END ACTION_PROFILE_ONLY -->
	<!-- BEGIN ACTION_GROUP_AND_PROFILE -->
	<h3 class="box-title">Task options on <strong>"{PROFILE_NAME}:{GROUP_NAME}"</strong> group :</h3>
	<!-- END ACTION_GROUP_AND_PROFILE -->
	<div class="box">
		<table class="form" style="width:100%">
		<tr><td>
			<table style="width:100%">
			<tr>
			<td style="width:5px;white-space:nowrap;">Task title :</td><td>
			<input
				type="text"
				name="repository_command_title"
				value="{REPOSITORY_COMMAND_TITLE}"
				style="width:100%";
			/>
			<!-- <em style="font-size:x-small">(example : "Installation d'Open Office")</em>-->
			</td>
			</tr>
			</table>
		</td></tr>
		<tr><td>
			<table style="width:100%">
			<tr>
			<td style="width:5px;white-space:nowrap;">Start date :</td><td>
			<input
				type="text"
				name="repository_start_date"
				id="repository_start_date"
				size="20"
				value="ASAP"
				readonly="readonly"
			/>
			<input 
				type="image"
				src="images/calendar.gif"
				id="repository_start_date_button"
			/>
			or <a href="javascript:;" onclick="javascript:document.getElementById('repository_start_date').value='ASAP';">as soon as possible</a>
			</td>
			</tr>
			<tr>
			<td style="width:5px;white-space:nowrap;">Expiry date :</td><td>
			<input
				type="text"
				name="repository_end_date"
				id="repository_end_date"
				size="20"
				readonly="readonly"
				value="none"
			/>
			<input 
				type="image"
				src="images/calendar.gif"
				id="repository_end_date_button"
			/>
			or <a href="javascript:;" onclick="javascript:document.getElementById('repository_end_date').value='none';">none</a>
			</td>
			</tr>
			<tr>
			<td style="width:5px;white-space:nowrap;">Repeat :</td><td>
				<select name="repeat">
				<option value="0">None</option>
				<option value="1">Hourly</option>
				<option value="24">Daily</option>
				<option value="168">Weekly</option>
				</select>
			</td>
			</tr>
			</table>
		</td></tr>
		<tr><td>
			<table style="width:100%">
			<tr>
			<td style="width:5px;white-space:nowrap;">Execution arguments :</td><td>
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
			/>
			Delete files after successful execution
			</td>
		</tr>
		<tr>
			<td>
			<input 
				<!-- BEGIN REPOSITORY_INVENTORY_CHECKED -->checked="checked"<!-- END REPOSITORY_INVENTORY_CHECKED -->
				type="checkbox"
				name="repository_inventory"
				value="1"
			/>
			Run the inventory agent after execution
			</td>
		</tr>
		<tr>
			<td>
			<input 
				<!-- BEGIN REPOSITORY_WAKE_ON_LAN_CHECKED -->checked="checked"<!-- END REPOSITORY_WAKE_ON_LAN_CHECKED -->
				type="checkbox"
				name="repository_wake_on_lan"
				value="1"
			/>
			If connection fails, send a "Wake on Lan" request
			</td>
		</tr>
		<tr>
			<td>
			Max connection attempts:
			<input 
				type="text"
				name="repository_max_connection_attempt"
				value="{MAX_CONNECTION_ATTEMPT}"
				size="3"
			/>.
			Delay between two connections:
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
			<td>Operating system: {OS}
			</td>
		</tr>
		<tr>
			<td>
			<div style="text-align:center">
			<input 
				type="submit" 
				name="repository_launch_action"
				value="Launch the task" 
			/>
			</div>
			</td>
		</tr>
		</table>
	</div>
</div> <!-- REPOSITORY ACTIONS -->
