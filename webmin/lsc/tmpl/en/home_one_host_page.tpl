<style type="text/css">
	@import url("css/lsc_main.css");
</style>
{where_I_m_connected}
<div class="lsc">
<h2>General informations</h2>

<h3>Distant control of this host :</h3>
<div class="indent">
<table class="vertical">
	<tbody>
		<tr>
			<th>MAC address :</th>
			<td>{HOST_INFO_MAC_ADDRESS}</td>
		</tr>
		<tr>
			<th>IP address :</th>
			<td>{HOST_INFO_IP_ADDRESS}</td>
		</tr>
		<tr>
			<th>Host name :</th>
			<td>{HOST_INFO_HOSTNAME}</td>
		</tr>
		<tr>
			<th>Belongs to profile :</th>
			<td><a href="{SCRIPT_NAME}?profile={HOST_INFO_PROFILE_URL}">{HOST_INFO_PROFILE}</a></td>
		</tr>
		<tr>
			<th>Belongs to group :</th>
			<td><a href="{SCRIPT_NAME}?group={HOST_INFO_GROUP_URL}">{HOST_INFO_GROUP}</a></td>
		</tr>
		<tr>
			<th>Operating system :</th>
			<td>{HOST_INFO_OPERATING_SYSTEM}</td>
		</tr>
		<tr>
			<th>Ping host :</th>
			<td>{HOST_INFO_REACHABLE}</td>
		</tr>
	</tbody>
</table>
</div> <!-- indent -->
<h3>Start action on "{HOST_INFO_PROFILE}:{HOST_INFO_GROUP}/{HOST_INFO_HOSTNAME}" host</h3>

{standard_host_actions}
</div> <!-- lsc -->
