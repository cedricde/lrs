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
        $ENV{"FOREIGN_MODULE_NAME"}="lbs_common";
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
        return \&mainlist_content;
}

sub mainlist_status_callback() {
        return \&mainlist_content;
}

sub mainlist_label() {
        init();
        return undef;
}

sub mainlist_content() {
        init();        
        return undef;
}

sub module_status() {
        
        return;
}

1;