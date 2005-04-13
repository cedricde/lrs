<BR>
<FORM NAME="main_form" METHOD="post" ACTION="index.cgi">

<INPUT TYPE="hidden" NAME="submitted" VALUE="1">
<INPUT TYPE="hidden" NAME="register" VALUE="0">

  <TABLE BORDER=1 CELLPADDING=5 ALIGN="center">
  
    <TR>
      <TH ALIGN="left">General configuration</TH>
      <TD BGCOLOR="#e2e2e2"><A HREF="adv_conf.cgi">Advanced configuration</A></TD>
    </TR>
  
    <TR>
      <TD COLSPAN="2">
      <A HREF="" onClick="window.open('/help.cgi/backuppc/index#wakeup','help','width=400,height=250,scrollbars=yes')" ALT="Help" TITLE="Help"><IMG SRC="images/qm.png" BORDER="0"></A>
      Wakeup schedule: <INPUT TYPE="text" NAME="wakeup" VALUE="{WAKEUP}">
      <INPUT TYPE="button" VALUE="Configure" onClick="window.open('wakeup.cgi','wake_up','width=450,height=200,resizable=yes')">
     </TD>
    </TR>
    <TR>
      <TD COLSPAN="2">
       <A HREF="" onClick="window.open('/help.cgi/backuppc/index#maxbackups','help','width=450,height=250,scrollbars=yes')" ALT="Help" TITLE="Help"><IMG SRC="images/qm.png" BORDER="0"></A>
        Max. number of simultaneous backups: <INPUT TYPE="text" NAME="maxbackups" VALUE="{MAXBACKUPS}" SIZE="3">
      </TD>
    </TR>
    <TR>
      <TD COLSPAN="2">
           <A HREF="" onClick="window.open('/help.cgi/backuppc/index#blackout','help','width=450,height=250,scrollbars=yes')" ALT="Help" TITLE="Help"><IMG SRC="images/qm.png" BORDER="0"></A>
           Do not contact from: <INPUT TYPE="text" NAME="blackoutbegin" VALUE="{BLACKOUT_BEGIN}" SIZE="3">
           to: <INPUT TYPE="text" NAME="blackoutend" VALUE="{BLACKOUT_END}" SIZE="3"><BR>
	   <TABLE>
	     <TR>
	       <TD VALIGN="TOP">
               Do not contact on the days: 
	       </TD>
	       <TD>
               <TABLE BORDER="1" CELLSPACING="0" CELLPADDING="0"><TR><TD>
	         <INPUT TYPE="CHECKBOX" NAME="blackout[]" VALUE="0" {CHECKED_0}>Sunday<BR>
	         <INPUT TYPE="CHECKBOX" NAME="blackout[]" VALUE="1" {CHECKED_1}>Monday<BR>
 	         <INPUT TYPE="CHECKBOX" NAME="blackout[]" VALUE="2" {CHECKED_2}>Tuesday<BR>
	         <INPUT TYPE="CHECKBOX" NAME="blackout[]" VALUE="3" {CHECKED_3}>Wednesday<BR></TD><TD>
	         <INPUT TYPE="CHECKBOX" NAME="blackout[]" VALUE="4" {CHECKED_4}>Thursday<BR>
	         <INPUT TYPE="CHECKBOX" NAME="blackout[]" VALUE="5" {CHECKED_5}>Friday<BR>
	         <INPUT TYPE="CHECKBOX" NAME="blackout[]" VALUE="6" {CHECKED_6}>Saturday
	      </TD></TR></TABLE>
	    </TD>
	  </TR>
	</TABLE>
      </TD>
    </TR>
    <TR>
      <TD COLSPAN="2">
           <A HREF="" onClick="window.open('/help.cgi/backuppc/index#dhcplist','help','width=450,height=250,scrollbars=yes')" ALT="Help" TITLE="Help"><IMG SRC="images/qm.png" BORDER="0"></A>
          DHCP addresses intervals:<BR> 
          <INPUT TYPE="text" NAME="dhcpbase1" VALUE="{DHCP_BASE1}" SIZE="3" MAXLENGTH="3">.
          <INPUT TYPE="text" NAME="dhcpbase2" VALUE="{DHCP_BASE2}" SIZE="3" MAXLENGTH="3">.
          <INPUT TYPE="text" NAME="dhcpbase3" VALUE="{DHCP_BASE3}" SIZE="3" MAXLENGTH="3">.
          <SELECT NAME="dhcpfirst" SIZE="1">{DHCP_FIRST}</SELECT>-<SELECT NAME="dhcplast" SIZE="1">{DHCP_LAST}</SELECT>
	  <INPUT TYPE="hidden" NAME="add_dhcp" VALUE="0">
          <INPUT TYPE="button" VALUE="Add" onClick="add_dhcp.value=1; main_form.submit()">
	    <TABLE><TR><TD VALIGN="TOP">
	      Addresses: 
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
             <INPUT TYPE="button" VALUE="Delete" onClick="delete_dhcp.value=1; main_form.submit()">
	   </TD></TR></TABLE>
	</TD>
    </TR>
    <TR>	    
      <TD COLSPAN="2" ALIGN="center" VALIGN="bottom">
        <INPUT TYPE="button" VALUE="Apply" onClick="register.value=1; main_form.submit()">
        <INPUT TYPE="button" VALUE="Cancel" onClick="window.location.href='gen_conf.cgi';">
      </TD>
    </TR>
  </TABLE>
</FORM>
<BR>
