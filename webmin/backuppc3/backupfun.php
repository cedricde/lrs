<?
#
# Linbox Rescue Server
# Copyright (C) 2005  Linbox FAS
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.


/* read hosts' names from the /etc/backuppc hosts file 
 * return hosts' names list
 */
function readBackupHosts() {
  
	$lines = file('/etc/backuppc/hosts');
	$hosts = array();
	foreach ($lines as $line_num => $line) {
		if (ereg("(^[^#][0-9a-zA-Z._-]+)", $line, $regs)) {
			$hosts[$line_num]=$regs[0];
		}
	}
	return $hosts;

}

/* check whether $host is registered by the backuppc
 * $host - host name
 * return true if host is in the /etc/backuppc/hosts file
 */
function hostBackuped($host) {
	$hosts = readBackupHosts();
	if ( in_array($host, $hosts) && 
	     is_readable("/etc/backuppc/".strtolower($host).".pl") ) {
		return true;
	}
	return false;
}

/*
 * Change the permissions to backuppc:backuppc
 */
function fixperms($file) {
	system("chmod 640 $file");
	system("chown backuppc:backuppc $file");
}

/* generate default configuration file for backuppc of a newly added host
 * by deafault it is Unix(NFS) with no shared folders
 * the created file is /etc/backuppc/$host.pl
 * $host - host name
 */
function generateDefaultFile($host) {
	$host = strtolower($host);
	$filename = "/etc/backuppc/".$host.".pl";
	if (!($fh = fopen($filename, "w")))
		halt("cannot create file $filename");
	fwrite($fh, "# Configuration of $host\n\$Conf{XferMethod} = 'smb';\n\n\$Conf{SmbShareName} = [];\n\n");
#fwrite($fh, "\$Conf{TarClientCmd} = '/usr/bin/env LANG=en \$tarPath -c -v -f - -C \$shareName --totals';\n\n");
	fwrite($fh, "\n# *** Unchanged Configuration ***\n");
	fwrite($fh, "\n\n# ***\n");
	fclose($fh);
	fixperms($filename);
}

/* add a host to BackupPC 
 * $host - host name
 * $dhcp - dhcp flag, by default 0, might be set through webmin
 * adding a host means adding its name to /etc/backuppc/hosts file and creating a default file
 * then the host can be configured through webmin interface
 */
function addBackuppcHost($host, $dhcp=0) {
	$filename = '/etc/backuppc/hosts';
	$fh = fopen($filename, "r+");
	$f_str = fread($fh, filesize($filename));
	$str = "$host \t $dhcp \t backuppc\n";
	if (!strstr($f_str, "\n".$str)) {
# only add if it does not exist
		if (fwrite($fh, $str) == FALSE)
			halt("cannot write to $filename");
	}
	fclose($fh);
	fixperms($filename);
	generateDefaultFile($host);
	reloadBPC();
}

/* Tell BPC to reload its main config files */
function reloadBPC () {
	exec('/etc/init.d/backuppc reload');
}

/* change host's DHCP flag in /etc/backuppc/hosts file 
 * $host - host name
 * $dhcp - dhcp flag, by default 0, might be set through webmin
 */
function changeDHCP($host, $dhcp) {
	$filename = '/etc/backuppc/hosts';

	$fh = fopen($filename, "rb");
	$f_str = fread($fh, filesize($filename));
	fclose($fh);
  
	$reg = "/[^#\s]*".$host."\s+[01]/";
	$replacement = "$host \t $dhcp";
	$f_str = preg_replace($reg, $replacement, $f_str);

	$fh = fopen($filename, "w");
	if (fwrite($fh, $f_str) == FALSE)
		halt("cannot write to $filename");
	fclose($fh);
	fixperms($filename);
}

/*  
 * return host's DHCP flag
 * $host - host name
 */
function getDHCP($host) {
	$filename = '/etc/backuppc/hosts';

	$fh = fopen($filename, "rb");
	$f_str = fread($fh, filesize($filename));
	fclose($fh);
  
	$reg = "/[^#]\s*".$host."\s+([01])/";
	if (preg_match($reg, $f_str, $regs)) 
		return $regs[1];

	return -1;
}

