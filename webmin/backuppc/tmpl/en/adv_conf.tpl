<!-- BEGIN menu -->
<!-- quelque chose qui remplace le menu -->
<table border="0" cellspacing="0" cellpadding="0" width="20%">
<tr> <th bgcolor="#ffffff">&nbsp;</th>
     <th STYLE="border-style: solid; border-top-width:0px; border-right-width:0px; 
                border-left-width:0px; border-bottom-width:0px;	border-top-color:#35b4c3;
		border-bottom-color:#35b4c3; border-left-color:#35b4c3;	border-right-color:#35b4c;
		background-color : #35b4c3;">
	<font color="#0000ee"><a href="index.cgi?general=1">Return</a></font></th>
</tr>
</table>
<div STYLE="border-style : solid; border-top-width : 1px; border-right-width : 1px; 
            border-bottom-width : 1px; border-left-width : 1px; border-color: #35b4c3;
            padding: 5px;"> 
{MENU}
<!-- END menu -->
<FORM ACTION="index.cgi" METHOD="POST">

<INPUT TYPE="hidden" NAME="advanced" VALUE="1">
<INPUT TYPE="hidden" NAME="register" VALUE="1">

<TABLE ALIGN="CENTER" BORDER="1">
  <TR>
    <TD BGCOLOR="#e2e2e2">
<B>File <tt>config.pl</tt> : </B>
    </TD>
  </TR>
  <TR>
   <TD>
     <TEXTAREA NAME="conf_file" ROWS="35" COLS="90">
     {CONFIG_PL}
     </TEXTAREA>
   </TD>
  </TR>
  <TR>
    <TD ALIGN="CENTER">
      <INPUT TYPE="submit" VALUE="Apply">
      <INPUT TYPE="button" VALUE="Cancel" onClick="window.location.href='index.cgi';">
    </TD>
  </TR>
</TABLE>
</FORM>
<!-- BEGIN fin_menu -->
<!-- quelque chose qui remplace la fin de menu -->
</div>
{FIN_MENU}
<!-- END fin_menu -->
<BR>

