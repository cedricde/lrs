<link rel='StyleSheet' href='/lrs-inventory/css/main.css' type='text/css' media='screen' />

<p>

	<div id="request-form">

		<h3>Inventory request</h3>

		<form action="request.cgi" method="get">

			<input type="hidden" name="profile" value="{REQUEST_PROFILE}" />
			<input type="hidden" name="group" value="{REQUEST_GROUP}" />
			<input type="hidden" name="mac" value="{REQUEST_MAC}" />

			<input type="submit" name="request" id="request" value="Request an inventory" />

		</form>

		<p>The inventory request updates instantly the machine informations by connecting to them. Only available machines will be updated.</p>

		<div id="eocontent"></div>

	</div>
</p>