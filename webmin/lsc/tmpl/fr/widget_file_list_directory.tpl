<script type="text/javascript" src="select_all.js">
</script>
<div style="border: 1px solid #FF3300;padding:0;margin:0;">
<table class="lsc-file-list-directory">
<thead>
	<tr>
		<th><!-- <a href="{FILE_LIST_TITLE_TYPE_URL}">-->Type<!--</a> --></th>
		<th><!-- <a href="{FILE_LIST_TITLE_FILENAME_URL}">-->Nom<!--</a>--></th>
		<th><!-- <a href="{FILE_LIST_TITLE_SIZE_URL}">-->Taille<!--</a>--></th>
		<th><!-- <a href="{FILE_LIST_TITLE_DATE_URL}">-->Dernière modification<!-- </a> --></th>
		<th colspan="<!-- BEGIN FOUR_ACTION -->3<!-- END FOUR_ACTION --><!-- BEGIN FIVE_ACTION -->4<!-- END FIVE_ACTION -->">Actions</th>
		<!-- BEGIN FILE_LIST_TITLE_SELECT_TO_COPY_COLUMN --><th>Sélection<br /> pour la copie</th><!-- END FILE_LIST_TITLE_SELECT_TO_COPY_COLUMN -->
		<!-- BEGIN FILE_LIST_TITLE_SELECT_TO_EXECUTE_COLUMN --><th>Sélection<br /> pour l'exécution</th><!-- END FILE_LIST_TITLE_SELECT_TO_EXECUTE_COLUMN -->
	</tr>
</thead>
<tbody>
	<!-- BEGIN FILE_LIST_ROW -->
	<tr class="{FILE_LIST_ROW_CLASS}">
		<td class="icon-column"><img 
			src="{RELATIVE_ROOT_MODULE_DIRECTORY}images/mimetypes/{FILE_LIST_ICON_MIMETYPE}" 
			alt="{FILE_LIST_MIMETYPE}"
		/></td>
		<td class="filename-column"
			><!-- BEGIN FILE_LIST_FILENAME_COLUMN -->{FILE_LIST_FILENAME}<input type="hidden" name="filename[{INDEX}]" value="{FILE_LIST_FILENAME}"><!-- END FILE_LIST_FILENAME_COLUMN --><!-- BEGIN FILE_LIST_DIRECTORYNAME_COLUMN --><a href="{SCRIPT_NAME}?mac={MAC}&profile={PROFILE}&group={GROUP}&go_to_directory={FILE_LIST_DIRECTORY_PATH}">{FILE_LIST_DIRECTORY_NAME}</a><input type="hidden" name="filename[{INDEX}]" value="{FILE_LIST_DIRECTORY_NAME}"><!-- END FILE_LIST_DIRECTORYNAME_COLUMN --></td>
		<td class="size-column" title="{FILE_LIST_SIZE} bytes"><div style="white-space:nowrap">{FILE_LIST_HUMAN_SIZE}</div></td>
		<td class="date-column"><div style="white-space:nowrap">{FILE_LIST_CTIME}</div></td>
		<td class="action-column"><div style="white-space:nowrap">
			<!-- BEGIN FILE_LIST_DOWNLOAD_COLUMN -->
			<a href="{SCRIPT_NAME}?mac={MAC}&profile={PROFILE}&group={GROUP}&download={FILE_LIST_OPEN_URL}"><img 
				src="{RELATIVE_ROOT_MODULE_DIRECTORY}images/actions/fileopen.png" 
				alt="Charger"
				title="Charger ou visualiser le fichier"
			/></a>
			<!-- END FILE_LIST_DOWNLOAD_COLUMN --></div>
		</td>
		<td class="action-column">
			<!-- BEGIN FILE_LIST_EDIT_COLUMN -->
			<a href="edit.cgi?mac={MAC}&profile={PROFILE}&group={GROUP}&edit={FILE_LIST_EDIT_URL}&current_tab={CURRENT_TAB}"><img 
				src="{RELATIVE_ROOT_MODULE_DIRECTORY}images/actions/edit.png" 
				alt="Editer"
				title="Editer le fichier"
			/></a>
			<!-- END FILE_LIST_EDIT_COLUMN -->
		</td>
		<td class="action-column">
			<!-- BEGIN FILE_LIST_DELETE_FILE_COLUMN -->
			<a href="{SCRIPT_NAME}?mac={MAC}&profile={PROFILE}&group={GROUP}&delete_file={FILE_LIST_DELETE_URL}"><img 
				src="{RELATIVE_ROOT_MODULE_DIRECTORY}images/actions/delete.png"
				alt="Supprimer"
				title="Supprimer le fichier"
				onclick="return confirm('Etes-vous sûr ?');"
			/></a>
			<!-- END FILE_LIST_DELETE_FILE_COLUMN -->
			<!-- BEGIN FILE_LIST_DELETE_DIRECTORY_COLUMN -->
			<a href="{SCRIPT_NAME}?mac={MAC}&profile={PROFILE}&group={GROUP}&delete_directory={FILE_LIST_DELETE_URL}"><img 
				src="{RELATIVE_ROOT_MODULE_DIRECTORY}images/actions/delete.png"
				alt="Supprimer"
				title="Supprimer le répertoire"
				onclick="return confirm('Etes-vous sûr ?');"
			/></a>
			<!-- END FILE_LIST_DELETE_DIRECTORY_COLUMN -->
		</td>
		<!-- BEGIN FILE_LIST_EXECUTE_COLUMN_HIDE -->
		<td class="action-column">
			<!-- BEGIN FILE_LIST_EXECUTE_COLUMN -->
			<a href="execute.cgi?mac={MAC}&profile={PROFILE}&group={GROUP}&execute={FILE_LIST_EXECUTE_URL}&current_tab={CURRENT_TAB}"><img 
				src="{RELATIVE_ROOT_MODULE_DIRECTORY}images/actions/run.png"
				alt="Exécuter"
				title="Exécution du fichier"
			/></a>
			<!-- END FILE_LIST_EXECUTE_COLUMN -->
		</td>
		<!-- END FILE_LIST_EXECUTE_COLUMN_HIDE -->
		<!-- <td class="action-column"> -->
			<!-- BEGIN FILE_LIST_PROPERTIES_COLUMN -->
