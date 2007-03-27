<style type="text/css">
	@import url("css/lsc_main.css");
</style>
<style type="text/css">@import url("calendar/calendar-win2k-1.css");</style>
<script type="text/javascript" src="calendar/calendar.js"></script>
<script type="text/javascript" src="calendar/lang/calendar-en.js"></script>
<script type="text/javascript" src="calendar/calendar-setup.js"></script>
{where_I_m_connected}

<div class="lsc">
<h2>Repository files</h2>

{action_message}

<table style="border:0;width:100%;">
	<tr>
	<td style="width:18em;">
		<h3 class="box-title">Repository directory tree :</span></h3>
	</td>
	<td style="vertical-align:bottom">
		<h3 class="box-title">Directory files list 
		<strong>"{CURRENT_DIRECTORY_PATH}"</strong> :</h3>
	</td>
	</tr>
	<tr>
	<td style="vertical-align:top">{tree}</td>
	<td style="vertical-align:top">
		<form 
			name="main_form"
			method="post"
			action="{SCRIPT_NAME}?mac={MAC}&profile={PROFILE}&group={GROUP}&process=1"
			enctype="multipart/form-data"
		>
		{file_list_directory}
		<!-- BEGIN FILE_LIST_DIRECTORY_EMPTY -->
		<p><i>Directory is empty</i></p>
		<!-- END FILE_LIST_DIRECTORY_EMPTY -->
		<div style="height:1em"></div>
		{repository_actions}
		<div style="height:1em"></div>
		{standard_file_list_directory_actions}
		</form>
		<script type="text/javascript">
		    Calendar.setup({
			inputField     :    "repository_start_date",   // id of the input field
			ifFormat       :    "%d-%m-%Y à %H:%M",       // format of the input field
			showsTime      :    true,
			timeFormat     :    "24",
			button	       :    "repository_start_date_button",
			singleClick    :    true
		    });
		    Calendar.setup({
			inputField     :    "repository_end_date",
			ifFormat       :    "%d-%m-%Y à %H:%M",
			showsTime      :    true,
			timeFormat     :    "24",
			button	       :    "repository_end_date_button",
			singleClick    :    true
		    });
		</script>
	</td>
	</tr>
</table>
</div> <!-- lsc -->
