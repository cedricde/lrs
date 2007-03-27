<div id="lsc-standard-file-list-directory-actions"> <!-- STANDARD FILE LIST DIRECTORY ACTIONS -->
	<h3 class="box-title">Upload file in current directory <strong>"{STANDARD_FILE_LIST_DIRECTORY_ACTIONS_CURRENT_DIRECTORY}"</strong> :</h3>
	<div class="box">
	<table class="form">
		<tr>
			<td>
			<select name="type_file_to_create">
				<option value="file">Create file</option>
				<option value="directory">Create directory</option>
			</select> named
			<input 
				name="filename_to_create" 
				type="text" 
				value="" 
			/> 
			in current directory 
			<input 
				name="create_file_submit"
				type="submit"
				value="create"
			/>
			</td>
		</tr>
		<tr>
			<td>
			Upload file 
			<input 
				name="file_to_upload"
				type="file" 
				value=""
			/> 
			in current directory 
			<input 
				name="file_upload_submit"
				type="submit"
				value="Send"
			/>
			</td>
		</tr>
	</table>
	</div>
</div> <!-- STANDARD FILE LIST DIRECTORY ACTIONS -->

