<link rel='StyleSheet' href='/lrs-inventory/css/main.css' type='text/css' media='screen' />

<h2>{MACHINE_NAME} customization</h2>

<div id="field-list">

	<h3>Field list</h3>

	<form action="custom.cgi" method="get">
		
	<input type="hidden" name="ac" value="update"/>
	<input type="hidden" name="mac" value="{MACHINE}"/>
	<input type="hidden" name="host" value="{MACHINE_NAME}"/>

	<table>

		<tr>
			<th>Field</th>
			<th>Value</th>
			<th>Actions</th>
		</tr>
			
		<!-- BEGIN row -->
		
		<tr class="{ROWCLASS}">
			<td><label for="{FIELDN}">{FIELD}</label></td>
			<td><input type="text" value="{VALUE}" name="{FIELDN}" id="{FIELDN}" size={SIZE} /></td>
			<td><!-- BEGIN candelete --><a href="{DELETE_URL}">Delete</a><!-- END candelete --></td>
		</tr>
		
		<!-- END row -->

	</table>

	<input type="submit" value="Update" />
	
	</form>

</div>


<div id="add-field">

	<h3>Add a field</h3>

		<form action="custom.cgi" method="get">
		
			<input type="hidden" name="ac" value="add"/>
			<input type="hidden" name="mac" value="{MACHINE}"/>

			<div class="field">
				<label for="field">Field name</label>
				<input type="text" name="field" id="field" value="" />
			</div>

			<div class="field">
				<label for="value">Field type</label>
				<select name="value" id="value">{SELECT}</select>
			</div>

			<input type="submit" value="Add" />

		</form>

</div>