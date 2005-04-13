# lrs-export.pl
# functions used by lbs_common to do some work
# $Id$
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


# functions are simply _written_ here, but when executed, that's as if they where taking place in the main code

# There are some functions to define:
# mainlist_label()      => to receive the labels for each columns in the main list (array)
# mainlist_content($)   => to receive the content for each cell ... (array, arg is the hash 's ref {'group', 'name', 'function', 'mac', ...) identifying the machine, depending on the called module)
# module_status()       => to get a <div> block containing some stats about the current module
# and some functions to get callbacks on them:
# mainlist_label_callback()   
# mainlist_content_callback()
# module_status_callback()  
# and an "init" function to get in the right namespace

sub init() {
        my $oldforeign=$ENV{"FOREIGN_MODULE_NAME"};
        $ENV{"FOREIGN_MODULE_NAME"}="backuppc";
#        main::init_config();

        $config_directory = $ENV{'WEBMIN_CONFIG'};

        # Read the webmin global config file. This contains the OS type and version,
        # OS specific configuration and global options such as proxy servers
        $config_file = "$config_directory/config";
        main::read_file_cached($config_file, \%gconfig);

        # Set PATH and LD_LIBRARY_PATH
        $ENV{'PATH'} = $gconfig{'path'} if ($gconfig{'path'});
        $ENV{$gconfig{'ld_env'}} = $gconfig{'ld_path'} if ($gconfig{'ld_env'});

        # get our module config
	$root_directory = $ENV{'FOREIGN_ROOT_DIRECTORY'};
	$module_name = $ENV{'FOREIGN_MODULE_NAME'};
	$module_config_directory = "$config_directory/$module_name";
	$module_config_file = "$module_config_directory/config";
	main::read_file_cached($module_config_file, \%config);

        # Get the username
        local $u = $ENV{'BASE_REMOTE_USER'} ? $ENV{'BASE_REMOTE_USER'}
                                            : $ENV{'REMOTE_USER'};
        $base_remote_user = $u;
        $remote_user = $ENV{'REMOTE_USER'};

        # Set some useful variables
        $current_theme = defined($gconfig{'theme_'.$remote_user}) ?
                            $gconfig{'theme_'.$remote_user} :
                         defined($gconfig{'theme_'.$base_remote_user}) ?
                            $gconfig{'theme_'.$base_remote_user} :
                            $gconfig{'theme'};
	main::read_file_cached("$root_directory/$current_theme/config", \%tconfig);

        $tb =   defined($tconfig{'cs_header'}) ? "bgcolor=#$tconfig{'cs_header'}" :
                defined($gconfig{'cs_header'}) ? "bgcolor=#$gconfig{'cs_header'}" :
				       "bgcolor=#9999ff";
        $cb =   defined($tconfig{'cs_table'}) ? "bgcolor=#$tconfig{'cs_table'}" :
                defined($gconfig{'cs_table'}) ? "bgcolor=#$gconfig{'cs_table'}" :
				      "bgcolor=#cccccc";

        $tb .= ' '.$tconfig{'tb'} if ($tconfig{'tb'});
        $cb .= ' '.$tconfig{'cb'} if ($tconfig{'cb'});

        # Get the %module_info for this module
        %module_info = main::get_module_info($module_name);
        $module_root_directory = "$root_directory/$module_name";

        # Check the Referer: header for nasty redirects
        local @referers = split(/\s+/, $gconfig{'referers'});
        local $referer_site;
        if ($ENV{'HTTP_REFERER'} =~/^(http|https|ftp):\/\/([^:\/]+:[^@\/]+@)?([^\/:@]+)/) {
                $referer_site = $3;
                }
                
        # read current's language file
        foreach my $o (("en", $gconfig{"lang"}, main::get_language())) {
                my $langfile="$root_directory/$module_name/lang/$o";
                main::read_file_cached($langfile, \%main::text);
        }

        $ENV{"FOREIGN_MODULE_NAME"}=$oldforeign;

}

sub mainlist_content_callback() {
        return \&mainlist_content;
}

sub mainlist_label_callback() {
        return \&mainlist_label;
}

sub mainlist_status_callback() {
        return \&mainlist_status;
}

sub mainlist_label() {
        init();        
        return ({'content' => "<div style='text-align: center'>".main::text('lab_backup')."</div>", 'attribs' => 'width="50px"'});
}

