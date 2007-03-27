<style type="text/css">
	@import url("css/lsc2.css");
</style>

{where_I_m_connected}

<h2>Rapport d'exécution du fichier "{FILE_EXECUTED}"</h2>

<!-- BEGIN FILE_DONT_EXIST -->
<p>Le fichier à exécuter est inexistant !</p>
<!-- END FILE_DONT_EXIST -->
<!-- BEGIN RAPPORT -->
<div id="lsc-execute-file">
	<table>
		<tr>
			<th>Code de retour :</th>
			<td>{EXIT_CODE}</td>
		</tr>
		<tr>
			<th>Sortie standard :</th>
			<td>{STDOUT}</td>
		</tr>
		<tr>
			<th>Sortie d'erreurs :</th>
			<td>{STDERR}</td>
		</tr>
	</table>
</div>
<!-- END RAPPORT -->

<p style="text-align:center;"><a href="explorer.cgi?mac={MAC}">Retour à la page d'exploration de fichiers</a></p>