/* remove commented lines from the lines' array
   return array with not commented lines
*/
function deleteComments($filelines) {
	$no_comment=array();
	$j=0;
	$reg = "/^#.*$/";
	for ($i=0; $i<count($filelines);$i++) {
		if (!preg_match($reg, $filelines[$i], $m)) { 
			$no_comment[$j] = $filelines[$i];
			$j++;
		} 
	}  
	$filestr = implode("", $no_comment);
	return $filestr;
} 

/* Read the following backuppc configuration settings:
   FullPeriod
   IncrPeriod
   BlackoutHourBegin
   BlackoutHourEnd
   BlackoutWeekDays
   from the string $filestr.
   These setting can be set for the client as well as globally on the server, this is why this function can be called 
   for the host's configuration file and for the config.pl file. The settings are registered on the proper variables only
   if those variables are not set (the value of the setting has not yet been found).
   
  $full, $incr - periods of full and incremental backups in days
  $blackout_begin, $blackout_end - starting and ending hours of the blackout period
  $blackout_days - blackout week days
*/
function findCommonSettings($filestr, &$full, &$incr, &$blackout_begin, &$blackout_end, &$blackout_days) {

	if (!isset($full)) {
		$reg = "/[\$]Conf\{FullPeriod\}\s*=\s*'?([^';]+)'?;/";
		if (preg_match($reg, $filestr, $m)) {
			$full = $m[1];
		}
	}
	if (!isset($incr)) {
		$reg = "/[\$]Conf\{IncrPeriod\}\s*=\s*'?([^';]+)'?;/";
		if (preg_match($reg, $filestr, $m)) {
			$incr = $m[1];
		}
	}

    	// not used anymore. can be removed.
	if (!isset($blackout_begin)) {
		$reg = "/[\$]Conf\{BlackoutHourBegin\}\s*=\s*'?([^']+)'?;/";
		if (preg_match($reg, $filestr, $m))
			$blackout_begin = $m[1];
	}
  
	if (!isset($blackout_end)) {
		$reg = "/[\$]Conf\{BlackoutHourEnd\}\s*=\s*'?([^']+)'?;/";
		if (preg_match($reg, $filestr, $m)) 
			$blackout_end = $m[1];
	}

	if (!isset($blackout_days)) {
		$reg = "/[\$]Conf\{BlackoutWeekDays\}\s*=\s*\[(.+)\];/";
		if (preg_match($reg, $filestr, $m)) {
			$blackoutdays_tmp = array_map("trim", explode(",", $m[1]));
			$blackout_days=array();
			for ($i=0; $i<7; $i++) 
				$blackout_days[$i]=(in_array($i, $blackoutdays_tmp));
		}
	}
} 
/* read configuration values of host, read them in an intelligent way: if a variable is set don't change it, 
 * if the xfermethod has changed don't read the shares from the file, if you don't have $full or $incr look for it
 * in the general configuration file
 * $host - host name
 * $xfermethod - transport method: tar/smb/rsync
 * $shares - table of shared folders
 * $username, $passwd - only for smb
 * $full, $incr - periods of full and incremental backups in days
 * $blackout_begin, $blackout_end - starting and ending hours of the blackout period
 * $blackout_days - blackout week days
 * on the return the proper variables are set
 */
