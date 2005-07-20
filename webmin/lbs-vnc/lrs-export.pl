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
        $ENV{"FOREIGN_MODULE_NAME"}="lbs-vnc";
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
        return ({'content' => "<div style='text-align: center'>".main::text('lab_vnc')."</div>", 'attribs' => 'width="50px"'});
}

sub mainlist_content($) {
my $hashref=shift;

        if (defined($hashref->{'mac'})) {
                my $module_name="lbs-vnc";                                # FIXME: hard-coded
                my $mac=$hashref->{'mac'};
                my $params="mac=".main::urlize($mac);
                my $imgout="/$module_name/images/icon-menu.gif";
                my $imgover="/$module_name/images/icon-menu-shaded.gif";
                
                my $timestamp = ".";
                my $arpcmd = "/usr/sbin/arp -n |";
                
                if (open ARPCMD, $arpcmd) {
                        while (<ARPCMD>) {      # typical output:
                                                # 192.168.0.248            ether   00:D0:70:00:F7:1E   C                     eth0
                                $timestamp = "http://$1:5800" if (m/(^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)\W+ether\W+$mac\W+/);
                        }
                }
                
                
                my $name="$module_name"."_".main::mac_remove_columns($mac)."_img";
                $name =~ tr|-/|__|;
                my $link = "<div title=\"$timestamp\" 
                                onmouseover=\"tooltip.show(this);$name.src='$imgover';\" 
                                onmouseout=\"tooltip.hide(this);$name.src='$imgout';\" 
                                align=\"center\"> 
                              <a
                                        onmouseover=\"$name.src='$imgover';\"
                                        onmouseout=\"$name.src='$imgout';\"
                                        href=\"/$module_name/index.cgi?$params\">
                                <img
                                        name=\"$name\"
                                        border='0'
                                        src=\"$imgout\"
                                        alt=\"inventory\" />
                              </a>
                            </div>";
                
                return ({'content' => $link});
        }
        return ({'content' => "&nbsp;"});
}

sub module_status() {
        
        return;
}

1;