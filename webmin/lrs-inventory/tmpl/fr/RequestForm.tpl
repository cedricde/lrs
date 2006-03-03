<link rel='StyleSheet' href='/lrs-inventory/css/main.css' type='text/css' media='screen' />

<p>

	<div id="request-form">

		<h3>Demande d'inventaire</h3>

		<form action="request.cgi" method="get">

			<input type="hidden" name="profile" value="{REQUEST_PROFILE}" />
			<input type="hidden" name="group" value="{REQUEST_GROUP}" />
			<input type="hidden" name="mac" value="{REQUEST_MAC}" />

			<input type="submit" name="request" id="request" value="Demander un inventaire" />

		</form>

		<p>La demande d'inventaire met à jour instantanément les informations des machines en se connectant à celle-ci. Seules les machines disponibles seront mises à jour.</p>

		<div id="eocontent"></div>

	</div>
</p>