<HTML>
<meta http-equiv="Content_Type" content="text-html; Charset=iso-8859-1">
<HEAD>
<SCRIPT LANGUAGE="JavaScript">
<!--
function passHours() {
  var str = "";
  var i = 0;
  while (i < 24 && !document.hours_form.elements[i].checked) i++;
  if (i<24) str += i;
  for (var j = i+1; j < 24; j++) {
    if (document.hours_form.elements[j].checked) {
      str += ","+j;
    }
  }
  window.opener.document.main_form.wakeup.value = str;
  window.close(self);
}
// -->
</SCRIPT>

</HEAD>
<BODY>
<FORM NAME="hours_form" METHOD="post" ACTION="wakeup.cgi">
<TABLE RULES="COLS" CELLPADDING="8">
  <TR>
<!-- BEGIN wakeup_row -->
{NEW_COLUMN_START}
<INPUT TYPE="CHECKBOX" NAME="wakeup_tab[]" VALUE="{HOUR}" {HOUR_CHECKED}>{HOUR}h.
<A HREF="wakeup.cgi?start_hour={HOUR}&end_hour={END_HOUR}">from</A>, 
<A HREF="wakeup.cgi?start_hour={START_HOUR}&end_hour={HOUR}">to</A> 
<BR>
{NEW_COLUMN_END}
<!-- END wakeup_row --> 
  </TR>
  <TR ALIGN="CENTER">
    <TD COLSPAN="4">
      <INPUT TYPE="button" VALUE="Apply" onClick="passHours()">
      <INPUT TYPE="button" VALUE="Cancel" onClick="window.close()">
    </TD>
  </TR>
</TABLE>

</FORM>
</BODY>
</HTML>
