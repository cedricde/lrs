<BR>
<FORM METHOD="post" ACTION="affiche.cgi{GET_DATA}" name="backuppc_configform">

  <table cellpadding="2" cellspacing="0" border="0" width="100%" class="cadre">
    <tr>
      <td bgcolor="#e2e2e2">&nbsp;<font face="arial" size="3"><b>Backup configuration</b></font></td>
    </tr>
  </table> 
  <p>
    <ul>
      <li> 
        <a HREF="" onClick="window.open('/help.cgi/backuppc/index#xfer','help','width=450,height=250,scrollbars=yes')" ALT="Aide" TITLE="Aide"><IMG SRC="images/qm.png" BORDER="0"></A> Backup method :
	<SELECT NAME="xfermethod" onChange="window.location.href='host_config.cgi{GET_DATA_BREF}&xfermethod='+this.value">
          <OPTION {SMBSELECTED} VALUE="smb">Windows (smb)
          <OPTION {TARSELECTED} VALUE="tar">Unix (NFS)
          <OPTION {TARSSHSELECTED} VALUE="tarssh">Tar SSH
          <OPTION {RSYNCSELECTED} VALUE="rsync">Distant backup (rsync)
          <OPTION {RSYNCDSELECTED} VALUE="rsyncd">Distant backup daemon (rsyncd)
        </SELECT>
<!-- BEGIN user_pass -->   
        <ul>
          <li>Username : <INPUT TYPE="text" NAME="username" VALUE="{USERNAME}"></li>
          <li>Password : <INPUT TYPE="password" NAME="passwd" VALUE="{PASSWD}"></li>
        </ul>