<!--			<a href="properties.cgi?mac={MAC}&profile={PROFILE}&group={GROUP}&properties={FILE_LIST_EXECUTE_URL}"><img 
				src="{RELATIVE_ROOT_MODULE_DIRECTORY}images/actions/info.png"
				alt="Propriétés"
				title="Visualiser les propriétés"
			/></a>-->
			<!-- END FILE_LIST_PROPERTIES_COLUMN -->
		<!-- </td> -->
		<!-- BEGIN FILE_LIST_SELECT_TO_COPY_COLUMN -->
		<td class="select-copy-column">
			<input 
				type="checkbox"
				name="select_to_copy[]"
				value="{INDEX}"
				style="border:none"
			/>
		</td>
		<!-- END FILE_LIST_SELECT_TO_COPY_COLUMN -->
		<!-- BEGIN FILE_LIST_SELECT_TO_EXECUTE_COLUMN -->
		<td class="select-execute-column">
			<input
				type="radio"
				name="select_to_execute"
				value="{INDEX}"
				style="border:none"
				{RADIO_CHECKED}	
			/>
		</td>
		<!-- END FILE_LIST_SELECT_TO_EXECUTE_COLUMN -->
	</tr>
	<!-- END FILE_LIST_ROW -->
	<!-- BEGIN NO_EXECUTE_FILE_SELECTED -->
	<tr class="{FILE_LIST_ROW_CLASS}">
		<th colspan="8" style="text-align:right;">
		N'exécuter aucun fichier :&nbsp;
		</th>
		<td style="text-align:center">
			<input
				type="radio"
				name="select_to_execute"
				value="-1"
				style="border:none"
				{RADIO_NOTCHECKED}	
			/>
		</td>
	</tr>
	<!-- END NO_EXECUTE_FILE_SELECTED -->
</tbody>
</table>
</div>
<!-- BEGIN SELECT_ALL -->
<div style="text-align:right"><a href="javascript:;" onclick="javascript:select_all_files(true);">Sélectionner tous les fichiers</a> 
<a href="javascript:;" onclick="javascript:select_all_files(false);">Sélectionner aucun fichier</a></div>
<!-- END SELECT_ALL -->