function readConfFile($host, &$xfermethod, &$shares, &$username, &$passwd, &$full, &$incr,
                      &$blackout_begin, &$blackout_end, &$blackout_days) {
 
	// values from host file
	$host_file = strtolower($host);
 
	$filename = '/etc/backuppc/'.$host_file.'.pl';
	$filelines = @file($filename);

	if (empty($filelines)) {
		halt("Error while reading $host configuration file; $filename does not exist or is empty.");
		return false;
	}
 
	$filestr = deleteComments($filelines);
 
	$reg = "/[\$]Conf\{XferMethod\}\s*=\s*\'(.+)\';/";
	preg_match($reg, $filestr, $m);
	$xfermethod_orig = $m[1];
	if ($xfermethod_orig == "tar") {
		$reg = "/[\$]Conf\{TarClientCmd\}\s*=\s*\'(.+)\';/";
		if (!preg_match($reg, $filestr, $m)) 
			$xfermethod_orig = "tarssh";
	}

	$xfer_changed = false;
	if (isset($xfermethod)) {
		if ($xfermethod_orig != $xfermethod)
			$xfer_changed = true;
	} else
		$xfermethod = $xfermethod_orig;
  
	$str = ucfirst($xfermethod);
  
	if (!isset($shares) && !($xfer_changed)) {
		$shares=array();
		if ($xfermethod == "rsyncd")
			$reg = "/[\$]Conf\{RsyncShareName\}\s*=\s*\[(.*?)\];/s";
		else if ($xfermethod == "tarssh")
			$reg = "/[\$]Conf\{TarShareName\}\s*=\s*\[(.*?)\];/s";
		else
			$reg = "/[\$]Conf\{".$str."ShareName\}\s*=\s*\[(.*?)\];/s";
		preg_match($reg, $filestr, $m);
		$shares_full = explode(",", $m[1]);
		$reg = "/\'(.*)\'/";
		$j = 0;
		for ($i=0; $i<count($shares_full); $i++) {
			preg_match($reg, $shares_full[$i], $m);
			if ($m[1]) { // this is to eliminate empty inputs in table
				$shares[$j] = $m[1];
				$j++;
			}
		}
	}
 
	if (!($xfer_changed) && ($xfermethod == 'smb' || $xfermethod == 'rsyncd') && !isset($username) && !isset($passwd)) {
		$reg = "/[\$]Conf\{".$str."ShareUserName\}\s*=\s*\'(.*)\';/";
		preg_match($reg, $filestr, $m);
		$username = $m[1];

		$reg = "/[\$]Conf\{".$str."SharePasswd\}\s*=\s*\'(.*)\';/";
		preg_match($reg, $filestr, $m);
		$passwd = $m[1];
	}

	findCommonSettings($filestr, $full, $incr, $blackout_begin, $blackout_end, $blackout_days);

	// values from config.pl
	$filename = '/etc/backuppc/config.pl';

	$filelines = @file($filename);
	if (empty($filelines)) {
		halt("Error while reading configuration file; $filename does not exist or is empty.");
		return false;
	}
 
	$filestr = deleteComments($filelines);
  
	findCommonSettings($filestr, $full, $incr, $blackout_begin, $blackout_end, $blackout_days);

}

/* show error message and quit
 */
function halt($msg) {
	die("<b>Halted:</b> $msg");
	return false;
}

function sshKeyExists() {
	return file_exists('/var/lib/backuppc/.ssh/BackupPC_id_rsa.pub');
}

/* Generate the public/private keys on the server. The public key is later used by a rsyncd, tar ssh clients for authorisation 
 */
function generateSshKey() {
	$bpchome = "/var/lib/backuppc";

	if (!file_exists('$bpchome/.ssh/id_rsa.pub')) {
		if (!file_exists('$bpchome/.ssh'))
			mkdir("$bpchome/.ssh", 0700);
		if (!file_exists('$bpchome/.ssh/id_rsa.pub')) 
			exec("ssh-keygen -t rsa -N '' -f $bpchome/.ssh/id_rsa");

		copy("$bpchome/.ssh/id_rsa.pub", "$bpchome/.ssh/BackupPC_id_rsa.pub");	
		exec("chown -R backuppc:backuppc $bpchome/.ssh/");
		exec("chmod -R og-rwx $bpchome/.ssh/");
	}
}

/* return the part of the hosts' ocnifuration file between the comments : *** Unchanged Configuration *** and *** */
function getUnchangedConf($host) {
	$host_file = strtolower($host);
	$filename = '/etc/backuppc/'.$host_file.'.pl';
	$filestr = implode("", @file($filename));

	if (empty($filestr)) {
		halt("Error while reading $host configuration file; $filename does not exist or is empty.");
		return false;
	}
	$reg = "/(# \*\*\* Unchanged Configuration \*\*\*[^\*]*# \*\*\*)/";
	preg_match($reg, $filestr, $m);
  
	return $m[1];
}

