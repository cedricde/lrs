<script type="text/javascript" language="JavaScript" src="backuppc.js"></script>

<BR>
<FORM METHOD="post" ACTION="affiche.cgi{GET_DATA}" name="backuppc_configform">
  <input type="hidden" name="host" value="{HOST}">
  <input type="hidden" name="mac" value="{MAC}">
  <input type="hidden" name="shares" value="{SHARES}">
  <table cellpadding="2" cellspacing="0" border="0" width="100%" class="cadre">
    <tr>
      <td bgcolor="#e2e2e2">&nbsp;<font face="arial" size="3"><b>Configuration de la sauvegarde</b></font></td>
    </tr>
  </table> 
  <p>
    <ul>
      <li> 
        <a HREF="" onClick="window.open('/help.cgi/backuppc3/index#xfer','help','width=450,height=250,scrollbars=yes')" ALT="Aide" TITLE="Aide"><IMG SRC="images/qm.png" BORDER="0"></A> M&eacute;thode de sauvegarde :
	<SELECT NAME="xfermethod" onChange="window.location.href='host_config.cgi{GET_DATA_BREF}&xfermethod='+this.value">
          <OPTION {SMBSELECTED} VALUE="smb">Windows (smb)
          <OPTION {TARSELECTED} VALUE="tar">Unix (NFS)
          <OPTION {TARSSHSELECTED} VALUE="tarssh">Tar SSH
          <OPTION {RSYNCSELECTED} VALUE="rsync">Sauvegarde distante (rsync)
          <OPTION {RSYNCDSELECTED} VALUE="rsyncd">Sauvegarde distante mode démon (rsyncd)
        </SELECT>
<!-- BEGIN user_pass -->   
        <ul>
          <li>Nom d'utilisateur : <INPUT TYPE="text" NAME="username" VALUE="{USERNAME}"></li>
          <li>Mot de passe : <INPUT TYPE="password" NAME="passwd" VALUE="{PASSWD}"></li>
        </ul>
<!-- END user_pass -->
      </li>
      <li>
        <a HREF="" onClick="window.open('/help.cgi/backuppc3/index#shares','help','width=450,height=250,scrollbars=yes')" ALT="Aide" TITLE="Aide"><IMG SRC="images/qm.png" BORDER="0"></A> Dossiers partag&eacute;s :
	  <UL>
              <!-- BEGIN share_row -->
            <li>
                 {SHARE}
            </li>
              <!-- END share_row -->
	  </UL>
            <input type="submit" onClick="ChangeActionChoix('');" value="Ajouter">
      </li>
      <!-- BEGIN auth_ssh -->
      <li>
        <a HREF="" onClick="window.open('/help.cgi/backuppc3/index#ssh','help','width=450,height=250,scrollbars=yes')" ALT="Aide" TITLE="Aide"><IMG SRC="images/qm.png" BORDER="0"></A> Authentification par SSH : 

        <!-- BEGIN ssh_key -->    
        Charger <A HREF="host_config.cgi{GET_DATA}&ssh_key=download">BackupPC_id_rsa.pub</a>.
        <!-- END ssh_key -->
        <!-- BEGIN ssh_key_gen -->    
        <br>Vous devez cr&eacute;er <FONT COLOR="#FF0000">la cl&eacute; SSH</FONT>. 
        <INPUT TYPE="button" VALUE="Cr&eacute;er" onClick="window.location.href='host_config.cgi{GET_DATA}&ssh_key=generate'"></p>
        <!-- END ssh_key_gen -->
      </li>
      <!-- END auth_ssh -->
    </ul>
  </p>
  <table cellpadding="2" cellspacing="0" border="0" width="100%" class="cadre" style="margin-top:1em;">
    <tr>
      <td bgcolor="#e2e2e2">&nbsp;<font face="arial" size="3"><b>P&eacute;riode entre les sauvegardes</b></font>
        <a HREF="" onClick="window.open('/help.cgi/backuppc3/index#periods','help','width=450,height=250,scrollbars=yes')" ALT="Aide" TITLE="Aide"><IMG SRC="images/qm.png" BORDER="0"></A>
      </td>
    </tr>
  </table>
  <p> 
    <ul>
      <li>Compl&egrave;te : <INPUT style="vertical-align:middle;" TYPE="text" NAME="full" VALUE="{FULL}" SIZE="10"> , 
        &nbsp;&nbsp;&nbsp;&nbsp;Incr&eacute;mentale : 
        <INPUT style="vertical-align:middle" TYPE="text" NAME="incr" VALUE="{INCR}" SIZE="10"></li>
