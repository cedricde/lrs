<!-- BEGIN all -->
<h2>Backup the LRS configuration</h2>
<p>If you modified the LRS system configuration (in /etc), 
you can backup the most important configuration files to
/tftpboot/revoboot/backup/. Then, if you have a tape backup of /tftpboot, 
you'll be able to restore the LRS configuration after a system crash.</p>
<form><input type=submit name="saveconf" value="Backup the LRS"></form>

<h2>Restore the LRS configuration</h2>
<p>Last backup: {LAST}</p>

<form><input type=submit name="loadconf" value="Restore the last configuration"></form>

<!-- END all -->