/* write gathered data to the host's configuration file
 * $host - host name
 * $xfermethod - transport method: tar/smb/rsync
 * $shares - table of shared folders
 * $username, $passwd - only for smb
 * $full, $incr - periods of full and incremental backups in days
 * $blackout_begin, $blackout_end - starting and ending hours of the blackout period
 * $blackout_days - blackout week days
 * on the return the proper file is written
 */
function saveBackupFile($host, $xfermethod, $shares_str, $username, $passwd, $full, $incr,
                        $blackout_begin, $blackout_end, $blackout_days) {
	$host_file = strtolower($host);
	$filename = "/etc/backuppc/".$host_file.".pl";
  
	$unchangedConf = getUnchangedConf($host);
  
	if (!($fh = fopen($filename, "w")))
		halt("cannot create file $filename");
	fwrite($fh, "# Configuration of $host\n");
	if ($xfermethod == "tarssh")
		fwrite($fh, "\$Conf{XferMethod} = 'tar';\n\n");
	else
		fwrite($fh, "\$Conf{XferMethod} = '$xfermethod';\n\n");
 
	if ($xfermethod == "tar" || $xfermethod == "tarssh") {
		fwrite($fh, "\$Conf{TarShareName} = $shares_str;\n\n");
		if ($xfermethod == "tar")
			fwrite($fh, "\$Conf{TarClientCmd} = '/usr/bin/env LANG=en \$tarPath -c -v -f - -C \$shareName --totals';\n\n");
			// restoration command is missing !
	} else 
		if ($xfermethod == "smb" ) {
			fwrite($fh, "\$Conf{SmbShareName} = $shares_str;\n\n");
			fwrite($fh, "\$Conf{SmbShareUserName} = '$username';\n");
			fwrite($fh, "\$Conf{SmbSharePasswd} = '$passwd';\n\n");
		} else
			if ($xfermethod == "rsync" || $xfermethod == "rsyncd") {
				fwrite($fh, "\$Conf{RsyncShareName} = $shares_str;\n\n");
				if ($xfermethod == "rsyncd") {
					fwrite($fh, "\$Conf{RsyncdShareUserName} = '$username';\n");
					fwrite($fh, "\$Conf{RsyncdSharePasswd} = '$passwd';\n\n");
				}
			} 
  
        if ($full != "")
                fwrite($fh, "\$Conf{FullPeriod} = $full;\n");
        if ($incr != "")
                fwrite($fh, "\$Conf{IncrPeriod} = $incr;\n\n");

	// not used anymore
        if ($blackout_begin != "")
                fwrite($fh, "\$Conf{BlackoutHourBegin} = $blackout_begin;\n");
        if ($blackout_end != "")
                fwrite($fh, "\$Conf{BlackoutHourEnd} = $blackout_end;\n");
        if ($blackout_days != "")
                fwrite($fh, "\$Conf{BlackoutWeekDays} = [$blackout_days];\n");

	fwrite($fh, "\n$unchangedConf\n");
	fclose($fh);
	fixperms($filename);
}

/* get the list of shared folders of a windows host
 * $host - host name
 * $username, $passwd
 * return - the shared folders list, empty in the case of error
 */
function getSmbShares($host, $username, $passwd) {
	$command = "smbclient -U ".$username."%".$passwd." -L $host";
	$handle = popen($command, "r");
	$str = fread($handle, 4096);
	pclose($handle);
  
	$reg = "/\s([^\s]+)\s+Disk/";
	preg_match_all($reg, $str, $m);
	$res = array();
	for ($i = 0; $i < count($m[0]); $i++) 
		$res[$i] = $m[1][$i];
	return $res; 
}

/* get the list of shared folders of a unix host
 * $host - host name
 * return - the shared folders list, empty in the case of error
 */
function getTarShares($host) {
	$command = "showmount -e $host";
	$handle = popen($command, "r");
	$res = array();
	$i = 0;
	while (!feof($handle)) {
		$str = fgets($handle, 4096);
		$reg = "/(\/[^\s]*)\s/";
		if (preg_match($reg, $str, $m)) {
			$res[$i] = $m[1];
			$i++;
		}
	}
	pclose($handle); 
	return $res; 
}

/* verify if LBS is installed on the machine
 * return boolean
 */
function isLBS() {
	$file = '/etc/lbs.conf';
	return file_exists($file);
}

?>
