<!-- BEGIN menu -->
<!-- quelque chose qui remplace le menu -->
<table border="0" cellspacing="0" cellpadding="0" width="20%">
<tr> <th bgcolor="#ffffff">&nbsp;</th>
     <th STYLE="border-style: solid; border-top-width:0px; border-right-width:0px; 
                border-left-width:0px; border-bottom-width:0px;	border-top-color:#35b4c3;
		border-bottom-color:#35b4c3; border-left-color:#35b4c3;	border-right-color:#35b4c;
		background-color : #35b4c3;">
	<font color="#0000ee"><a href="index.cgi?general=1">Liste des Machines</a></font></th>
</tr>
</table>
<div STYLE="border-style : solid; border-top-width : 1px; border-right-width : 1px; 
            border-bottom-width : 1px; border-left-width : 1px; border-color: #35b4c3;
            padding: 5px;"> 
{MENU}
<!-- END menu -->
<BR>
<FORM NAME="main_form" METHOD="post" ACTION="gen_conf.cgi">

<INPUT TYPE="hidden" NAME="submitted" VALUE="1">
<INPUT TYPE="hidden" NAME="register" VALUE="0">

  <TABLE BORDER=1 CELLPADDING=5 ALIGN="center">
  
    <TR>
      <TH ALIGN="left">Configuration générale</TH>
      <TD BGCOLOR="#e2e2e2"><A HREF="adv_conf.cgi">Configuration avancée</A></TD>
    </TR>
  
    <TR>
      <TD COLSPAN="2">
      <A HREF="" onClick="window.open('/help.cgi/backuppc/index#wakeup','help','width=400,height=250,scrollbars=yes')" ALT="Aide" TITLE="Aide"><IMG SRC="images/qm.png" BORDER="0"></A>
      Horaires de réveil : <INPUT TYPE="text" NAME="wakeup" VALUE="{WAKEUP}">
      <INPUT TYPE="button" VALUE="Configurer" onClick="window.open('wakeup.cgi','wake_up','width=450,height=200,resizable=yes')">
     </TD>
    </TR>
    <TR>
      <TD COLSPAN="2">
       <A HREF="" onClick="window.open('/help.cgi/backuppc/index#maxbackups','help','width=450,height=250,scrollbars=yes')" ALT="Aide" TITLE="Aide"><IMG SRC="images/qm.png" BORDER="0"></A>
        Nombre max. de sauvegardes simultanés : <INPUT TYPE="text" NAME="maxbackups" VALUE="{MAXBACKUPS}" SIZE="3">
      </TD>
    </TR>
    <TR>
      <TD COLSPAN="2">
           <A HREF="" onClick="window.open('/help.cgi/backuppc/index#blackou','help','width=450,height=250,scrollbars=yes')" ALT="Aide" TITLE="Aide"><IMG SRC="images/qm.png" BORDER="0"></A>
           Ne pas contacter entre : <INPUT TYPE="text" NAME="blackoutbegin" VALUE="{BLACKOUT_BEGIN}" SIZE="3">
           et <INPUT TYPE="text" NAME="blackoutend" VALUE="{BLACKOUT_END}" SIZE="3"><BR>
	   <TABLE>
	     <TR>
	       <TD VALIGN="TOP">
               Ne pas contacter les jours : 
	       </TD>
	       <TD>
               <TABLE BORDER="1" CELLSPACING="0" CELLPADDING="0"><TR><TD>
	         <INPUT TYPE="CHECKBOX" NAME="blackout[]" VALUE="0" {CHECKED_0}>Dimanche<BR>
	         <INPUT TYPE="CHECKBOX" NAME="blackout[]" VALUE="1" {CHECKED_1}>Lundi<BR>
 	         <INPUT TYPE="CHECKBOX" NAME="blackout[]" VALUE="2" {CHECKED_2}>Mardi<BR>
	         <INPUT TYPE="CHECKBOX" NAME="blackout[]" VALUE="3" {CHECKED_3}>Mercredi<BR></TD><TD>
	         <INPUT TYPE="CHECKBOX" NAME="blackout[]" VALUE="4" {CHECKED_4}>Jeudi<BR>
	         <INPUT TYPE="CHECKBOX" NAME="blackout[]" VALUE="5" {CHECKED_5}>Vendredi<BR>
	         <INPUT TYPE="CHECKBOX" NAME="blackout[]" VALUE="6" {CHECKED_6}>Samedi
	      </TD></TR></TABLE>
	    </TD>
	  </TR>
	</TABLE>
      </TD>
    </TR>
    <TR>
      <TD COLSPAN="2">
           <A HREF="" onClick="window.open('/help.cgi/backuppc/index#dhcplist','help','width=450,height=250,scrollbars=yes')" ALT="Aide" TITLE="Aide"><IMG SRC="images/qm.png" BORDER="0"></A>
          Intervalles d'adresses DHCP :<BR> 
          <INPUT TYPE="text" NAME="dhcpbase1" VALUE="{DHCP_BASE1}" SIZE="3" MAXLENGTH="3">.
          <INPUT TYPE="text" NAME="dhcpbase2" VALUE="{DHCP_BASE2}" SIZE="3" MAXLENGTH="3">.
          <INPUT TYPE="text" NAME="dhcpbase3" VALUE="{DHCP_BASE3}" SIZE="3" MAXLENGTH="3">.
          <SELECT NAME="dhcpfirst" SIZE="1">{DHCP_FIRST}</SELECT>-<SELECT NAME="dhcplast" SIZE="1">{DHCP_LAST}</SELECT>
	  <INPUT TYPE="hidden" NAME="add_dhcp" VALUE="0">
          <INPUT TYPE="button" VALUE="Ajouter" onClick="add_dhcp.value=1; main_form.submit()">
	    <TABLE><TR><TD VALIGN="TOP">
	      Adresses : 
	    </TD><TD>
	      <INPUT TYPE="hidden" NAME="affiche_dhcp" VALUE="0">
 	      <SELECT NAME="dhcp" SIZE="{DHCPS_SIZE}" onChange="affiche_dhcp.value=1; main_form.submit()">
  	              <!-- BEGIN dhcp_row -->
	                <OPTION {DHCP_SELECTED}>{DHCP_ADDR}
	              <!-- END dhcp_row -->
	      </SELECT>
	              <!-- BEGIN dhcp_hidden_row -->
			<INPUT TYPE="hidden" NAME={DHCP_NAME} VALUE={DHCP_ADDR}>
	              <!-- END dhcp_hidden_row -->
           </TD><TD VALIGN="TOP">
	     <INPUT TYPE="hidden" NAME="delete_dhcp" VALUE="0">
             <INPUT TYPE="button" VALUE="Supprimer" onClick="delete_dhcp.value=1; main_form.submit()">
	   </TD></TR></TABLE>
	</TD>
    </TR>
    <TR>	    
      <TD COLSPAN="2" ALIGN="center" VALIGN="bottom">
        <INPUT TYPE="button" VALUE="Appliquer" onClick="register.value=1; main_form.submit()">
        <INPUT TYPE="button" VALUE="Annuler" onClick="window.location.href='gen_conf.cgi';">
      </TD>
    </TR>
  </TABLE>
</FORM>
<BR>
<!-- BEGIN fin_menu -->
<!-- quelque chose qui remplace la fin de menu -->
</div>
{FIN_MENU}
<!-- END fin_menu -->
<BR>
