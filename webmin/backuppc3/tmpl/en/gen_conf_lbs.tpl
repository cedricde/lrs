<BR>
<FORM NAME="main_form" METHOD="post" ACTION="gen_conf.cgi">
  <INPUT TYPE="hidden" NAME="submitted" VALUE="1">
  <INPUT TYPE="hidden" NAME="register" VALUE="0">
  <table cellpadding="2" cellspacing="0" border="0" width="100%" class="cadre">
    <tr>
      <td bgcolor="#e2e2e2">&nbsp;<font face="arial" size="3"><b>Files backup configuration ( <A HREF="index.cgi?action=editConfig">Advanced configuration</A> )</b></font></td>
    </tr>
  </table>
  <p>
    <ul>
     <li>
        <A HREF="" onClick="window.open('/help.cgi/backuppc/index#wakeup','help','width=400,height=250,scrollbars=yes')"
           ALT="Aide" TITLE="Aide"><IMG SRC="images/qm.png" BORDER="0"></A>
          Wakeup schedule: <INPUT TYPE="text" NAME="wakeup" VALUE="{WAKEUP}" style="vertical-align:middle;">
        <INPUT TYPE="button" VALUE="Configure" onClick="window.open('wakeup.cgi','wake_up','width=450,height=200,resizable=yes')"
         style="vertical-align:middle;">
     </li>
     <li>
       <A HREF="" onClick="window.open('/help.cgi/backuppc/index#maxbackups','help','width=450,height=250,scrollbars=yes')"
          ALT="Aide" TITLE="Aide"><IMG SRC="images/qm.png" BORDER="0"></A>
        Max. number of simultaneous backups: <INPUT TYPE="text" NAME="maxbackups" VALUE="{MAXBACKUPS}" SIZE="2"
                                                 style="vertical-align:middle;">
     </li>
     <li>Number of backups to keep. 
       Full: <INPUT TYPE="text" NAME="FullKeepCnt" VALUE="{FULLKEEPCNT}" SIZE="3" style="vertical-align:middle;">
       Incremental: <INPUT TYPE="text" NAME="IncrKeepCnt" VALUE="{INCRKEEPCNT}" SIZE="3" style="vertical-align:middle;">
     </li>
     <li>
       <A HREF="" onClick="window.open('/help.cgi/backuppc/index#blackout','help','width=450,height=250,scrollbars=yes')"
          ALT="Aide" TITLE="Aide"><IMG SRC="images/qm.png" BORDER="0"></A>
       Do not contact from: <INPUT TYPE="text" NAME="blackoutbegin" VALUE="{BLACKOUT_BEGIN}" SIZE="3"
                                 style="vertical-align:middle;">h.
       to <INPUT TYPE="text" NAME="blackoutend" VALUE="{BLACKOUT_END}" SIZE="3" style="vertical-align:middle;">h.
       on the following days :
       <div style="border:1px solid #EA4F26;padding-left:1em;">
          Sunday<INPUT TYPE="CHECKBOX" NAME="blackout[]" VALUE="0" style="vertical-align:middle;margin-right:1em;" {CHECKED_0}>
          Monday<INPUT TYPE="CHECKBOX" NAME="blackout[]" VALUE="1" style="vertical-align:middle;margin-right:1em;" {CHECKED_1}>
          Tuesday<INPUT TYPE="CHECKBOX" NAME="blackout[]" VALUE="2" style="vertical-align:middle;margin-right:1em;" {CHECKED_2}>
          Wednesday<INPUT TYPE="CHECKBOX" NAME="blackout[]" VALUE="3" style="vertical-align:middle;margin-right:1em;" {CHECKED_3}>
          Thursday<INPUT TYPE="CHECKBOX" NAME="blackout[]" VALUE="4" style="vertical-align:middle;margin-right:1em;" {CHECKED_4}>
          Friday<INPUT TYPE="CHECKBOX" NAME="blackout[]" VALUE="5" style="vertical-align:middle;margin-right:1em;" {CHECKED_5}>
          Saturday<INPUT TYPE="CHECKBOX" NAME="blackout" VALUE="6" style="vertical-align:middle;margin-right:1em;" {CHECKED_6}>
        </div>
      </li>
    </ul>
  </p>
  <table cellpadding="2" cellspacing="0" border="0" width="100%" class="cadre">
    <tr>
      <td bgcolor="#e2e2e2">&nbsp;<font face="arial" size="3"><b>DHCP configuration</b></font></td>
    </tr>
  </table>
  <p>
    <ul>
      <li>
        <A HREF="" onClick="window.open('/help.cgi/backuppc/index#dhcplist','help','width=450,height=250,scrollbars=yes')"
           ALT="Aide" TITLE="Aide"><IMG SRC="images/qm.png" BORDER="0"></A>
        DHCP pools: 
        <INPUT TYPE="text" NAME="dhcpbase1" VALUE="{DHCP_BASE1}" SIZE="3" MAXLENGTH="3" style="vertical-align:middle;">.
        <INPUT TYPE="text" NAME="dhcpbase2" VALUE="{DHCP_BASE2}" SIZE="3" MAXLENGTH="3" style="vertical-align:middle;">.
        <INPUT TYPE="text" NAME="dhcpbase3" VALUE="{DHCP_BASE3}" SIZE="3" MAXLENGTH="3" style="vertical-align:middle;">.
        <SELECT NAME="dhcpfirst" SIZE="1" style="vertical-align:middle;">{DHCP_FIRST}</SELECT> / 
        <SELECT NAME="dhcplast" SIZE="1" style="vertical-align:middle;">{DHCP_LAST}</SELECT>
	<INPUT TYPE="hidden" NAME="add_dhcp" VALUE="0">
        <INPUT TYPE="button" VALUE="Add" onClick="add_dhcp.value=1; main_form.submit()" style="vertical-align:middle;">
        <ul>
          <li>
            Addresses : 
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
            <INPUT TYPE="button" VALUE="Delete" onClick="delete_dhcp.value=1; main_form.submit()">
          </li>
        </ul>
      </li>
    </ul>
  </p>
  <div ALIGN="center" VALIGN="bottom" style="margin-top:2em;">
        <INPUT TYPE="button" VALUE="Apply" onClick="register.value=1; main_form.submit()">
        <INPUT TYPE="button" VALUE="Cancel" onClick="window.location.href='gen_conf.cgi';">
  </div>
</FORM>
<BR>
