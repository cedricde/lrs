# functions used by lbs_common to do some work
# $Id$

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
        $ENV{"FOREIGN_MODULE_NAME"}="lbs";
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
my $hashref=shift;
        init();
        if (lc($hashref->{'section'}) eq "search") {
                return (
                        {'content' => "<div style='text-align: center'>".main::text('lab_macaddr')."</div>",    "attribs" => ""},
                        {'content' => "<div style='text-align: center'>".main::text('lab_boot')."</div>",       "attribs" => "width=\"50px\""}
                        );
        } elsif (defined ($hashref->{'currentprofile'}) && ($hashref->{'currentprofile'} ne "") && ($hashref->{'currentprofile'} ne "all") && ($hashref->{'currentprofile'} ne "none")) {
                return (
                        {'content' => "<div style='text-align: center'>".main::text('lab_macaddr')."</div>",    "attribs" => ""},
                        {'content' => "<div style='text-align: center'>".main::text('lab_nbimages')."</div>",   "attribs" => "width=\"50px\""},
                        {'content' => "<div style='text-align: center'>".main::text('lab_size')."</div>",       "attribs" => "width=\"50px\""},
                        {'content' => "<div style='text-align: center'>".main::text('lab_boot')."</div>",       "attribs" => "width=\"50px\""}
                        );
        } else {
                return (
                        {'content' => "<div style='text-align: center'>".main::text('lab_profile')."</div>",    "attribs" => "width=\"50px\""},
                        {'content' => "<div style='text-align: center'>".main::text('lab_macaddr')."</div>",    "attribs" => ""},
                        {'content' => "<div style='text-align: center'>".main::text('lab_nbimages')."</div>",   "attribs" => "width=\"50px\""},
                        {'content' => "<div style='text-align: center'>".main::text('lab_size')."</div>",       "attribs" => "width=\"50px\""},
                        {'content' => "<div style='text-align: center'>".main::text('lab_boot')."</div>",       "attribs" => "width=\"50px\""}
                        );
        }
}

