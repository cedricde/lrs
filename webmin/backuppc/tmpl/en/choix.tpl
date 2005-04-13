<BR>
<FORM METHOD="post" ACTION="host_config.cgi{GET_DATA}">

  <TABLE BORDER=1 CELLPADDING=5 ALIGN="center">
    <TR BGCOLOR="#e2e2e2">
      <TH ALIGN="left">Shared folders of {HOST}</TH>
    </TR>
    <TR ALIGN="center">
      <TD>Backup method: <B>{XFERMETHOD_NAME}</B></TD>
    </TR>
    
    <TR ALIGN="center" VALIGN="top">
      <TD>
      
      
      <TABLE CELLPADDING="0" WIDTH="100%" class="noborder">  
 	<!-- BEGIN warning_row -->
	<TR>
	  <TD COLSPAN=3 ALIGN="center" class="noborder">
	    <FONT COLOR="#FF0000">{EMPTY_LIST}</FONT>
	  </TD>
	</TR>
	<!-- END warning_row -->
	<TR>
          <TD ALIGN="LEFT" VALIGN="top" class="noborder">Shared folders:<BR><BR>
            <INPUT TYPE="text" NAME="new_share"><BR>
            <INPUT TYPE="button" VALUE="Add" onClick="window.location.href='choix.cgi{GET_DATA}&add='+new_share.value">
          </TD>
	  <TD COLSPAN="2" class="noborder">
 	  <!-- BEGIN found_share_row -->
            <INPUT TYPE="checkbox" NAME="found_shares[]" {SHARE_CHECKED} VALUE="{SHARE}" onClick="window.location.href='choix.cgi{GET_DATA}&found_change='+this.checked+'&found_name='+this.value">{SHARE}<BR>
	  <!-- onChange -->
	  <!-- END found_share_row -->
	  </TD>
 	</TR>
        <TR>
	  <TD ALIGN="RIGHT" VALIGN="top" class="noborder">
            <INPUT TYPE="button" VALUE="Delete" onClick="window.location.href='choix.cgi{GET_DATA}&delete='+added_shares.value">
	  </TD>
	  <TD class="noborder">
	    <SELECT NAME="added_shares" SIZE="{SHARE_SIZE}">
	    <!-- BEGIN added_share_row -->
	      <OPTION VALUE="{SHARE}">{SHARE}
	    <!-- END added_share_row -->
	    </SELECT>
	  </TD>
	</TR>

      </TABLE> 
	  

      </TD>
    </TR>
    	<TR>	    
	  <TD ALIGN="center" VALIGN="bottom">
	    <INPUT TYPE="submit" VALUE="Apply">
	    <INPUT TYPE="button" VALUE="Cancel" onClick="window.location.href='host_config.cgi{GET_DATA_BREF}';">
          </TD>
	</TR>
  </TABLE>
      </FORM>

  <BR>
<BR>
