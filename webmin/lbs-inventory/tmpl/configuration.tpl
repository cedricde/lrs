<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
  <title>Sitechecker</title>
  <meta http-equiv="content-type" content="text/html; charset=ISO-8859-1">
</head>
{HEADER}
<div align="Center">
<h1>Configuration</h1>
<h3></h3>
<hr width="100%" size="2"><br>
<div align="Left">
<h3>G&eacute;n&eacute;ral:</h3>
</div>
<form method=POST action="site.php">
<input type=hidden name="cnf" value="{CNF}">
<input type=hidden name="action" value="save">
<table cellpadding="2" cellspacing="2" border="0" width="100%">
  <tbody>
    <tr>
      <td valign="Top" width="30%" align="Right">Description:<br>
      </td>
      <td valign="Top"><input type=text name="global_desc" value="{GLOBAL_DESC}" size=60>
      </td>
    </tr>
    <tr>
      <td valign="Top" align="Right">Url:<br>
      </td>
      <td valign="Top"><input type=text name="global_url" value="{GLOBAL_URL}" size=60>
      <a onClick='window.open("./help/conf.html", "help", "toolbar=no,menubar=no,scrollbars=yes,width=400,height=300,resizable=yes"); return false' href="./help/conf.html"><small>Aide<small></a>
      </td>
    </tr>
    <tr>
      <td valign="Top" align="Right">Intervalle de v&eacute;rification:<br>
      </td>
      <td valign="Top"><input type=text name="global_every" value="{GLOBAL_EVERY}" size=6>
      <a onClick='window.open("./help/conf.html#ev", "help", "toolbar=no,menubar=no,scrollbars=yes,width=400,height=300,resizable=yes"); return false' href="./help/conf.html#ev"><small>Aide<small></a>
      </td>
    </tr>
  </tbody>
</table>
<div align="Left">
<h3>Login avant test:</h3>
</div>
<table cellpadding="2" cellspacing="2" border="0" width="100%">
  <tbody>
    <tr>
      <td valign="Top" width="30%" align="Right">Url de Login:<br>
      </td>
      <td valign="Top"><input type=text name="global_loginurl" value="{GLOBAL_LOGINURL}" size=60>
      <a onClick='window.open("./help/conf.html#ul", "help", "toolbar=no,menubar=no,scrollbars=yes,width=400,height=300,resizable=yes"); return false' href="./help/conf.html#ul"><small>Aide<small></a>
      </td>
    </tr>
    <tr>
      <td valign="Top" align="Right">Donn&eacute;es du login:<br>
      </td>
      <td valign="Top"><input type=text name="global_loginform" value="{GLOBAL_LOGINFORM}" size=60>
      <a onClick='window.open("./help/conf.html#dl", "help", "toolbar=no,menubar=no,scrollbars=yes,width=400,height=300,resizable=yes"); return false' href="./help/conf.html#dl"><small>Aide<small></a>
      </td>
    </tr>
  </tbody>
</table>
<div align="Left">
<h3>Validation des donn&eacute;es:</h3>
</div>
<table cellpadding="2" cellspacing="2" border="0" width="100%">
  <tbody>
    <tr>
      <td valign="Top" width="30%" align="Right">Bons Mots:<br>
      </td>
      <td valign="Top"><input type=text name="check_goodword" value="{CHECK_GOODWORD}" size=60>
      <a onClick='window.open("./help/conf.html#bm", "help", "toolbar=no,menubar=no,scrollbars=yes,width=400,height=300,resizable=yes"); return false' href="./help/conf.html#bm"><small>Aide<small></a>
      </td>
    </tr>
    <tr>
      <td valign="Top" align="Right" width="30%">Mauvais Mots:<br>
      </td>
      <td valign="Top"><input type=text name="check_badword" value="{CHECK_BADWORD}" size=60>
      <a onClick='window.open("./help/conf.html#mm", "help", "toolbar=no,menubar=no,scrollbars=yes,width=400,height=300,resizable=yes"); return false' href="./help/conf.html#mm"><small>Aide<small></a>
      </td>
    </tr>
    <tr>
      <td valign="Top" align="Right" width="30%">D&eacute;lai max. de chargement:<br>
      </td>
      <td valign="Top"><input type=text name="check_maxtime" value="{CHECK_MAXTIME}" size=6>
      <a onClick='window.open("./help/conf.html#dm", "help", "toolbar=no,menubar=no,scrollbars=yes,width=400,height=300,resizable=yes"); return false' href="./help/conf.html#dm"><small>Aide<small></a>
      </td>
    </tr>
    <tr>
      <td valign="Top" align="Right" width="30%">Taille min. des donn&eacute;es:<br>
      </td>
      <td valign="Top"><input type=text name="check_minsize" value="{CHECK_MINSIZE}" size=6>
      <a onClick='window.open("./help/conf.html#tm", "help", "toolbar=no,menubar=no,scrollbars=yes,width=400,height=300,resizable=yes"); return false' href="./help/conf.html#tm"><small>Aide<small></a>
      </td>
    </tr>
  </tbody>
