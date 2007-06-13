<!-- BEGIN menu -->
<!-- quelque chose qui remplace le menu -->
{MENU}
<!-- END menu -->
<TABLE ALIGN="CENTER" BORDER="1" WIDTH="55%">
  <TR>
    <TD>
<B>Following parameters have been changed:</B>
    </TD>
    <TD BGCOLOR="#e2e2e2" ALIGN= "CENTER">
      <A HREF="gen_conf.cgi">Configure again</A>
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
{FIN_MENU}
<!-- END fin_menu -->
<BR>

