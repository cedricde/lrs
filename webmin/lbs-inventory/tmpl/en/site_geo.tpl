<!-- BEGIN options -->
<form action="maj_site_geo.cgi{OPTIONS}" method="post" >
<!-- END options -->

<form action="maj_garantie.php" method="post" >

<table width="100%" border=1>
<!-- BEGIN initialisation -->

<tr>
	<td width="25%"> Geographical location </td>
	<td align="left"><input type="text" name="situation_geographique" value={INIT_SITE_GEO}  maxlength="10" size="10" title="Situation g&eacute;ographique"> </td>
</tr>
<tr>
	<td width="25%"> Phone number </td>
	<td align="left"> <input type="text" name="telephone_proche" value={INIT_TEL}  maxlength="10" size="10" title="T&eacute;l&eacute;phone le plus proche"></td>
</tr>

<!-- END initialisation -->


<tr>
	<td colspan=2 align="center">
		<input type="submit" name="valider"  value="Apply">
		<input type="reset" name="annuler" value="Reset">
	</td>
</tr>

</table>
</form>