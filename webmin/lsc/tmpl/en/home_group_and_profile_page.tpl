<style type="text/css">
	@import url("css/lsc2.css");
</style>

{where_I_m_connected}
<div class="lsc">
<h2>General informations</h2>
<h3>Distant control these hosts :</h3>

<!-- BEGIN HOSTS_LIST -->
<table class="table-horizontal">
<thead>
	<tr>
		<th style="padding:0.5em;">Host name</th>
		<th style="padding:0.5em;">IP address</th>
		<th style="padding:0.5em;">MAC address</th>
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
<p>This group is empty.</p>
<!-- END HOSTS_LIST_EMPTY -->

<h3>Start action on "{PROFILE}:{GROUP}" hosts</h3>

{standard_host_actions}

</div> <!-- lsc -->
