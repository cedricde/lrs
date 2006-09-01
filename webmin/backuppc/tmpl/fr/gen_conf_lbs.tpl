<BR>
<FORM NAME="main_form" METHOD="post" ACTION="gen_conf.cgi">
  <INPUT TYPE="hidden" NAME="submitted" VALUE="1">
  <INPUT TYPE="hidden" NAME="register" VALUE="0">
  <table cellpadding="2" cellspacing="0" border="0" width="100%" class="cadre">
    <tr>
      <td bgcolor="#e2e2e2">&nbsp;<font face="arial" size="3"><b>Configuration de la sauvegarde ( <A HREF="adv_conf.cgi">Configuration avancée</A> )</b></font></td>
    </tr>
  </table>
  <p>
    <ul>
     <li>
        <A HREF="" onClick="window.open('/help.cgi/backuppc/index#wakeup','help','width=400,height=250,scrollbars=yes')"
           ALT="Aide" TITLE="Aide"><IMG SRC="images/qm.png" BORDER="0"></A>
          Horaires de réveil : <INPUT TYPE="text" NAME="wakeup" VALUE="{WAKEUP}" style="vertical-align:middle;">
        <INPUT TYPE="button" VALUE="Configurer" onClick="window.open('wakeup.cgi','wake_up','width=450,height=200,resizable=yes')"
         style="vertical-align:middle;">
     </li>
     <li>
       <A HREF="" onClick="window.open('/help.cgi/backuppc/index#maxbackups','help','width=450,height=250,scrollbars=yes')"
          ALT="Aide" TITLE="Aide"><IMG SRC="images/qm.png" BORDER="0"></A>
        Nombre max. de sauvegardes simultanés : <INPUT TYPE="text" NAME="maxbackups" VALUE="{MAXBACKUPS}" SIZE="2"
                                                 style="vertical-align:middle;">
     </li>
     <li>Nombre de sauvegardes &agrave; garder. 
       Compl&egrave;tes: <INPUT TYPE="text" NAME="FullKeepCnt" VALUE="{FULLKEEPCNT}" SIZE="3" style="vertical-align:middle;">
       Incr&eacute;mentales: <INPUT TYPE="text" NAME="IncrKeepCnt" VALUE="{INCRKEEPCNT}" SIZE="3" style="vertical-align:middle;">
     </li>
     <li>
       <A HREF="" onClick="window.open('/help.cgi/backuppc/index#blackout','help','width=450,height=250,scrollbars=yes')"
          ALT="Aide" TITLE="Aide"><IMG SRC="images/qm.png" BORDER="0"></A>
       Ne pas contacter entre : <INPUT TYPE="text" NAME="blackoutbegin" VALUE="{BLACKOUT_BEGIN}" SIZE="3"
                                 style="vertical-align:middle;">h.
       et <INPUT TYPE="text" NAME="blackoutend" VALUE="{BLACKOUT_END}" SIZE="3" style="vertical-align:middle;">h.
       pour les jours suivants :
       <div style="border:1px solid #EA4F26;padding-left:1em;">
          Dimanche<INPUT TYPE="CHECKBOX" NAME="blackout[]" VALUE="0" style="vertical-align:middle;margin-right:1em;" {CHECKED_0}>
          Lundi<INPUT TYPE="CHECKBOX" NAME="blackout[]" VALUE="1" style="vertical-align:middle;margin-right:1em;" {CHECKED_1}>
          Mardi<INPUT TYPE="CHECKBOX" NAME="blackout[]" VALUE="2" style="vertical-align:middle;margin-right:1em;" {CHECKED_2}>
          Mercredi<INPUT TYPE="CHECKBOX" NAME="blackout[]" VALUE="3" style="vertical-align:middle;margin-right:1em;" {CHECKED_3}>
          Jeudi<INPUT TYPE="CHECKBOX" NAME="blackout[]" VALUE="4" style="vertical-align:middle;margin-right:1em;" {CHECKED_4}>
          Vendredi<INPUT TYPE="CHECKBOX" NAME="blackout[]" VALUE="5" style="vertical-align:middle;margin-right:1em;" {CHECKED_5}>
          Samedi<INPUT TYPE="CHECKBOX" NAME="blackout" VALUE="6" style="vertical-align:middle;margin-right:1em;" {CHECKED_6}>
        </div>
      </li>
    </ul>
  </p>
  <table cellpadding="2" cellspacing="0" border="0" width="100%" class="cadre">
    <tr>
      <td bgcolor="#e2e2e2">&nbsp;<font face="arial" size="3"><b>Configuration DHCP</b></font></td>
    </tr>
  </table>
  <p>
    <ul>
      <li>
        <A HREF="" onClick="window.open('/help.cgi/backuppc/index#dhcplist','help','width=450,height=250,scrollbars=yes')"
           ALT="Aide" TITLE="Aide"><IMG SRC="images/qm.png" BORDER="0"></A>
        Intervalles d'adresses DHCP : 
        <INPUT TYPE="text" NAME="dhcpbase1" VALUE="{DHCP_BASE1}" SIZE="3" MAXLENGTH="3" style="vertical-align:middle;">.
        <INPUT TYPE="text" NAME="dhcpbase2" VALUE="{DHCP_BASE2}" SIZE="3" MAXLENGTH="3" style="vertical-align:middle;">.
        <INPUT TYPE="text" NAME="dhcpbase3" VALUE="{DHCP_BASE3}" SIZE="3" MAXLENGTH="3" style="vertical-align:middle;">.
        <SELECT NAME="dhcpfirst" SIZE="1" style="vertical-align:middle;">{DHCP_FIRST}</SELECT> / 
        <SELECT NAME="dhcplast" SIZE="1" style="vertical-align:middle;">{DHCP_LAST}</SELECT>
	<INPUT TYPE="hidden" NAME="add_dhcp" VALUE="0">
        <INPUT TYPE="button" VALUE="Ajouter" onClick="add_dhcp.value=1; main_form.submit()" style="vertical-align:middle;">
        <ul>
          <li>
            Adresses : 
	    <INPUT TYPE="hidden" NAME="affiche_dhcp" VALUE="0">
 	    <SELECT NAME="dhcp" SIZE="{DHCPS_SIZE}" onChange="affiche_dhcp.value=1; main_form.submit()">
  	      <!-- BEGIN dhcp_row -->
	      <OPTION {DHCP_SELECTED}>{DHCP_ADDR}
	      <!-- END dhcp_row -->
	    </SELECT>
	    <!-- BEGIN dhcp_hidden_row -->
	    <INPUT TYPE="hidden" NAME={DHCP_NAME} VALUE={DHCP_ADDR}>
	    <!-- END dhcp_hidden_row -->
            <INPUT TYPE="hidden" NAME="delete_dhcp" VALUE="0">
            <INPUT TYPE="button" VALUE="Supprimer" onClick="delete_dhcp.value=1; main_form.submit()">
          </li>
        </ul>
      </li>
    </ul>
  </p>
  <div ALIGN="center" VALIGN="bottom" style="margin-top:2em;">
        <INPUT TYPE="button" VALUE="Appliquer" onClick="register.value=1; main_form.submit()">
        <INPUT TYPE="button" VALUE="Annuler" onClick="window.location.href='gen_conf.cgi';">
  </div>
</FORM>
<BR>
