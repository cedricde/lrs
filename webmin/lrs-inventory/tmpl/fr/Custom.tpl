<link rel='StyleSheet' href='/lrs-inventory/css/main.css' type='text/css' media='screen' />

<h2>Personnalisation de {MACHINE_NAME}</h2>

<div id="field-list">

	<h3>Liste des champs</h3>

	<form action="custom.cgi" method="get">
		
	<input type="hidden" name="ac" value="update"/>
	<input type="hidden" name="mac" value="{MACHINE}"/>
	<input type="hidden" name="host" value="{MACHINE_NAME}"/>

	<table>

		<tr>
			<th>Champ</th>
			<th>Valeur</th>
			<th>Actions</th>
		</tr>
			
		<!-- BEGIN row -->
		
		<tr class="{ROWCLASS}">
			<td><label for="{FIELDN}">{FIELD}</label></td>
			<td><input type="text" value="{VALUE}" name="{FIELDN}" id="{FIELDN}" size={SIZE} /></td>
			<td><!-- BEGIN candelete --><a href="{DELETE_URL}">Supprimer</a><!-- END candelete --></td>
		</tr>
		
		<!-- END row -->

	</table>

	<input type="submit" value="Mettre à jour" />
	
	</form>

</div>


<div id="add-field">

	<h3>Ajouter un champ</h3>

		<form action="custom.cgi" method="get">
		
			<input type="hidden" name="ac" value="add"/>
			<input type="hidden" name="mac" value="{MACHINE}"/>

			<div class="field">
				<label for="field">Nom du champ</label>
				<input type="text" name="field" id="field" value="" />
			</div>

			<div class="field">
				<label for="value">Type du champ</label>
				<select name="value" id="value">{SELECT}</select>
			</div>

			<input type="submit" value="Ajouter" />

		</form>

</div>