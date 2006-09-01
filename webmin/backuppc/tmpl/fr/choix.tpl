<BR>
<FORM METHOD="post" ACTION="host_config.cgi{GET_DATA}">
  <INPUT TYPE="hidden" NAME="username" VALUE="{USERNAME}">
  <INPUT TYPE="hidden" NAME="passwd" VALUE="{PASSWD}">
  <INPUT TYPE="hidden" NAME="mac" VALUE="{MAC}">
  <INPUT TYPE="hidden" NAME="host" VALUE="{HOST}">

  <TABLE BORDER=1 CELLPADDING=5 ALIGN="center">
    <TR BGCOLOR="#e2e2e2">
      <TH ALIGN="left">Partages de {HOST}</TH>
    </TR>
    <TR ALIGN="center">
      <TD>M&eacute;thode de sauvegarde : <B>{XFERMETHOD_NAME}</B></TD>
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
          <TD ALIGN="LEFT" VALIGN="top" class="noborder">Partages :<BR><BR>
            <INPUT TYPE="text" NAME="new_share"><BR>
            <INPUT TYPE="button" VALUE="Ajouter" onClick="window.location.href='choix.cgi{GET_DATA}&add='+new_share.value">
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
            <INPUT TYPE="button" VALUE="Supprimer" onClick="window.location.href='choix.cgi{GET_DATA}&delete='+added_shares.value">
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
	    <INPUT TYPE="submit" VALUE="Appliquer">
	    <INPUT TYPE="button" VALUE="Annuler" onClick="window.location.href='host_config.cgi{GET_DATA_BREF}';">
          </TD>
	</TR>
  </TABLE>
      </FORM>

  <BR>
<BR>