sub mainlist_content($) {
my $hashref=shift;

        init();        
        
        if (lc($hashref->{'section'}) eq "search") {
                my $module_name="lbs";                                          # FIXME: hard-coded
                my $mac=$hashref->{'mac'};
                my $params="mac=".main::urlize($mac);
                my $imgout="/$module_name/images/icon-menu.gif";
                my $imgover="/$module_name/images/icon-menu-shaded.gif";

                my $link = "<div title=\"$timestamp\" align=\"center\"> 
                              <a
                                        onmouseover=\"$name.src='$imgover';\"
                                        onmouseout=\"$name.src='$imgout';\"
                                        href=\"/$module_name/bootmenu.cgi?$params\">
                                <img
                                        name=\"$name\"
                                        border='0'
                                        src=\"$imgout\"
                                />
                              </a>
                            </div>";
                
                
                return (
                        {'content' => "<tt>$mac</tt>"},
                        {'content' => $link}
                        );
        } elsif (defined($hashref->{'mac'})) {
                my $module_name="lbs";                                          # FIXME: hard-coded
                my $TFTPBOOT=$config{'chemin_basedir'};
                my $mac=$hashref->{'mac'};
		my $macfile = main::toMacFileName($mac);      		        # it's file
                my $params="mac=".main::urlize($mac);
                my $name="$module_name"."_".main::mac_remove_columns($mac)."_img";
                my $imgout="/$module_name/images/icon-menu.gif";
                my $imgover="/$module_name/images/icon-menu-shaded.gif";

                # get the menu
                my $cfgfile = "$TFTPBOOT/images/$macfile/header.lst";
                my %hdr;
                my $timestamp = "No default menu";

                if (main::hdrLoad( $cfgfile, \%hdr, 1)) {
                        my $defaultmenu;
                        foreach my $menuitem (main::hdrGetMenuNames(\%hdr)) {
                                my $isdefault = ($hdr{'ini'}{'data'}{$menuitem}[1] eq "yes");
                                my $bootimage = $hdr{'ini'}{'data'}{$menuitem}[5];
                                $timestamp = "Default menu: $bootimage" if $isdefault; # hem, not clean isn't it
                        }
                }
                
                my $link = "<div title=\"$timestamp\" 
                                onmouseover=\"tooltip.show(this);$name.src='$imgover';\" 
                                onmouseout=\"tooltip.hide(this);$name.src='$imgout';\" 
                                align=\"center\"> 
                              <a
                                        onmouseover=\"$name.src='$imgover';\"
                                        onmouseout=\"$name.src='$imgout';\"
                                        href=\"/$module_name/bootmenu.cgi?$params\">
                                <img
                                        name=\"$name\"
                                        border='0'
                                        src=\"$imgout\"
                                />
                              </a>
                            </div>";
                
                
		my $size=main::get_directory_size("$TFTPBOOT/images/$macfile");         # collect the size of the image
		$size = int( $size >> 10 );
		$size = "<div style=\"text-align: right;\">$size</div>";                                 # and Justify results

                my $nb=main::get_directory_numofimages("$TFTPBOOT/images/$macfile");    # collect the number of image
		$nb   = "<div style=\"text-align: right;\">$nb</div>";   			        # and Justify results

                if (defined ($hashref->{'currentprofile'}) && ($hashref->{'currentprofile'} ne "") && ($hashref->{'currentprofile'} ne "all") && ($hashref->{'currentprofile'} ne "none")) {
                        return (
                                {'content' => "<tt>$mac</tt>"},
                                {'content' => "$nb"},
                                {'content' => "$size"},
                                {'content' => $link}
                                );
                } else {        #supplementary column "profile"
                        return (
                                {'content' => "<tt>$hashref->{'profile'}</tt>"},
                                {'content' => "<tt>$mac</tt>"},
                                {'content' => "$nb"},
                                {'content' => "$size"},
                                {'content' => $link}
                                );
                }
        } elsif (defined ($hashref->{'group'})) {
                
                my $module_name="lbs";                                          # FIXME: hard-coded
                my $TFTPBOOT=$main::config{'chemin_basedir'};
                my $group=$hashref->{'group'};
                my $profile=$hashref->{'profile'} || "";
                my $params="group=".main::urlize($group)."&profile=".main::urlize($profile);
                my $name="$module_name"."_".$group."_img";
                my $imgout="/$module_name/images/icon-menu2.gif";
                my $imgover="/$module_name/images/icon-menu2-shaded.gif";

                # get the menu
                my $cfgfile = "$TFTPBOOT/imgprofiles/$profile/$group/header.lst";
                my %hdr;
                my $timestamp = "No default menu";

                
                if (main::hdrLoad( $cfgfile, \%hdr, 1)) {
                        my $defaultmenu;
                        foreach my $menuitem (main::hdrGetMenuNames(\%hdr)) {
                                my $isdefault = ($hdr{'ini'}{'data'}{$menuitem}[1] eq "yes");
                                my $bootimage = $hdr{'ini'}{'data'}{$menuitem}[5];
                                $timestamp = "Default menu: $bootimage<br />" if $isdefault; # hem, not clean isn't it
                        }
                }
                
                $name =~ tr|-/|__|;
                my $link = "<div title=\"$timestamp\" 
                                onmouseover=\"tooltip.show(this);$name.src='$imgover';\" 
                                onmouseout=\"tooltip.hide(this);$name.src='$imgout';\" 
                                align=\"center\"> 
                              <a
                                        onmouseover=\"$name.src='$imgover';\"
                                        onmouseout=\"$name.src='$imgout';\"
                                        href=\"/$module_name/bootmenu.cgi?$params\">
                                <img
                                        name=\"$name\"
                                        border='0'
                                        src=\"$imgout\"
                                />
                              </a>
                            </div>";
                
                
		my $size=main::get_group_size($group, $profile);                                  # collect the size of the group
		$size = int( $size >> 10 );
		$size = "<div style=\"text-align: right;\">$size</div>";                                 # and Justify results

                my $nb=main::get_group_numofimages($group, $profile);                             # collect the number of image
		$nb   = "<div style=\"text-align: right;\">$nb</div>";   			        # and Justify results
                
                if (defined ($hashref->{'currentprofile'}) && ($hashref->{'currentprofile'} ne "") && ($hashref->{'currentprofile'} ne "all") && ($hashref->{'currentprofile'} ne "none")) {
                        return (
                                {'content' => ""},
                                {'content' => "$nb"},
                                {'content' => "$size"},
                                {'content' => $link}
                                );
                } else {        #supplementary column "profile"
                        return (
                                {'content' => ""},
                                {'content' => ""},
                                {'content' => "$nb"},
                                {'content' => "$size"},
                                {'content' => $link}
                                );
                }
        } elsif (defined ($hashref->{'profile'}) && ($hashref->{'profile'} ne "all") && ($hashref->{'profile'} ne "none")) {
                my $module_name="lbs";                                          # FIXME: hard-coded
                my $TFTPBOOT=$main::config{'chemin_basedir'};
                my $profile=$hashref->{'profile'};
                my $params="profile=".main::urlize($profile);
                my $name="$module_name"."_img";
                my $imgout="/$module_name/images/icon-menu2.gif";
                my $imgover="/$module_name/images/icon-menu2-shaded.gif";

                # get the menu
                my $cfgfile = "$TFTPBOOT/imgprofiles/$profile/header.lst";
                my %hdr;
                my $timestamp = "No default menu";

                if (main::hdrLoad( $cfgfile, \%hdr, 1)) {
                        my $defaultmenu;
                        foreach my $menuitem (main::hdrGetMenuNames(\%hdr)) {
                                my $isdefault = ($hdr{'ini'}{'data'}{$menuitem}[1] eq "yes");
                                my $bootimage = $hdr{'ini'}{'data'}{$menuitem}[5];
                                $timestamp = "Default menu: $bootimage" if $isdefault; # hem, not clean isn't it
                        }
                }
                
                $name =~ tr|-/|__|;
                my $link = "<table style='border-width: 0px;'><tr><td style='border-width: 0px;'>
                                <div title=\"$timestamp\" 
                                onmouseover=\"tooltip.show(this);$name.src='$imgover';\" 
                                onmouseout=\"tooltip.hide(this);$name.src='$imgout';\" 
                                align=\"center\"> 
                              <a
                                        onmouseover=\"$name.src='$imgover';\"
                                        onmouseout=\"$name.src='$imgout';\"
                                        href=\"/$module_name/bootmenu.cgi?$params\">
                                <img
                                        name=\"$name\"
                                        border='0'
                                        src=\"$imgout\"
                                />
                              </a>
                            </div></td></tr><tr><td style='border-width: 0px; text-align: center'>"
                            .
                            main::text('lab_boot')
                            .
                            "</td></tr></table>"
                            ;
                
                return ({'content' => $link});
        }
        
        return undef;
}

sub module_status() {
        
        return;
}

1;