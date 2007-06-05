<style type="text/css">
	@import url("css/lsc_main.css");
</style>
{where_I_m_connected}
<div class="lsc">
<h2>Informations générales</h2>

<h3>Contrôle à distance du poste client</h3>
<div class="indent">
<table class="vertical">
	<tbody>
		<tr>
			<th>Nom du poste :</th>
			<td>{HOST_INFO_HOSTNAME}</td>
		</tr>
		<tr>
			<th>Adresse IP :</th>
			<td>{HOST_INFO_IP_ADDRESS}</td>
		</tr>
		<tr>
			<th>Adresse MAC :</th>
			<td>{HOST_INFO_MAC_ADDRESS}</td>
		</tr>
		<tr>
			<th>Appartient au profil :</th>
			<td><a href="{SCRIPT_NAME}?profile={HOST_INFO_PROFILE_URL}">{HOST_INFO_PROFILE}</a></td>
		</tr>
		<tr>
			<th>Appartient au groupe :</th>
			<td><a href="{SCRIPT_NAME}?group={HOST_INFO_GROUP_URL}">{HOST_INFO_GROUP}</a></td>
		</tr>
		<tr>
			<th>Système d'exploitation :</th>
			<td>{HOST_INFO_OPERATING_SYSTEM}</td>
		</tr>
		<tr>
			<th>Ping du poste client :</th>
			<td>{HOST_INFO_REACHABLE}</td>
		</tr>
	</tbody>
</table>
</div> <!-- indent -->
<h3>Exécuter une action sur le poste client "{HOST_INFO_PROFILE}:{HOST_INFO_GROUP}/{HOST_INFO_HOSTNAME}"</h3>

{standard_host_actions}
</div> <!-- lsc -->
