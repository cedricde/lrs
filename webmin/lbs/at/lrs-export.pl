# lrs-export.pl
# functions used by lbs_common to do some work
# $Id$

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
        $ENV{"FOREIGN_MODULE_NAME"}="lbs/at";
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

        $ENV{"FOREIGN_MODULE_NAME"}=$oldforeign;}

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
        return (
                {'content' => "<div style='text-align: center'>"."Admin"."</div>", 'attribs' => 'width="50px"'}
                );
}

sub mainlist_content($) {
my $hashref=shift;
        
        if (defined($hashref->{'mac'})) {
                my $module_name="lbs";
                my $mac=$hashref->{'mac'};
                my $params="mac=".main::urlize($mac);
                my $name="lbswol"."_".main::mac_remove_columns($mac)."_img";
                $name =~ tr|-/|__|;
                my $imgout="/lbs/images/admin.gif";
                my $imgover="/lbs/images/admin-shaded.gif";
                my $timestamp="&nbsp";

                my $link = "<div title=\"$timestamp\" 
                                onmouseover=\"$name.src='$imgover';\" 
                                onmouseout=\"$name.src='$imgout';\" 
                                align=\"center\"> 
                              <a
                                                onmouseover=\"$name.src='$imgover';\"
                                                onmouseout=\"$name.src='$imgout';\"
                                                href=\"/$module_name/admin.cgi?$params\">
                                                <img
                                                        border=0
                                                        name=\"$name\"
                                                        src=\"$imgout\"
                                                        alt=\"wake\">
                                        </a>
                                </div>";
                
                return ({'content' => $link});
        } elsif (defined($hashref->{'group'})) { # TODO
                my $module_name="lbs";
                my $group=$hashref->{'group'};
                my $profile=$hashref->{'profile'} || "";
                my $params="group=".main::urlize($group)."&profile=".main::urlize($profile);
                my $imgout="/lbs/images/admin.gif";
                my $imgover="/lbs/images/admin-shaded.gif";
                my $timestamp="&nbsp";
                my $name="lbswol"."_".$group."_img";
                $name =~ tr|-/|__|;

                my $link = "<div title=\"$timestamp\" 
                                onmouseover=\"$name.src='$imgover';\" 
                                onmouseout=\"$name.src='$imgout';\" 
                                align=\"center\"> 
                              <a
                                                onmouseover=\"$name.src='$imgover';\"
                                                onmouseout=\"$name.src='$imgout';\"
                                                href=\"/$module_name/admin.cgi?$params\">
                                                <img
                                                        border=0
                                                        name=\"$name\"
                                                        src=\"$imgout\"
                                                        alt=\"wake\">
                                        </a>
                                </div>";
                
                return ({'content' => $link});
        } elsif (defined ($hashref->{'profile'}) && ($hashref->{'profile'} ne "all") && ($hashref->{'profile'} ne "none")) { # TODO, also
                my $module_name="lbs";
                my $group=$hashref->{'group'};
                my $profile=$hashref->{'profile'};
                my $params="profile=".main::urlize($profile);
                my $imgout="/lbs/images/wake.gif";
                my $imgover="/lbs/images/wake-shaded.gif";
                my $timestamp="&nbsp";
                
                my $name="lbswol"."_".$profile."_img";
                $name =~ tr|-/|__|;
                my $link = "<table style='border-width: 0px;'><tr><td style='border-width: 0px;'>
                                <div title=\"$timestamp\" 
                                onmouseover=\"$name.src='$imgover';\" 
                                onmouseout=\"$name.src='$imgout';\" 
                                align=\"center\"> 
                              <a
                                                onmouseover=\"$name.src='$imgover';\"
                                                onmouseout=\"$name.src='$imgout';\"
                                                href=\"/$module_name/wol.cgi?$params\">
                                                <img
                                                        border=0
                                                        name=\"$name\"
                                                        src=\"$imgout\"
                                                        alt=\"wake\">
                                        </a>
                                </div></td></tr><tr><td style='border-width: 0px; text-align: center'>"
                            .
                            "WOL"
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