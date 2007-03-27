<table class="lsc-file-list">
<thead>
	<tr>
		<th><a href="{FILE_LIST_TITLE_TYPE_URL}">Type</a></th>
		<th><a href="{FILE_LIST_TITLE_FILENAME_URL}">File name</a></th>
		<th><a href="{FILE_LIST_TITLE_SIZE_URL}">Size</a></th>
		<th><a href="{FILE_LIST_TITLE_DATE_URL}">Last update date</a></th>
		<th>Actions</th>
	</tr>
</thead>
<tbody>
	<!-- BEGIN FILE_LIST_ROW -->
	<tr class="{FILE_LIST_ROW_CLASS}">
		<td class="icon-column"><img 
			src="{RELATIVE_ROOT_MODULE_DIRECTORY}images/mimetypes/{FILE_LIST_ICON_MIMETYPE}" 
			alt="{FILE_LIST_MIMETYPE}"
		/></td>
		<td class="filename-column"><a href="{FILE_LIST_FILENAME_URL}">{FILE_LIST_FILENAME}</a></td>
		<td class="size-column" title="{FILE_LIST_SIZE} octets">{FILE_LIST_HUMAN_SIZE}</td>
		<td class="date-column">{FILE_LIST_CTIME}</td>
		<td class="action-column">
			<a href="{FILE_LIST_OPEN_URL}"><img 
				src="{RELATIVE_ROOT_MODULE_DIRECTORY}images/actions/fileopen.png" 
				alt="Download"
				title="Download file"
			/></a>
			<a href="{FILE_LIST_EDIT_URL}"><img 
				src="{RELATIVE_ROOT_MODULE_DIRECTORY}images/actions/edit.png" 
				alt="Edit"
				title="Edit file"
			/></a>
			<a href="{FILE_LIST_DELETE_URL}"><img 
				src="{RELATIVE_ROOT_MODULE_DIRECTORY}images/actions/delete.png"
				alt="Delete"
				title="Delete file"
			/></a>
			<a href="{FILE_LIST_EXECUTE_URL}"><img 
				src="{RELATIVE_ROOT_MODULE_DIRECTORY}images/actions/run.png"
				alt="Execute"
				title="Execute file"
			/></a>
			<!--
			<a href="{FILE_LIST_PROPERTIES_URL}"><img 
				src="{RELATIVE_ROOT_MODULE_DIRECTORY}images/actions/info.png"
				alt="Propri�t�s"
				title="Afficher les propr�t�s du fichier"
			/></a>-->
		</td>
	</tr>
	<!-- END FILE_LIST_ROW -->
</tbody>
</table>
