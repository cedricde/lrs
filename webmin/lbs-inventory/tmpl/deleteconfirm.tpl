<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
  <title>Sitechecker</title>
  <meta http-equiv="content-type" content="text/html; charset=ISO-8859-1">
</head>
{HEADER}
<div align="Center">
<h1>Effacement</h1>
<h3></h3>
<hr width="100%" size="2"><br>
<center>
<h3>Etes vous certain de vouloir effacer la configuration concernant '{SITE}'?</h3>
<form method=POST action="site.php">
<input type=hidden name="cnf" value="{CNF}">
<input type=hidden name="action" value="save">
<input type=hidden name="delete" value="confirm">
En effet, vous pouvez aussi d&eacute;sactiver temporairement le site avec l'option 
'D&eacute;sactiver ce site'.
<br><br>
<input type=submit name="yessure" value="Effacer"> &nbsp;
<input type=submit name="mainmenu" value="Menu Principal"> &nbsp;</center>
</form>
<br>
<br>
</div>
{FOOTER}
</body>
</html>
