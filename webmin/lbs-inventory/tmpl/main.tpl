<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
  <title>Sitechecker</title>
  <meta http-equiv="content-type" content="text/html; charset=ISO-8859-1">
</head>
<!-- $Id: main.tpl 2164 2005-03-17 14:28:03Z jaudin $ -->
{HEADER}
<div align="Center">
<h1>Etat des sites</h1>
<br>
<hr width="100%" size="2"><br>
</div>
<div align="Left">
<table cellpadding="2" cellspacing="2" border="0" width="100%">
  <tbody>
    <tr align="center">
      <td align="left" valign="Top"><b>Site</b><br>
      </td>
      <td valign="Top" colspan=2><b>Etat</b><br>
      </td>
      <td valign="Top"><br>
      </td>
      <td valign="Top"><br>
      </td>
    </tr>
<!-- BEGIN site_row -->
    <tr>
      <td valign="Top"><a href='{URL}'>{DESC}</a></td>
      <td align="Center"><img src='{STATUS}'></td>
      <td valign="Top">{LAST}</td>
      <td valign="Top"><a href='site.php?action=view&site={DESC}&log={LOG}'><img border=0 src="images/details.gif"></a></td>
      <td valign="Top"><a href='site.php?action=edit&cnf={CONF}'><img border=0 src="images/config.gif"></a></td>
    </tr>
<!-- END site_row -->
  </tbody>
</table>
<br>
</div>
<table border=0 width='100%'><tr>
<td align="left"><a href="site.php"><img border=0 src="images/actualiser.gif"></a></td>
<td align="right"><a href="site.php?action=add"><img width=108 border=0 src="images/nouveau.gif"></a></td>
</tr></table>
{FOOTER}
<script language="JavaScript">
<!--
setTimeout('window.location.replace("site.php")',10000);
//-->
</script>
</body>
</html>
