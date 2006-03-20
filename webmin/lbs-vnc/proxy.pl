#!/usr/bin/perl
#
# $Id$
#
# Smart proxy ssh tunnel
#
# Linbox Rescue Server. Copyright (C) 2005  Linbox FAS
#
# Some proxy code is based on tcpproxy (c)opyright 1999 by dan goldwater, dgold@zblob.com
#

use strict;
use Socket;
use POSIX qw(setsid);
use warnings;
use Sys::Syslog;
use Sys::Syslog qw(:DEFAULT setlogsock);
use IO::Socket::INET;

# command line parsing: simple, always 6 arguments

if ( $#ARGV != 7 )
  {
    print "Usage: proxy.pl run|test from.ip dest.ip dest.port key user host loguser\n";
    exit 1;
  }

my ($command, $from, $dest, $destport, $key, $sshuser, $host, $loguser) = @ARGV;

# globals
my $pid;
my $debug = 0;			# disable the double fork stuff

#
# Check for two free ports in the range "5900-5999"
#
sub alloc_freeport  {
  my $localport = 5900;
  my $max = 100;
  my $tries = $max;
  my ($sock1, $sock2);

  while (1)
    {
      $tries--;
      if ($tries == 0) {
	return 0;
      }
      
      $localport += int(rand($max/2)) * 2;
      #$localport = 5900;
      
      # try to open the sockets
      $sock1 = new IO::Socket::INET ( LocalPort => $localport, Proto => 'tcp', Listen => 1, Reuse => 1 );
      
      $sock2 = new IO::Socket::INET ( LocalPort => $localport + 1, Proto => 'tcp', Listen => 1, Reuse => 1 );
      
      next unless $sock1;
      close($sock1);
      next unless $sock2;
      close($sock2);
      last;
    }
  return $localport;
}


#
# Transparent proxy
#
sub proxy {
  my $remoteAddr = shift;
  my $proxyPort = shift;
  my $destHost  = shift;
  my $destPort  = shift;

  my $peer;
  do {
    $peer = server($remoteAddr, $proxyPort);
    client($destHost, $destPort);
    transferdata();
  } while ($peer ne $remoteAddr);
}


#
#
#
sub server {
  my($addr) = shift;
  my($port) = shift;

  socket(SERVER, PF_INET, SOCK_STREAM, getprotobyname('tcp'));
  setsockopt(SERVER, SOL_SOCKET, SO_REUSEADDR, pack("l", 1));
  bind(SERVER, sockaddr_in($port, INADDR_ANY));
  listen(SERVER, 1);

  $SIG{ALRM} = \&sigterm;
  alarm(40);			# allow 40 seconds for the initial connect
  while (1) {
    accept(CLIENT, SERVER);

    my ($port, $iaddr) = unpack_sockaddr_in(getpeername(CLIENT));
    my $peer = inet_ntoa($iaddr);
    my ($port2, $iaddr2) = unpack_sockaddr_in(getsockname(CLIENT));
    my $peer2 = inet_ntoa($iaddr2);
    syslog("info", "connect from ".$peer." to ".$peer2);
    if (($peer ne $peer2) && ($peer ne $addr)) {
      syslog("info", "rejected");
      next;
    } else {
      alarm(0);
      return $peer;
    }
  }
}

#
# 
#
sub client {
  my $remote = shift;
  my $port = shift;
  my $paddr;
  my $tries = 5;
  
  $paddr = sockaddr_in($port, inet_aton($remote));
  socket(SOCK, PF_INET, SOCK_STREAM, getprotobyname('tcp'));
  while (1) {
    if (connect(SOCK, $paddr)) { last; }
    syslog("err", "Could not connect to $remote:$port: $!");
    sleep(1);
    $tries--;
    if ($tries == 0) { mydie("5 tries"); }
  }

  select(SOCK);
  $| = 1;
  select(STDOUT);
  return;
}

# move data through the tunnel.  called when data is waiting
# at one end of the tunnel.  it moves the data to the other end.
# input: direction flag:  0 = client->server   1 = server->client
sub movedata($) {
    my($s2c) = $_[0];
    my($buf1, $buf2, $buf3, $len1, $len2, $offset, $written);
    my($FH1, $FH2);
    my($decode) = 0;
    my($encode) = 0;

    if($s2c) {
	$FH1 = \*SOCK;
	$FH2 = \*CLIENT;
    }
    else {
	$FH1 = \*CLIENT;
	$FH2 = \*SOCK;
    }

    $len1 = sysread($FH1, $buf1, 4096, 0);

    unless(defined($len1)) {
	if($! =~ /^Interrupted/) { next; }
	mydie("system read error: $!");
    }
    if($len1 == 0) {
      # socket closed
      return 0;
    }

    $buf2 = $buf1;
    $len2 = $len1;

    $offset = 0;
    while($len2) {
	$written = syswrite($FH2, $buf2, $len2, $offset);
	unless(defined($written)) {
	    mydie("system write error: $!\n");
	}
	$len2 -= $written;
	$offset += $written;
    }
    return 1;
}

# main processing function once connections are established
# alternately checks the client and server sockets to see if any
# data is waiting on them to be read.  if data is available, it calls
# the MoveData() function to move the data from one socket to the other.
sub transferdata() {
  my($rin, $rout, $blksize1, $blksize2, $nfound, $FH1, $FH2);

  # read from stdin if we are an inetd managed daemon, otherwise read
  # from the client socket which we created

  $FH1 = \*CLIENT;
  $FH2 = \*SOCK;

  $rin = "";
  #$rin = $win = $ein = "";
  vec($rin, fileno($FH2), 1) = 1;
  vec($rin, fileno($FH1), 1) = 1;

  # main processing loop.  stay here until a socket closes.
  while(1) {
    #$nfound = select($rout=$rin, $wout=$win, $eout=$ein, undef);
    $nfound = select($rout=$rin, undef, undef, undef);
    if(vec($rout, fileno($FH1), 1)) {
      unless(movedata(0)) {
	syslog("info", "client closed connection");
	return;
      }
    }
    if(vec($rout, fileno($FH2), 1)) {
      unless(movedata(1)) {
	syslog("info", "server closed connection");
	return;
      }
    }
  }
}

#
# Syslog the error before exit
#
sub mydie {
  my $txt = shift;

  # kill the tunnel
  kill 15, $pid;
  syslog("crit", "died: $txt");
  exit(1);
}

#
# SIGKILL handler
#
sub sigterm {
  # kill the tunnel
  kill 15, $pid;
  syslog("debug", "signal handler kill $pid");
  exit(0);
}

#
# Main
#

setlogsock('unix');
openlog("proxy.pl: to $host as $loguser", "", "daemon");

$pid = 0;			# SSH pid

#
if ($command eq "run")
  {
    # set up the tunnel
    my $localport = alloc_freeport();
    print "port: ".($localport+1)."\n";

    #$SIG{CHLD} = 'IGNORE';
    $SIG{PIPE} = 'IGNORE';
    $SIG{TERM} = \&sigterm;

    if (!$debug) {
      # double fork
      defined($pid = fork) or die("Can't fork: $!");
      exit if( $pid );   # parent exits
      
      POSIX::setsid();
      defined($pid = fork) or die("Can't fork: $!");
      exit if $pid;   # parent exits
      chdir ("/") or die("Cannot chdir to /: $!\n");
      close(STDIN);
      open(STDIN , ">/dev/null") or die("Cannot open /dev/null as stdin\n");
      # STDOUT and STDERR are handled in LogFileOpen() right below,
      # otherwise we would have to reopen them too.
      open(STDOUT , ">/dev/null") or mydie("Cannot open /dev/null as stdout\n");
      open(STDERR , ">/dev/null") or mydie("Cannot open /dev/null as stderr\n");
    }
     
    # another fork for the proxy
    $pid = fork();
    die "Cannot fork: $!" unless defined($pid);

    if ($pid == 0)
      {
	# ssh process
	exec("ssh", "-i", $key, "-L", "$localport:127.0.0.1:$destport", "-o", "Batchmode yes", "-o", "StrictHostKeyChecking no",
	     "-n", $sshuser."@".$dest, "-N");	
        exit(0);   # Child process exits when it is done.
      }
    # proxy
    proxy($from, $localport+1, "127.0.0.1", $localport);

    # kill the tunnel
    kill 15, $pid;
    syslog("debug", "done kill $pid");
    exit(0);
  }
else
  {
    # test
    my $localport = alloc_freeport();
    my $cmd = "ssh -i $key -L $localport:127.0.0.1:$destport -o 'Batchmode yes' -o 'StrictHostKeyChecking no' -n $sshuser@".$dest." echo =SSHOK=";
    my $ret = `$cmd`;
    print "$ret";
    # should check for WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED
    if ($ret =~ /=SSHOK/) {
      exit 0;
    } else {
      exit 1;
    }
  }

