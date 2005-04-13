<FORM ACTION="gen_conf.cgi" METHOD="POST">

<INPUT TYPE="hidden" NAME="advanced" VALUE="1">
<INPUT TYPE="hidden" NAME="register" VALUE="1">

<TABLE ALIGN="CENTER" BORDER="1">
  <TR>
    <TD BGCOLOR="#e2e2e2">
<B>Fichier <tt>config.pl</tt> : </B>
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
      <INPUT TYPE="submit" VALUE="Appliquer">
      <INPUT TYPE="button" VALUE="Annuler" onClick="window.location.href='gen_conf.cgi';">
    </TD>
  </TR>
</TABLE>
</FORM>
<!-- BEGIN fin_menu -->
<!-- quelque chose qui remplace la fin de menu -->
</div>
