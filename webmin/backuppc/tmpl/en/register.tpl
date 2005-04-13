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
<TABLE ALIGN="CENTER" BORDER="1" WIDTH="55%">
  <TR>
    <TD>
<B>Following parameters have been changed:</B>
    </TD>
    <TD BGCOLOR="#e2e2e2" ALIGN= "CENTER">
      <A HREF="index.cgi">Reconfiguration</A>
    </TD>
  </TR>
  <TR>
    <TD COLSPAN="2">
      <TT>
<!-- BEGIN std_conf -->
<PRE>
  $Conf{WakeupSchedule} = [{WAKEUP}];<BR>
  $Conf{MaxBackups} = {MAXBACKUPS};<BR>
  $Conf{BlackoutHourBegin} = {BLACKOUT_BEGIN};<BR>
  $Conf{BlackoutHourEnd} = {BLACKOUT_END};<BR>
  $Conf{BlackoutWeekDays} = [{BLACKOUT_DAYS}];<BR>
  $Conf{DHCPAddressRanges} = [{DHCPS}];
</PRE>
<!-- END std_conf -->
<!-- BEGIN adv_conf -->
<PRE>
{CONFIG_PL}
</PRE>
<!-- END adv_conf -->
      </TT>
    </TD>
  </TR>
</TABLE>
<!-- BEGIN fin_menu -->
<!-- quelque chose qui remplace la fin de menu -->
</div>
{FIN_MENU}
<!-- END fin_menu -->
<BR>