sub mainlist_content($) {
my $hashref=shift;

        init();        
        if (defined($hashref->{'mac'})) {
                my $module_name="backuppc";                                # FIXME: hard-coded
                my $mac=$hashref->{'mac'};
                my $params="mac=".main::urlize($mac);
                my $imgout="/$module_name/images/icon-menu.gif";
                my $imgover="/$module_name/images/icon-menu-shaded.gif";
                
                # get status
                
                my $backuppc_status="/var/lib/backuppc/log/status.pl";
                my $timestamp="";
                
                if (-r $backuppc_status) {
                        use vars qw'%Status';
                        require $backuppc_status;
                        my %ether;
                        main::etherLoad("$main::config{'chemin_basedir'}/etc/ether" , \%ether);
                        my $name=lc(main::etherGetNameByMac(\%ether, $mac));
                        if ($Status{$name}) {
                                my $state=$Status{$name}{'state'};
                                my $time=$Status{$name}{'startTime'};
                                my $lastpings=$Status{$name}{'deadCnt'};
                                my $lasterror=$Status{$name}{'error'};
                                my $lastsave=$Status{$name}{'aliveCnt'};
                                my $lasttype=$Status{$name}{'type'} || "";
                                
                                $timestamp = "last probe (".main::timestamp2date($time)."):<br>";
                                if ($lasterror) {
                                        $timestamp .= "failure since '".$lasterror."'.";
                                } else {
                                        $timestamp .= "success for the save #$lastsave (type $lasttype)";
                                }
                        }
                }
                my $name="$module_name"."_".main::mac_remove_columns($mac)."_img";
                $name =~ tr|-/|__|;
                my $link = "<div title=\"$timestamp\" 
                                onmouseover=\"$name.src='$imgover';\" 
                                onmouseout=\"$name.src='$imgout';\" 
                                align=\"center\"> 
                              <a
                                        onmouseover=\"$name.src='$imgover';\"
                                        onmouseout=\"$name.src='$imgout';\"
                                        href=\"/$module_name/index.cgi?$params\">
                                <img
                                        name=\"$name\"
                                        border='0'
                                        src=\"$imgout\"
                                        alt=\"".main::text('lab_backup')."\" />
                              </a>
                            </div>";
                
                return ({'content' => $link});
        }
        return ({'content' => "&nbsp;"});
}


sub module_status() {
        
        return;
}

# erases a machine
# the only argument is the machine name, AS SEEN BY BACKUPPC

sub delete_client($) {
my $name = shift;
my $find = "/usr/bin/find";
my $backuppcuser = "backuppc";

        # dump junk chars
        $name =~ tr/a-zA-Z_-//cd;

        # get out if no name was given
        return 1 unless ($name ne "");
        
        # some init
        init();
        
        # backuppc hold machine's conf in two places:
        # 1. it's config. file (default to /etc/backuppc/hosts)
        # 2. the machine's config file (default to /etc/backuppc/name.pl)
        # 3. the pool of files (default to /var/lib/backuppc/pc/name)

        # will be used to get BPC's conf files
        my $backuppc_config_path = $config{'config_path'};
        # assign a default value
        $backuppc_config_path = "/etc/backuppc" unless $backuppc_config_path ne "";
        # and define some other path
        my $backuppc_main_conffile = "$backuppc_config_path/hosts";
        my $host_main_conffile = "$backuppc_config_path/$name.pl";
        
        # get the pool
        my $backuppc_pool_path = $config{'pool_path'};
        # assign a default value
        $backuppc_pool_path = "/var/lib/backuppc" unless $backuppc_pool_path ne "";
        my $backuppc_pc_path = "$backuppc_pool_path/pc";
        my $host_pc_path = "$backuppc_pc_path/$name";
        
        # exits if nothing seems to work
        return 1 unless -d $backuppc_config_path;
        return 1 unless -w $backuppc_main_conffile;
        return 1 unless -w $host_main_conffile;
        return 1 unless -d $backuppc_pc_path;
        return 1 unless getpwuid ((stat($backuppc_pc_path))[4]) eq $backuppcuser;
        return 1 unless ((stat($backuppc_pc_path))[1]) != ((stat($host_pc_path))[1]);

        # performs first step
        my $buffer = "";        
        open BACKUPPC_MAIN_CONFFILE, '<', $backuppc_main_conffile or return 1;
        while (<BACKUPPC_MAIN_CONFFILE>) {
                $buffer .= $_ unless m/^[^#]*\W*$name\W+/;
        }
        close BACKUPPC_MAIN_CONFFILE;
        open BACKUPPC_MAIN_CONFFILE, '>', $backuppc_main_conffile or return 1;
        print BACKUPPC_MAIN_CONFFILE $buffer;
        close BACKUPPC_MAIN_CONFFILE;

        # and the second step
        unlink $host_main_conffile or return 1;

        # and the third step. Cross your fingers ;)
        `rm -fr $host_pc_path`
        

}

1;
