<!-- BEGIN options -->
<form action="maj_garantie.cgi{OPTIONS}" method="post" >
<!-- END options -->

<table width="100%" border=1>
<!-- BEGIN initialisation -->

<tr>
	<th class="fond_designation" width="25%"> Date d'achat </th>
	<td class="fond_normal" align="left"><input type="text" name="date_achat" value={INIT_DATE}  maxlength="10" size="10" title="Date d'achat"> </td>
</tr>

<tr>
	<th class="fond_designation" width="25%"> Garantie du constructeur </th>
	<td class="fond_normal" align="left"> <input type="text" name="garantie_constructeur" value={INIT_CONSTRUCTEUR}  maxlength="10" size="10" title="Garantie du constructeur"></td>
</tr>

<tr>
	<th class="fond_designation" width="25%"> Garantie du revendeur </th>
	<td class="fond_normal" align="left"> <input type="text" name="duree" value={INIT_DUREE}  maxlength="10" size="10" title="Dur&eacute;e de la garantie"> </td>
</tr>

<tr>
	<th class="fond_designation" width="25%"> Commentaires </th>
	<td class="fond_normal" align="left" width="85%">
		<textarea  name="commentaires"   cols="112" rows="10"  wrap="physical">{INIT_COMMENTAIRE} </textarea> </td>
</tr>

<!-- END initialisation -->


<tr>
	<td colspan=2 align="center" class="fond_normal">
		<input type="submit" name="valider"  value="Valider">
		<input type="reset" name="annuler" value="Remise &eacute;tat initial">
	</td>
</tr>

</table>
</form>