<style type="text/css">
	@import url("css/lsc2.css");
</style>

{where_I_m_connected}
<div class="lsc">
<h2>Informations générales</h2>
<h3>Contrôle à distance des postes clients suivants :</h3>

<!-- BEGIN HOSTS_LIST -->
<table class="table-horizontal">
<thead>
	<tr>
		<th style="padding:0.5em;">Nom du poste client</th>
		<th style="padding:0.5em;">Adresse IP</th>
		<th style="padding:0.5em;">Adresse MAC</th>
	</tr>
</thead>
<tbody>
	<!-- BEGIN HOSTS_LIST_ROW -->
	<tr class={ROW_CLASS}>
		<!-- <td class="center-column">{INDEX}</td> -->
		<td class="center-column" style="padding:0.5em;"><a href="index.cgi?mac={MAC_AND_DOT}">{HOSTNAME}</a></td>
		<td class="center-column" style="padding:0.5em;"><a href="index.cgi?mac={MAC_AND_DOT}">{IP}</a></td>
		<td class="center-column" style="padding:0.5em;"><a href="index.cgi?mac={MAC_AND_DOT}">{MAC}</a></td>
	</tr>
	<!-- END HOSTS_LIST_ROW -->
</tbody>
</table>
<!-- END HOSTS_LIST -->
<!-- BEGIN HOSTS_LIST_EMPTY -->
<p>Le groupe ne contient aucun poste client.</p>
<!-- END HOSTS_LIST_EMPTY -->

<h3>Exécuter une action sur les postes clients appartenant à "{PROFILE}:{GROUP}"</h3>

{standard_host_actions}

</div> <!-- lsc -->
