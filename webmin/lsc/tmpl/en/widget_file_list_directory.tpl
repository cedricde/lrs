<script type="text/javascript" src="select_all.js">
</script>
<div style="border: 1px solid #FF3300;padding:0;margin:0;">
<table class="lsc-file-list-directory">
<thead>
	<tr>
		<th><!-- <a href="{FILE_LIST_TITLE_TYPE_URL}">-->Type<!--</a> --></th>
		<th><!-- <a href="{FILE_LIST_TITLE_FILENAME_URL}">-->File name<!--</a>--></th>
		<th><!-- <a href="{FILE_LIST_TITLE_SIZE_URL}">-->Size<!--</a>--></th>
		<th><!-- <a href="{FILE_LIST_TITLE_DATE_URL}">-->Last update date<!-- </a> --></th>
		<th colspan="<!-- BEGIN FOUR_ACTION -->3<!-- END FOUR_ACTION --><!-- BEGIN FIVE_ACTION -->4<!-- END FIVE_ACTION -->">Actions</th>
		<!-- BEGIN FILE_LIST_TITLE_SELECT_TO_COPY_COLUMN --><th>Select<br />to upload</th><!-- END FILE_LIST_TITLE_SELECT_TO_COPY_COLUMN -->
		<!-- BEGIN FILE_LIST_TITLE_SELECT_TO_EXECUTE_COLUMN --><th>Select<br />to execute</th><!-- END FILE_LIST_TITLE_SELECT_TO_EXECUTE_COLUMN -->
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
			><!-- BEGIN FILE_LIST_FILENAME_COLUMN -->{FILE_LIST_FILENAME}<input type="hidden" name="filename[{INDEX}]" value="{FILE_LIST_FILENAME}"><!-- END FILE_LIST_FILENAME_COLUMN --><!-- BEGIN FILE_LIST_DIRECTORYNAME_COLUMN --><a href="{SCRIPT_NAME}?mac={MAC}&profile={PROFILE}&group={GROUP}&repository_pwd={CURRENT_DIRECTORY_PATH}%2F{FILE_LIST_DIRECTORY_PATH}">{FILE_LIST_DIRECTORY_NAME}</a><input type="hidden" name="filename[{INDEX}]" value="{FILE_LIST_DIRECTORY_NAME}"><!-- END FILE_LIST_DIRECTORYNAME_COLUMN --></td>
		<td class="size-column" title="{FILE_LIST_SIZE} bytes">{FILE_LIST_HUMAN_SIZE}</td>
		<td class="date-column">{FILE_LIST_CTIME}</td>
		<td class="action-column">
			<!-- BEGIN FILE_LIST_DOWNLOAD_COLUMN -->
			<a href="{SCRIPT_NAME}?mac={MAC}&profile={PROFILE}&group={GROUP}&download={FILE_LIST_OPEN_URL}"><img 
				src="{RELATIVE_ROOT_MODULE_DIRECTORY}images/actions/fileopen.png" 
				alt="Download"
				title="Download file"
			/></a>
			<!-- END FILE_LIST_DOWNLOAD_COLUMN -->
		</td>
		<td class="action-column">
			<!-- BEGIN FILE_LIST_EDIT_COLUMN -->
			<a href="edit.cgi?mac={MAC}&profile={PROFILE}&group={GROUP}&edit={FILE_LIST_EDIT_URL}&current_tab={CURRENT_TAB}"><img 
				src="{RELATIVE_ROOT_MODULE_DIRECTORY}images/actions/edit.png" 
				alt="Edit"
				title="Edit file"
			/></a>
			<!-- END FILE_LIST_EDIT_COLUMN -->
		</td>
		<td class="action-column">
			<!-- BEGIN FILE_LIST_DELETE_FILE_COLUMN -->
			<a href="{SCRIPT_NAME}?mac={MAC}&profile={PROFILE}&group={GROUP}&delete_file={FILE_LIST_DELETE_URL}"><img 
				src="{RELATIVE_ROOT_MODULE_DIRECTORY}images/actions/delete.png"
				alt="Delete"
				title="Delete file"
				onclick="return confirm('Are you sure ?');"
			/></a>
			<!-- END FILE_LIST_DELETE_FILE_COLUMN -->
			<!-- BEGIN FILE_LIST_DELETE_DIRECTORY_COLUMN -->
			<a href="{SCRIPT_NAME}?mac={MAC}&profile={PROFILE}&group={GROUP}&delete_directory={FILE_LIST_DELETE_URL}"><img 
				src="{RELATIVE_ROOT_MODULE_DIRECTORY}images/actions/delete.png"
				alt="Delete"
				title="Delete directory"
				onclick="return confirm('Are you sure ?');"
			/></a>
			<!-- END FILE_LIST_DELETE_DIRECTORY_COLUMN -->
		</td>
		<!-- BEGIN FILE_LIST_EXECUTE_COLUMN_HIDE -->
		<td class="action-column">
			<!-- BEGIN FILE_LIST_EXECUTE_COLUMN -->
			<a href="execute.cgi?mac={MAC}&profile={PROFILE}&group={GROUP}&execute={FILE_LIST_EXECUTE_URL}&current_tab={CURRENT_TAB}"><img 
				src="{RELATIVE_ROOT_MODULE_DIRECTORY}images/actions/run.png"
				alt="Execute"
				title="Execute file"
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
		Don't execute anything :&nbsp;
		</th>
		<td class="select-execute-column">
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
<div style="text-align:right"><a href="javascript:;" onclick="javascript:select_all_files(true);">All files selected</a> 
<a href="javascript:;" onclick="javascript:select_all_files(false);">No files selected</a></div>
<!-- END SELECT_ALL -->