<!-- END user_pass -->
      </li>
      <li>
        <a HREF="" onClick="window.open('/help.cgi/backuppc/index#shares','help','width=450,height=250,scrollbars=yes')" ALT="Aide" TITLE="Aide"><IMG SRC="images/qm.png" BORDER="0"></A> Shared folders :
	  <UL>
            <li>
              <!-- BEGIN share_row -->
                 {SHARE},
              <!-- END share_row -->
              ... 
              <!-- BEGIN user_pass_configure -->
              <a href="#" onClick="window.location.href='choix.cgi{GET_DATA}&username='+document.backuppc_configform.username.value+'&passwd='+document.backuppc_configform.passwd.value">( Configure )</a>
              <!-- END user_pass_configure -->
              <!-- BEGIN configure -->
              <a href="#" onClick="window.location.href='choix.cgi{GET_DATA}'">( Configure )</a>
              <!-- END configure -->
            </li>
          </UL>
      </li>
      <!-- BEGIN auth_ssh -->
      <li>
        <a HREF="" onClick="window.open('/help.cgi/backuppc/index#ssh','help','width=450,height=250,scrollbars=yes')" ALT="Aide" TITLE="Aide"><IMG SRC="images/qm.png" BORDER="0"></A> SSH authentication : 

        <!-- BEGIN ssh_key -->    
        Download <A HREF="host_config.cgi{GET_DATA}&ssh_key=download">BackupPC_id_rsa.pub</a>.
        <!-- END ssh_key -->
        <!-- BEGIN ssh_key_gen -->    
        <br>You need to create the <FONT COLOR="#FF0000">SSH key</FONT>. 
        <INPUT TYPE="button" VALUE="Create" onClick="window.location.href='host_config.cgi{GET_DATA}&ssh_key=generate'"></p>
        <!-- END ssh_key_gen -->
      </li>
      <!-- END auth_ssh -->
    </ul>
  </p>
  <table cellpadding="2" cellspacing="0" border="0" width="100%" class="cadre" style="margin-top:1em;">
    <tr>
      <td bgcolor="#e2e2e2">&nbsp;<font face="arial" size="3"><b>Backup periods</b></font>
        <a HREF="" onClick="window.open('/help.cgi/backuppc/index#periods','help','width=450,height=250,scrollbars=yes')" ALT="Aide" TITLE="Aide"><IMG SRC="images/qm.png" BORDER="0"></A>
      </td>
    </tr>
  </table>
  <p> 
    <ul>
      <li>Full : <INPUT style="vertical-align:middle;" TYPE="text" NAME="full" VALUE="{FULL}" SIZE="10"> , 
        &nbsp;&nbsp;&nbsp;&nbsp;Incremental : 
        <INPUT style="vertical-align:middle" TYPE="text" NAME="incr" VALUE="{INCR}" SIZE="10"></li>
      <li>
        <a HREF="" onClick="window.open('/help.cgi/backuppc/index#blackout','help','width=450,height=250,scrollbars=yes')" ALT="Aide" TITLE="Aide"><IMG SRC="images/qm.png" BORDER="0"></a>
        Do not backup from : <INPUT TYPE="text" NAME="blackout_begin" VALUE="{BLACKOUT_BEGIN}" SIZE="3" style="vertical-align:middle;">h.
  to <INPUT TYPE="text" NAME="blackout_end" VALUE="{BLACKOUT_END}" SIZE="3" style="vertical-align:middle;">h. during these days :
        <div style="border:1px solid #EA4F26;padding-left:1em;">
	  Sunday<INPUT TYPE="CHECKBOX" NAME="blackout_days[]" VALUE="0" style="vertical-align:middle;margin-right:1em;" {CHECKED_0}> 
	  Monday<INPUT TYPE="CHECKBOX" NAME="blackout_days[]" VALUE="1" style="vertical-align:middle;margin-right:1em;" {CHECKED_1}>
 	  Tuesday<INPUT TYPE="CHECKBOX" NAME="blackout_days[]" VALUE="2" style="vertical-align:middle;margin-right:1em;" {CHECKED_2}> 
	  Wednesday<INPUT TYPE="CHECKBOX" NAME="blackout_days[]" VALUE="3" style="vertical-align:middle;margin-right:1em;" {CHECKED_3}>
	  Thursday<INPUT TYPE="CHECKBOX" NAME="blackout_days[]" VALUE="4" style="vertical-align:middle;margin-right:1em;" {CHECKED_4}> 
	  Friday<INPUT TYPE="CHECKBOX" NAME="blackout_days[]" VALUE="5" style="vertical-align:middle;margin-right:1em;" {CHECKED_5}> 
	  Saturday<INPUT TYPE="CHECKBOX" NAME="blackout_days[]" VALUE="6" style="vertical-align:middle;margin-right:1em;" {CHECKED_6}> 
        </div>
      </li>
    </ul>
  </p>
  <table cellpadding="2" cellspacing="0" border="0" width="100%" class="cadre">
    <tr>
      <td bgcolor="#e2e2e2">&nbsp;<font face="arial" size="3"><b>Is {HOST} using DHCP</b></font>
        <a HREF="" onClick="window.open('/help.cgi/backuppc/index#dhcp','help','width=450,height=250,scrollbars=yes')" ALT="Aide" TITLE="Aide"><IMG SRC="images/qm.png" BORDER="0"></A>
      </td>
    </tr>
  </table>
    <ul>
      <input name="dhcp" type="radio" VALUE="0" {0_SELECTED} onChange="window.location.href='host_config.cgi{GET_DATA}&dhcp='+this.value" 
         style="vertical-align:middle;">No</option>
      <input name="dhcp" type="radio" VALUE="1" {1_SELECTED} onChange="window.location.href='host_config.cgi{GET_DATA}&dhcp='+this.value"
         style="vertical-align:middle;">Yes</option>
  </ul>

  <div align="center">
    <INPUT TYPE="submit" VALUE="Apply">
    <INPUT TYPE="button" VALUE="Cancel" onClick="window.location.href='host_config.cgi{GET_DATA}&restore=1'">
  </div>
</FORM>
<BR>
<BR>
