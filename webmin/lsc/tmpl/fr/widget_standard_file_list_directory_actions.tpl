<div id="lsc-standard-file-list-directory-actions"> <!-- STANDARD FILE LIST DIRECTORY ACTIONS -->
	<h3 class="box-title">Envoi de fichiers dans le r�pertoire courant <strong>"{STANDARD_FILE_LIST_DIRECTORY_ACTIONS_CURRENT_DIRECTORY}"</strong> :</h3>
	<div class="box">
	<table class="form">
		<tr>
			<td>
			<select name="type_file_to_create">
				<option value="file">Cr�er un fichier</option>
				<option value="directory">Cr�er un r�pertoire</option>
			</select> nomm�
			<input 
				name="filename_to_create" 
				type="text" 
				value="" 
			/> 
			dans le r�pertoire courant 
			<input 
				name="create_file_submit"
				type="submit"
				value="Cr�er"
			/>
			</td>
		</tr>
		<tr>
			<td>
			Envoyer le fichier 
			<input 
				name="file_to_upload"
				type="file" 
				value=""
			/> 
			dans le r�pertoire courant 
			<input 
				name="file_upload_submit"
				type="submit"
				value="Envoyer"
			/>
			</td>
		</tr>
	</table>
	</div>
</div> <!-- STANDARD FILE LIST DIRECTORY ACTIONS -->

