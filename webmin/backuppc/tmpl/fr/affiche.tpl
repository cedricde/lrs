<BR>
  <TABLE BORDER=1 CELLPADDING=5 ALIGN="center">
    <TR>
      <TH BGCOLOR="#e2e2e2">
        <TABLE WIDTH="100%" CELLPADDING="5"><TR>
	   <TH ALIGN="LEFT" BGCOLOR="#e2e2e2">Fichier de configuration de {HOST}</TH>
           <TH WIDTH="25%" BGCOLOR="#ffffff"><A HREF="host_config.cgi{GET_DATA_BREF}">Changer la configuration</A></TH>
        </TR></TABLE>
      </TH>
    </TR>
    <TR ALIGN="left">
      <TD COLSPAN="2">
        $Conf{XferMethod} = '{XFERMETHOD}';<BR><BR>
	
        <!-- BEGIN smb -->
	  $Conf{SmbShareName} = {SHARES_STR};<BR><BR>
	  $Conf{SmbShareUserName} = '{USERNAME}';<BR>
	  $Conf{SmbSharePasswd} = '{PASSWD}';<BR>
        <!-- END smb -->
	
	<!-- BEGIN tar -->
	  $Conf{TarShareName} = {SHARES_STR};<BR><BR>
          $Conf{TarClientCmd} = '/usr/bin/env LANG=en $tarPath -c -v -f - -C $shareName --totals';<BR><BR>
	<!-- END tar -->

	<!-- BEGIN tarssh -->
	  $Conf{TarShareName} = {SHARES_STR};<BR><BR>
	<!-- END tarssh -->

	<!-- BEGIN rsync -->
	  $Conf{RsyncShareName} = {SHARES_STR};<BR>
        <!-- END rsync -->

         <!-- BEGIN rsyncd -->
	  $Conf{RsyncShareName} = {SHARES_STR};<BR><BR>
	  $Conf{RsyncdShareUserName} = '{USERNAME}';<BR>
	  $Conf{RsyncdSharePasswd} = '{PASSWD}';<BR>
        <!-- END rsyncd -->

       <BR>
        $Conf{FullPeriod} = {FULL};<BR>
        $Conf{IncrPeriod} = {INCR};<BR><BR>
        $Conf{BlackoutHourBegin} = {BLACKOUT_BEGIN};<BR>
        $Conf{BlackoutHourEnd} = {BLACKOUT_END};<BR>
        $Conf{BlackoutWeekDays} = [{BLACKOUT_DAYS}];<BR>
      </TD>
    </TR>
 </TABLE>
<BR>


