<style type="text/css">
	@import url("css/lsc2.css");
</style>
{where_I_m_connected}

<h2>Commands states</h2>
<form name="form" method="post" action="{SCRIPT_NAME}?mac={MAC}&profile={PROFILE}&group={GROUP}">
<table class="form">
	<tr>
		<td>Filter :
			<select name="target_filter">
				<option value="all">All targets</option>
				<!-- BEGIN TARGET_FILTER_ITEM -->
				<option 
					value="{TARGET_FILTER}" 
					<!-- BEGIN TARGET_FILTER_ITEM_SELECTED -->selected="selected"<!-- END TARGET_FILTER_ITEM_SELECTED --> 
				>{TARGET_FILTER}</option>
				<!-- END TARGET_FILTER_ITEM -->
			</select>
			<select name="number_command_by_page">
				<option 
					value="10"
					<!-- BEGIN NUMBER_BY_PAGE_10_SELECTED -->selected="selected"<!-- END NUMBER_BY_PAGE_10_SELECTED -->
				>Display 10 commands by page</option>
				<option value="20"
					<!-- BEGIN NUMBER_BY_PAGE_20_SELECTED -->selected="selected"<!-- END NUMBER_BY_PAGE_20_SELECTED -->
				>Display 20 commands by page</option>
				<option value="50"
					<!-- BEGIN NUMBER_BY_PAGE_50_SELECTED -->selected="selected"<!-- END NUMBER_BY_PAGE_50_SELECTED -->
				>Display 50 commands by page</option>
				<option value="100"
					<!-- BEGIN NUMBER_BY_PAGE_100_SELECTED -->selected="selected"<!-- END NUMBER_BY_PAGE_100_SELECTED -->
				>Display 100 commands by page</option>
			</select>
			<input 
				type="submit" 
				name="apply_filter_submit"
				value="Apply"
			/>
		</td>
	</tr>
</table>
</p>

<!-- BEGIN LIST_PAGES -->
<div style="text-align:center;margin-top:1em;margin-bottom:1em;">
	Pages : 
	<!-- BEGIN PAGE_PREVIOUS_HIDE -->
	<a href="{SCRIPT_NAME}?mac={MAC}&profile={PROFILE}&group={GROUP}&page={PAGE_PREVIOUS}"><img title="previous page" src="images/previous.png" /></a>
	<!-- END PAGE_PREVIOUS_HIDE -->
	
	<!-- BEGIN LIST_PAGE_COL -->
	<!-- BEGIN PAGE_LINK --><a href="{SCRIPT_NAME}?mac={MAC}&profile={PROFILE}&group={GROUP}&page={PAGE_NUMBER}">{PAGE_LABEL}</a><!-- END PAGE_LINK -->
	<!-- BEGIN PAGE_CURRENT -->{PAGE_LABEL}<!-- END PAGE_CURRENT -->
	<!-- END LIST_PAGE_COL -->

	<!-- BEGIN PAGE_NEXT_HIDE -->
	<a href="{SCRIPT_NAME}?mac={MAC}&profile={PROFILE}&group={GROUP}&page={PAGE_NEXT}"><img title="next page" src="images/next.png" /></a>
	<!-- END PAGE_NEXT_HIDE -->
</div>
<!-- END LIST_PAGES -->

<div id="lsc-commands-states-list">
	<!-- BEGIN COMMANDS_STATES_LIST -->
	<table class="table-horizontal" style="width:100%;">
		<thead>
			<tr>
				<th class="center-column">Target</th>
				<th class="center-column">Number <br/>of<br/>hosts</th>
				<th class="center-column">Command<br />title</th>
				<th class="center-column">Command date<br />created</th>
				<th class="center-column">Start<br />Date</th>
				<th class="center-column">Expire <br/>date</th>
				<th class="center-column" colspan="2">State</th>
				<!-- <th class="number-attempt-column">Nombre de<br /> tentatives</th> -->
				<th class="center-column" colspan="3">Actions</th>
			</tr>
		</thead>
		<tbody>                                      
			<!-- BEGIN COMMANDS_STATES_ROW -->
			<tr class="{ROW_CLASS}">
				<td class="center-column"><a href="{SCRIPT_NAME}?mac={MAC}&profile={PROFILE}&group={GROUP}&target={TARGET_URL}">{TARGET}</a></td>
				<td class="center-column">{NUMBER_OF_HOST}</td>
				<td class="center-column">{TITLE}</td>
				<td class="center-column">{DATE_CREATED}</td>
				<td class="center-column">{START_DATE}</td>
				<td class="center-column">{END_DATE}</td>
				<td class="center-column">
					&nbsp;<img src="images/{CURRENT_STATES_ICON}" />&nbsp;
				</td>
				<td class="center-column">
					{CURRENT_STATES}
				</td>
				<td class="center-column">
					<a href="{SCRIPT_NAME}?mac={MAC}&profile={PROFILE}&group={GROUP}&id_command={ID_COMMAND}"><img title="Visualiser le détail de cette commande" src="images/detail.gif" /></a>
				</td>
				<td class="center-column">
					<!-- BEGIN BUTTON_PAUSE --><a 
						href="{SCRIPT_NAME}?mac={MAC}&profile={PROFILE}&group={GROUP}&id_command_pause={ID_COMMAND}&action=pause"
						><img title="Pause command" src="images/stock_media-pause.png" /></a><!-- END BUTTON_PAUSE -->
					<!-- BEGIN BUTTON_PLAY --><a 
						href="{SCRIPT_NAME}?mac={MAC}&profile={PROFILE}&group={GROUP}&id_command_play={ID_COMMAND}&action=play"
					><img title="Start command" src="images/stock_media-play.png" /></a><!-- END BUTTON_PLAY -->
				</td><td class="center-column">
					<!-- BEGIN BUTTON_STOP --><a
						href="{SCRIPT_NAME}?mac={MAC}&profile={PROFILE}&group={GROUP}&id_command_stop={ID_COMMAND}&action=stop"
					><img title="Stop command" src="images/stock_media-stop.png " /></a><!-- END BUTTON_STOP -->
				</td>
			</tr>
			<!-- END COMMANDS_STATES_ROW -->
		</tbody>
	</table>
	
	<!-- END COMMANDS_STATES_LIST -->
	<!-- BEGIN COMMANDS_STATES_LIST_EMPTY -->
	No tasks scheduled, started or done.
	<!-- END COMMANDS_STATES_LIST_EMPTY -->
</div>
<br />
