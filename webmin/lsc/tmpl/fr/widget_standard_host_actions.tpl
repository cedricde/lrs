<div id="lsc-standard-host-actions"> <!-- STANDARD HOST ACTIONS -->
	<table>
		<tr>
		<td>
			<form method="post" action="{SCRIPT_NAME}?mac={MAC}&profile={PROFILE}&group={GROUP}">
			<select name="action">
				<option value="">Action à exécuter...</option>
				<!-- BEGIN SCRIPT_LIST -->
				<option value="{FILENAME}">{TITLE}</option>
				<!-- END SCRIPT_LIST -->
			</select>
			<input 
				type="image"
				src="images/button_ok.png"
				style="vertical-align:bottom;border:0"
			/>
		</td>
		</tr>
	</table>
</div> <!-- STANDARD HOST ACTIONS -->
