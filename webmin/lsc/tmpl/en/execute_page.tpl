<style type="text/css">
	@import url("css/lsc2.css");
</style>

{where_I_m_connected}

<h2>"{FILE_EXECUTED}" file execution report :</h2>

<!-- BEGIN FILE_DONT_EXIST -->
<p>File not exist !</p>
<!-- END FILE_DONT_EXIST -->
<!-- BEGIN RAPPORT -->
<div id="lsc-execute-file">
	<table>
		<tr>
			<th>Exit code :</th>
			<td>{EXIT_CODE}</td>
		</tr>
		<tr>
			<th>Standard output :</th>
			<td>{STDOUT}</td>
		</tr>
		<tr>
			<th>Error output :</th>
			<td>{STDERR}</td>
		</tr>
	</table>
</div>
<!-- END RAPPORT -->

<p style="text-align:center;"><a href="explorer.cgi?mac={MAC}">Return to file explorer page</a></p>