<!--      <li>
        <a HREF="" onClick="window.open('/help.cgi/backuppc3/index#blackout','help','width=450,height=250,scrollbars=yes')" ALT="Aide" TITLE="Aide"><IMG SRC="images/qm.png" BORDER="0"></a>
        Ne pas sauvegarder entre : <INPUT TYPE="text" NAME="blackout_begin" VALUE="{BLACKOUT_BEGIN}" SIZE="3" style="vertical-align:middle;">h.
  et <INPUT TYPE="text" NAME="blackout_end" VALUE="{BLACKOUT_END}" SIZE="3" style="vertical-align:middle;">h. pour les jours suivants :
        <div style="border:1px solid #EA4F26;padding-left:1em;">
	  Dimanche<INPUT TYPE="CHECKBOX" NAME="blackout_days[]" VALUE="0" style="vertical-align:middle;margin-right:1em;" {CHECKED_0}> 
	  Lundi<INPUT TYPE="CHECKBOX" NAME="blackout_days[]" VALUE="1" style="vertical-align:middle;margin-right:1em;" {CHECKED_1}>
 	  Mardi<INPUT TYPE="CHECKBOX" NAME="blackout_days[]" VALUE="2" style="vertical-align:middle;margin-right:1em;" {CHECKED_2}> 
	  Mercredi<INPUT TYPE="CHECKBOX" NAME="blackout_days[]" VALUE="3" style="vertical-align:middle;margin-right:1em;" {CHECKED_3}>
	  Jeudi<INPUT TYPE="CHECKBOX" NAME="blackout_days[]" VALUE="4" style="vertical-align:middle;margin-right:1em;" {CHECKED_4}> 
	  Vendredi<INPUT TYPE="CHECKBOX" NAME="blackout_days[]" VALUE="5" style="vertical-align:middle;margin-right:1em;" {CHECKED_5}> 
	  Samedi<INPUT TYPE="CHECKBOX" NAME="blackout_days[]" VALUE="6" style="vertical-align:middle;margin-right:1em;" {CHECKED_6}> 
        </div>
      </li> -->
    </ul>
  </p>
  <table cellpadding="2" cellspacing="0" border="0" width="100%" class="cadre">
    <tr>
      <td bgcolor="#e2e2e2">&nbsp;<font face="arial" size="3"><b>{HOST} : IP dynamique</b></font>
        <a HREF="" onClick="window.open('/help.cgi/backuppc3/index#dhcp','help','width=450,height=250,scrollbars=yes')" ALT="Aide" TITLE="Aide"><IMG SRC="images/qm.png" BORDER="0"></A>
      </td>
    </tr>
  </table>
    <ul>
      <input name="dhcp" type="radio" VALUE="0" {0_SELECTED} onChange="window.location.href='host_config.cgi{GET_DATA}&dhcp='+this.value" 
         style="vertical-align:middle;">Non</option>
      <input name="dhcp" type="radio" VALUE="1" {1_SELECTED} onChange="window.location.href='host_config.cgi{GET_DATA}&dhcp='+this.value"
         style="vertical-align:middle;">Oui</option>
  </ul>

  <div align="center">
    <INPUT TYPE="submit" VALUE="Appliquer">
    <INPUT TYPE="button" VALUE="Annuler" onClick="window.location.href='host_config.cgi{GET_DATA}&restore=1'">
  </div>
</FORM>
<BR>
<BR>