</table>
<br>
<div align="Left">
<h3>Options Avanc&eacute;es:</h3>
</div>
<table cellpadding="2" cellspacing="2" border="0" width="100%">
  <tbody>
    <tr>
      <td valign="Top" width="30%" align="Right">Donn&eacute;es HTTP:<br>
      </td>
      <td valign="Top"><input type=text name="global_form" value="{GLOBAL_FORM}" size=60>
      <a onClick='window.open("./help/conf.html#dh", "help", "toolbar=no,menubar=no,scrollbars=yes,width=400,height=300,resizable=yes"); return false' href="./help/conf.html#dh"><small>Aide<small></a>
      </td>
    </tr>
    <tr>
      <td valign="Top" width="30%" align="Right">Cookies:<br>
      </td>
      <td valign="Top"><input type=text name="global_cookie" value="{GLOBAL_COOKIE}" size=60>
      <a onClick='window.open("./help/conf.html#co", "help", "toolbar=no,menubar=no,scrollbars=yes,width=400,height=300,resizable=yes"); return false' href="./help/conf.html#co"><small>Aide<small></a>
      </td>
    </tr>
    <tr>
      <td valign="Top" width="30%" align="Right">Agent:<br>
      </td>
      <td valign="Top"><input type=text name="global_agent" value="{GLOBAL_AGENT}" size=60>
      <a onClick='window.open("./help/conf.html#ag", "help", "toolbar=no,menubar=no,scrollbars=yes,width=400,height=300,resizable=yes"); return false' href="./help/conf.html#ag"><small>Aide<small></a>
      </td>
    </tr>
    <tr>
      <td valign="Top" width="30%" align="Right">Referer:<br>
      </td>
      <td valign="Top"><input type=text name="global_referer" value="{GLOBAL_REFERER}" size=60>
      <a onClick='window.open("./help/conf.html#re", "help", "toolbar=no,menubar=no,scrollbars=yes,width=400,height=300,resizable=yes"); return false' href="./help/conf.html#re"><small>Aide<small></a>
      </td>
    </tr>
    <tr>
      <td valign="Top" width="30%" align="Right">Utilisateur HTTP:<br>
      </td>
      <td valign="Top"><input type=text name="global_user" value="{GLOBAL_USER}" size=60>
      <a onClick='window.open("./help/conf.html#uh", "help", "toolbar=no,menubar=no,scrollbars=yes,width=400,height=300,resizable=yes"); return false' href="./help/conf.html#uh"><small>Aide<small></a>
      </td>
    </tr>
    <tr>
      <td valign="Top" width="30%" align="Right">Proxy:<br>
      </td>
      <td valign="Top"><input type=text name="global_proxy" value="{GLOBAL_PROXY}" size=60>
      <a onClick='window.open("./help/conf.html#pr", "help", "toolbar=no,menubar=no,scrollbars=yes,width=400,height=300,resizable=yes"); return false' href="./help/conf.html#pr"><small>Aide<small></a>
      </td>
    </tr>
    <tr>
      <td valign="Top" width="30%" align="Right">Utilisateur Proxy:<br>
      </td>
      <td valign="Top"><input type=text name="global_proxyuser" value="{GLOBAL_PROXYUSER}" size=60>
      <a onClick='window.open("./help/conf.html#up", "help", "toolbar=no,menubar=no,scrollbars=yes,width=400,height=300,resizable=yes"); return false' href="./help/conf.html#up"><small>Aide<small></a>
      </td>
    </tr>
    <tr>
      <td valign="Top" width="30%" align="Right">D&eacute;boggage:<br>
      </td>
      <td valign="Top"><input type=text name="global_debug" value="{GLOBAL_DEBUG}" size=2>
      <a onClick='window.open("./help/conf.html#deb", "help", "toolbar=no,menubar=no,scrollbars=yes,width=400,height=300,resizable=yes"); return false' href="./help/conf.html#deb"><small>Aide<small></a>
      </td>
    </tr>
    <tr>
      <td valign="Top" width="30%" align="Right">D&eacute;sactiver ce site:<br>
      </td>
      <td valign="Top"><input type=text name="global_skip" value="{GLOBAL_SKIP}" size=2>
      <a onClick='window.open("./help/conf.html#des", "help", "toolbar=no,menubar=no,scrollbars=yes,width=400,height=300,resizable=yes"); return false' href="./help/conf.html#des"><small>Aide<small></a>
      </td>
    </tr>
  </tbody>
</table>
<br><br>
<center>
<input type=submit name="save" value="Modifier la configuration"> &nbsp;
<input type=submit name="mainmenu" value="Retour au menu principal"> &nbsp;
<input type=submit name="delete" value="Effacer la configuration"></center>
</form>
<br>
<br>
</div>
{FOOTER}
</body>
</html>
