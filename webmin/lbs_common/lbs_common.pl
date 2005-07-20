# $Id$

# Including the common functions
# FIXME: coder les noms des modules en pseudo-dur
# FIXME: what wabout WOL ?
use strict;

BEGIN {
our $logrep="/var/lib/lrs";
our $phplink="$logrep/php";

############ LOGGING ############ 
	close STDERR;
	
	`mkdir -p $logrep` unless (-d $logrep);

        if (-r "/var/lib/lbs/webmin.log") {
		system("echo \"===`date`\" >> /var/lib/lbs/webmin.log"); 
        	open STDERR, ">> /var/lib/lbs/webmin.log";
        } else {
        	open STDERR, "> /dev/null"; 
        }
############ /LOGGING ############ 

############ WEBMIN INCLUDING ############ 
        # doing some other init due to "strict" mode
        use vars qw '%gconfig $module_root_directory %access';
        $gconfig{'referers'}                    = "" unless $gconfig{'referers'};
        
	do '../web-lib.pl';
	init_config();
############ WEBMIN INCLUDING ############ 

############ LINKS THE GOOD PHP4 ############ 
	my @candidates = ( "/usr/lib/cgi-bin/php4",	# Location for Debian PHP 4 cgi binary
	"/usr/bin/php-cgi",				# Location for Mandrake PHP 4 cgi binary
	"/usr/bin/php",					# Location for Fedora Core 2 PHP 4 cgi binary
	"/usr/bin/php4-cgi", "/usr/bin/php4");		# Others location ...
	if (! -e $phplink) {
		# first we try to set the link according to the OS
		my $os = $gconfig{'real_os_type'}.' '.$gconfig{'os_version'};
	
		if ( $os =~ m/Debian/i ) {	# Version match Debian ?
			my $phpversion = `dpkg -s php4-cgi 2>&1 | egrep "^Version: " | sed 's/Version: //'`;
			if ( $phpversion =~ m/4:4\.1/ ) {
				`ln -s /usr/bin/php4 $phplink`;
			} else {
				`ln -s /usr/lib/cgi-bin/php4 $phplink`;
			}
		} elsif ( $os =~ m/Mandrake.*10\./i ) {	# Version match Mandrake 10.0 ?
			`ln -s /usr/bin/php-cgi $phplink`;
		} elsif ( $os =~ m/Mandrake.*9\./i ) {	# Version match Mandrake 9.0 ?
			`ln -s /usr/bin/php $phplink`;
		} elsif ( $os =~ m/Mandrake.*8\./i ) {	# Version match Mandrake 8.0 ?
			`ln -s /usr/bin/php $phplink`;
		} else {				# Try default paths, good luck
			foreach my $location (@candidates) {
				# Create a symbolink link to the right php4 binary
				if ( -e $location) {
					`ln -s $location $phplink`;
					last;
				}
			}
		}
	}
############ /LINKS THE GOOD PHP4 ############

################# MODIFY @INC ################
push @INC, "$module_root_directory/modules";
#push @INC, "/tftpboot/revoboot/bin";
################ /MODIFY @INC ################
}

#### include some mudules ####################
use Qtpl;
##############################################

#### Fixes some env vars #####################
$ENV{'LC_TIME'}=$ENV{'OLD_LANG'};
##############################################


#### consts ##################################
use vars qw ($current_lang %config %gconfig %in %text $cb $tb %module_info $module_root_directory $module_name $root_directory);
our $VERSION    ='$Rev$';                                                # REVISION
$VERSION        =~ s/\$Rev: (\d+) \$/$module_info{version} (r.$1)/;
our $LRS_HERE   =  -d "/tftpboot/revoboot";					# are we in LRS ?
our $LINBOX_URL = 'http://www.linbox.com';
our $BIGLOGO_URL= '/lbs_common/images/logo-big.gif';
our @LRS_MODULES= qw 'lbs_common lbs backuppc lbs-inventory lbs-cd  rsync lbs-vnc lrs-proxy lbs/at';      # every modules
#our @LRS_MODULES= qw 'lbs_common lbs';      # every modules
our $REALPATH   = 'readlink';
##############################################


# get some fonction from lbs
require 'lbs_path.pl';
require 'lbs-lib.pl' if -d "/tftpboot/revoboot";
require 'minilbs-lib.pl' if ! -d "/tftpboot/revoboot";

# prototype
sub init_lbs_conf($);

init_lbs_conf( $config{'lbs_conf'} ) or exit(0);

# Antialiased titles (webmin > 0.88)
$gconfig{'texttitles'} = 0 ;

# when used as a foreign module, get the right module name
$module_name=$ENV{'SCRIPT_NAME'};
$module_name =~ s|^/(.*)/.*$|$1|;

my $mac;
my $macPom = $mac;

# errors
our $ERROR_UNKNOWN=0;
# paths
our $LBS_COMMON_PATH=$module_root_directory;
$LBS_COMMON_PATH="/usr/share/webmin/lbs_common"         unless $LBS_COMMON_PATH;
our $TFTPBOOT=$config{'tftpboot_path'};
$TFTPBOOT="/tftpboot/revoboot"                          unless $TFTPBOOT;
our $TEMPLATES_PATH=$LBS_COMMON_PATH."/tmpl";
$TEMPLATES_PATH="/usr/share/webmin/lbs_common/tmpl"     unless $TEMPLATES_PATH;

my $ONGLET_DESCRIPTION="description.ini";
my $MENU_PATH=$LBS_COMMON_PATH."/menus";
my $IMAGES_PATH=$LBS_COMMON_PATH."/images";

# urls
my $LBS_COMMON_URL="/lbs_common";
my $IMAGES_URL=$LBS_COMMON_URL."/images";

our %lbsconf;

#### prototypes ####
sub get_hash_from_menu($$);


#### let's begin the Code ;) ####

# attempt to explore a supposed "Menu" directory. Recursive code.
# param 1 : $path : the path to explore
# param 2 : $menuref : a ref to our hash's 
# return :      - 1 if no error
#               - 0 if any error occurs
sub get_hash_from_menu($$) {
my ($path,$menuref)=@_;
my $basename=$path;

        return 0 if (!-d $path || !-r $path );            # we give out if that's not a directory nor readable

        opendir PATH, $path;
        $basename =~ s/.*\/(.*)$/$1/;
        
        my @contents=map "$path/$_",                    # we are building the dir's list
                sort                                    # sorted aplhabeticaly
                grep !/^CVS$/,                          # without CVS dirs
                grep !/^\.svn$/,                        # nor SVN dirs
                grep !/^\.{1,2}$/,                      # nor «.» and «..»
                grep !/^.*\~$/,                         # nor «blablabla~»
                readdir PATH;
        foreach (@contents) {
                if (-d) {                               # directory: we go deeper
                        my $position=0;
                        my %submenu;
                        my $name=$_;
                        
                        $name =~ s/.*\/(.*)$/$1/;
                        
                        get_hash_from_menu($_, \%submenu);
                        
                        $position=$submenu{'DATAS'}{'position_number'} if (defined($submenu{'DATAS'}{'position_number'})); # TODO: entier ?
                        $menuref->{$position}=\%submenu;
                } else {                                # simple file
                        my %datas;
                        my $name=$_;

                        $name =~ s/.*\/(.*)\/.*$/$1/;
                        
                        read_onglet_desc($_, \%datas);
                        if (%datas) {
                                $menuref->{'DATAS'} = \%datas;
                                $menuref->{'DATAS'}->{'title'}=$name;
                        }
                }
	}
        closedir PATH;
        
        return 1;
}

# get an onglet's config
# param 1 : $file : the file to read
# param 2 : $confref : a ref to our hash's 
# return :      - empty hash in case of error
#               - empty hash if $path is not readable
sub read_onglet_desc($$) {
my ($path,$confref)=@_; # path to explore

        read_env_file($path, $confref);
}

sub get_template{
	my ($template)= @_;
	return new Qtpl("$template");
}



# translation hash -> html
# param 1 : $titles     : ref on the selected onglets' titles's array
# param 2 : $mac        : ref on some GET parameters to emulate
# param 3 : $path       : 
# return : nothing #FIXME
sub print_html_tabs {
my ($titles, $params, $path)= @_;
my $template            = new Qtpl("$TEMPLATES_PATH/tabs.tpl");
my $language            = get_language();

ReadParse()     	if !%in;

$in{'host'}     	= $params->{'host'}     if !$in{'host'};
$in{'mac'}     	 	= $params->{'mac'}      if !$in{'mac'};

my $host                = $in{'host'};
my $group               = $in{'group'};
my $profile             = $in{'profile'};
my %menu;

        # when coming from some modules (backuppc f.ex.), the mac adress
        # can *not* be given: in this case we count on the hostname to
        # compute it
        
        if (not defined $in{'mac'} and defined $in{'host'} and $LRS_HERE) {
                
                my %einfo;
                my $etherfile = "$lbsconf{'basedir'}/etc/ether";
                main::etherLoad( $etherfile, \%einfo);
                $in{'mac'} = main::etherGetMacByName(\%einfo, $host, 1);
        }

my $mac                 = url_encode(mac_remove_columns($in{'mac'})) if $in{'mac'};
my $mac_with_dot        = url_encode(mac_add_columns(mac_remove_columns($in{'mac'}))) if $in{'mac'};

        # get the tabs according to installed modules
        foreach my $module (@LRS_MODULES) {
        	get_hash_from_menu("$ENV{'SERVER_ROOT'}/$module/menus", \%menu) if foreign_check($module);
        }
        
        foreach my $depth (0..3) {                                                                      # menu have a 3 level depth ? (FIXME)
                my $selected_onglet;
                my %hash=%menu;
                
		my $nbtabs=0;
		foreach my $onglet(keys %menu) {                                                	# first level
                        if ($onglet =~ m/\d+/) {                                                        # no "DATAS"
				if (!exists $menu{$onglet}{'DATAS'}{'require'}    		      	# keep only tabs which lead to installed mods
				     ||
				     foreign_check($menu{$onglet}{'DATAS'}{'require'}, 0)
				   ) {  $nbtabs++; }
                        }

                }		
		last if ($nbtabs==0);
		
                my $width=sprintf "%d%%", 100 / $nbtabs;

                foreach my $onglet(sort { $a <=> $b } keys %menu) {                                                   # first level
			my $selected=0;
                        my $url   = $menu{$onglet}{'DATAS'}{"link_$language"};                          # got the URL
                        my $label = $menu{$onglet}{'DATAS'}{"screen_name_$language"};                   # got the label
                        my $title = $menu{$onglet}{'DATAS'}->{'title'};                                 # got the title

                        if ($onglet =~ m/\d+/) {                                                        # no "DATAS"
				if (!exists $menu{$onglet}{'DATAS'}{'require'}    	      		# keep only tabs which lead to installed mods
				     ||
				     foreign_check($menu{$onglet}{'DATAS'}{'require'}, 0)
				   ) {
					if ($titles->[$depth] =~ m/$title/) {                   	# got THE selected onglet
						$selected_onglet=$onglet;               		# and keep it for later
						$selected=1;
					} else {
						$selected=0;
					}
					if ($url) {                                                     # shown only if we got the good args
                                                # check words to replace
                                                my $url2 = $url;                                        # backup copy
                                                my %toreplaces;                                         # will contain words to replace
                                                my $todisplay=0;
                                                while ($url2 =~ s/%([^%]*)%//) {                        
                                                        $toreplaces{$1}++;                              # fill the array
                                                }

                                                $todisplay = 1 if ($toreplaces{'host'} && $host && $host ne "");
                                                $todisplay = 1 if ($toreplaces{'group'} && $group && $group ne "");
                                                $todisplay = 1 if ($toreplaces{'mac'} && $mac && $mac ne "");
                                                $todisplay = 1 if ($toreplaces{'mac_with_dot'} && $mac && $mac ne "");
                                                $todisplay = 1 if ($toreplaces{'mac_with_dot'} && $mac_with_dot && $mac_with_dot ne "");
                                                $todisplay = 1 if ($toreplaces{'group'} && $toreplaces{'group'} && ( $group ne "" || $profile ne "") );
                                                $todisplay = 1 if (lc($menu{$onglet}{'DATAS'}{'dont_shade'}) eq "y");
                                                
                                                $host = "" unless $host;
                                                $group = "" unless $group;
                                                $mac = "" unless $mac;
                                                $mac_with_dot = "" unless $mac_with_dot;
                                                $profile = "" unless $profile;
                                                
                                                if (keys(%toreplaces) == 0 || $todisplay) {
                                                        $url =~ s/(.*)%mac_with_dot%(.*)/$1$mac_with_dot$2/             # perhaps an "mac_with_dot" arg given ?
                                                                if $url =~ m/%mac_with_dot%/;
                                                        $url =~ s/(.*)%mac%(.*)/$1$mac$2/       			# perhaps an "mac" arg given ?
                                                                if $url =~ m/%mac%/;            
                                                        $url =~ s/(.*)%host%(.*)/$1$host$2/     			# perhaps an "host" arg given ?
                                                                if $url =~ m/%host%/;           
                                                        $url =~ s/(.*)%group%(.*)/$1$group$2/     			# perhaps an "host" arg given ?
                                                                if $url =~ m/%group%/;           
                                                        $url =~ s/(.*)%profile%(.*)/$1$profile$2/     			# perhaps an "host" arg given ?
                                                                if $url =~ m/%profile%/;           
                                                        $template->assign('URL', $url);
                                                        if ($label) {                                                   # shown only if there is a label
                                                                $template->assign('NOM_LIEN', $label);
                                                                if ($selected) {                                        # got THE selected onglet
                                                                        $template->assign('IS_SELECTED', 'select');     # so paint it
                                                                } else {
                                                                        $template->assign('IS_SELECTED', 'unselect');   
                                                                }
                                                                $template->assign('WIDTH', $width);                     # width based on the number of onglets
                                                                $template->parse('section_menu.ligne.case.etat:plein');
                                                        }
                                                } else {                                                                # no need to disaply something
                                                        if ($selected) {                   # got THE selected onglet
                                                                $template->assign('IS_SELECTED', 'select');     # so paint it
                                                        } else {
                                                                $template->assign('IS_SELECTED', 'unselect');   
                                                        }
                                                        $template->assign('NOM_LIEN', $label);
                                                        $template->assign('WIDTH', $width);
                                                        $template->parse('section_menu.ligne.case.etat:vide');
                                                }
                                                $template->parse('section_menu.ligne.case');
                                        }
				}
                        }

                }
                $template->parse('section_menu.ligne');
		
		last if (!$selected_onglet);

                %menu=%{$menu{$selected_onglet}};
        }
	
	my $customttb = $tb;
	$customttb =~ s|.*(\#[0-9a-zA-Z]{6}).*|$1|;
	$template->assign('BACKGROUND_COLOR', $customttb);      # so paint it

	my $customtcb = $cb;
	$customtcb =~ s|.*(\#[0-9a-zA-Z]{6}).*|$1|;
	$template->assign('HEADER_COLOR', $customtcb);          # so paint it
	
        $template->parse('section_menu');

        $template->out('section_menu');
}

# Print the end of the menu
sub print_end_menu {

 print <<EOFFENDMENU;
  </div>
EOFFENDMENU
}

# Print the header
sub print_header {
my ($title, $help, $version, $image, $url)=@_;

	$url    	= $LINBOX_URL   unless $url;
	$image  	= $BIGLOGO_URL  unless $image;
	$version        = $VERSION   	unless $version;

	header($title , "", $help, 1, 1, undef, "<a href='$url' style='text-decoration: none;'><img src='$image' style='border: none;'/></a>", "", "", "<font size='-2'>v. $version</font>");
	
	return 0;
}

# loading of the conffile (/etc/lbs.conf) in %lbsconf (global hash).
# we also did some checks: existance of /etc/lbs.conf and of 'basedir'
# param 1 : $file : the conf file's name
# return : nothing #FIXME
sub init_lbs_conf($) {
my $file = shift ;

	$file=$config{'lbs_conf'} if not $file;

	if ($LRS_HERE) {
                if (not -f $file) {                     # config file readable ?
                        header($text{'index_title'}, "", undef, 1, 1, 0, $text{'author'} . "<br><br><font size=-2>version $VERSION</font>");
                        message($text{'tit_error'},text("err_confnf",$file)) ; # FIXME
                        return 0 ;
                }
      
        
                read_env_file($file, \%lbsconf);
        
                if (not exists $lbsconf{'basedir'}) {   # basedir defined ?
                        header($text{'index_title'}, "", undef, 1, 1, 0, $text{'author'} . "<br><br><font size=-2>version $VERSION</font>");
                        message($text{'tit_error'},
                        text("err_paramnf", $lbsconf{'basedir'},$file)) ;
                        return 0 ;
                }
        
                if (not -d $lbsconf{'basedir'}) {       # basedir existing ?
                        header($text{'index_title'}, "", undef, 1, 1, 0, $text{'author'} . "<br><br><font size=-2>version $VERSION</font>");
                        message($text{'tit_error'},text("err_basedirnf", $lbsconf{'basedir'}));
                        return 0 ;
                }

        }

        if (exists $gconfig{'lang'}) {  	# language configuration
                lbsSetLang($gconfig{'lang'}) or lbsSetLang('default') ;
        } else {
               lbsSetLang('default') ;
        }

	return 1 ;
}

# table's generation
# param 1 : $title : the table's title
# param 2 : $top : a ref on the top's labels
# param 3 : $lol : a ref on the table's content
# param 4 : $attribs: a ref on the attribs
# return : nothing #FIXME
sub make_html_table($$$$) {
my ($title, $top, $lol, $attrref) = @_;
my %attr =%{$attrref};

# default values
my $att_rotate 		= 0 ;
my $att_tr_header 	= $tb ;
my $att_tr_body 	= $cb ;
my $att_border 		= 'noborder' ;
my $att_center		= 1;
my $att_cell_center	= 0;

$att_rotate     = $attr{'rotate'}       if (exists($attr{'rotate'})) ;
$att_tr_header  = $attr{'tr_header'}    if (exists($attr{'tr_header'})) ;
$att_tr_body    = $attr{'tr_body'}      if (exists($attr{'tr_body'})) ;
$att_border     = $attr{'border'}       if (exists($attr{'border'})) ;
$att_center     = $attr{'center'}       if (exists($attr{'center'})) ;
$att_center     = $attr{'center'}       if (exists($attr{'center'})) ;
$att_cell_center= $attr{'cell_center'}  if (exists($attr{'cell_center'})) ;

my $out = "" ;

my $oddorevenline=0;    # to distinguish odd and even lines

        my $firstcell=0;
	map {                                                                   # each content of $top become a cell
                if ($firstcell == 1) {
                        $_ = "<td $att_tr_header><b>$_</b></td>"
                } else {
                        $firstcell = 1;
                        $_ = "<td $att_tr_header><b>$_</b></td>"
                }                        
        } @{$top} ;	      	

	foreach (@{$lol}) {                                                     # each content of $lol become a cell
                my $firstcell=0;
                map {
                        if ($firstcell == 1) {
                                $_ = "<td style=\"
                                        padding-left: .5em;
                                        padding-right: .5em; border: 0px solid white; border-left: solid 1px #FCD3C2\">$_</td>"
                        } else {
                                $firstcell = 1;
                                $_ = "<td style=\"padding-left: .5em; padding-right: .5em; border: 0px solid white;\">$_</td>"
                        }                        
                } @{$_} ;
        }    

	unshift @{$lol}, $top ; 						# then we put @top over @lol
	lolRotate($lol) if $att_rotate;					 	# rotate if needeed
	$out .= "<center>" if ($att_center);    				# center if needeed
	
	$out .= "<b><font size=+1>$title</font><br><br></b>"    		if ! ($title eq "");
        $out .= "<table style='border: 1px solid #EA4F26'";
        $out .= " width='100%' " if ($att_center);    
        $out .= "$att_border>\n" ; 		      			# table's heading
	foreach (@{$lol}) {  	# table's content
                $out .= '<tr style="background-color:'
                        . oddorevenline(\$oddorevenline)
                        . '">'
                        . join("", @{$_} )
                        . "</tr>\n";
        }
	$out .= "</table>" ;    						# table's end
	
	$out .= "</center>" if ($att_center);    				# center if needeed

return $out ;
}

# Deep copy
sub deep_copy {
      my $this = shift;
      if (not ref $this) {
	        $this;
      } elsif (ref $this eq "ARRAY") {
          [map deep_copy($_), @$this];
      } elsif (ref $this eq "HASH") {
        +{map { $_ => deep_copy($this->{$_}) } keys %$this};
      } else { die "what type is $_?" }
}					  

# table's printing
# param 1 : $paramsref: a ref on a hash containning a bunch of parameters
# return : nothing #FIXME
sub print_machines_list {
        my ($paramsref, $headcallbacksref, $bodycallbacksref) = @_;

        my $home=$TFTPBOOT;

        my $baseuri=$paramsref->{'baseuri'};
        $baseuri = $ENV{'SCRIPT_NAME'} unless $baseuri;

        my $nowrap=$paramsref->{'nowrap'};
        if ($nowrap == 1) {
                $nowrap = "NOWRAP" 
        } else {
                $nowrap = "";
        }
                
        my $firstcellwidth=$paramsref->{'width'};
        $firstcellwidth = "WIDTH=\"$firstcellwidth\"" if $firstcellwidth;

        my ( $n, $un );
        my ( $ip, $mac, $umac, $size, $dummy, $nb, $g, $nn);
        my $name_url;
        my $info_url;
        
        my $template = new Qtpl("$TEMPLATES_PATH/mainlist.tpl");        # first to be printed
        my $template2 = new Qtpl("$TEMPLATES_PATH/mainlist.tpl");       # and second to be printed

        # main title
        $template->assign('REGISTRED_CLIENTS', $text{'tab_index'});
        $template->parse('mainlist.title');

        # search field
        $template->assign('QUICKSEARCH', $text{'lab_quicksearch'});
        $template->assign('ADVSEARCH', main::text('lab_searchadv'));
        $template->parse('mainlist.searchform') if ($paramsref->{'searchform'});

        my %ether;							# ethernet addresses
        my $einfo=\%ether;                                              # ref on ethernet addresses

        # MAC hash loading
        if ($LRS_HERE) {                                                # LRS mode
                etherLoad("$home/etc/ether" , \%ether);                 # ethernet adresses load, using LRS database
        } else {                                                        # no LRS installe
	        ocsLoad("$home/etc/ether" , \%ether);                   # ethernet adresses load, using OCS database
        }
	
	my $ethero = deep_copy(\%ether);	# backup
	
        # nr. of displayed machines limited
	if (defined $in{'max_displayed_clients'}) {      		
		my $maxmachines=$in{'max_displayed_clients'};
		my %ether2;
		
		foreach my $key(keys %ether) {
			last if (!$maxmachines);
			$ether2{$key}=$ether{$key};
			$maxmachines--;
		}
		
		%ether=%ether2;
	}
	
        # huge error message if no host is registred
	if ( keys(%ether) == 0) {
		print "<h2><center>", $text{'msg_index_empty'}, "</h2></center>";
		return;
	}

        # all right: we got the hash, let's reformat-it a little (aka NORMALISATION)
        normalize_machine_names(\%ether);
        
        $in{'profile'} = "" unless $in{'profile'};
        my %profiles;
        my ($profile_key, $profile_name);

	%profiles = get_all_profiles(%ether);
	#if ($LRS_HERE) { %profiles = get_all_profiles(%ether) };

        # PROFILS parsing
        if ( (lc($in{'profile'}) eq "all") || ($in{'profile'} eq "") ) {
                
                # keep all machines, simply remove the leading ":" and the profile name
                foreach my $key (keys %ether) {
                        $ether{$key}[2] = $ether{$key}[1];
                        $ether{$key}[2] =~ s|^(.*):.*$|$1|;
                        $ether{$key}[1] =~ s|^.*:(.*)$|$1|;
                }
                
                # first tab is selected
                $template->assign('IS_SELECTED', "selected");
                $template->assign('URL', "?profile=all");
                $template->assign('PROFIL', text("lab_all"));
                $template->parse('mainlist.profils.profil');
                
                # and others are not
                foreach my $key (keys %profiles) {
                        $template->assign('IS_SELECTED', "unselected");
                        $template->assign('URL', "?profile=$key");
                        $template->assign('PROFIL', $key);
                        $template->parse('mainlist.profils.profil');
                }
                
                $template->assign('IS_SELECTED', "unselected");
                $template->assign('URL', "?profile=none");
                $template->assign('PROFIL', text("lab_unprofiled"));
                $template->parse('mainlist.profils.profil');
                
                $profile_key = "all";
                $profile_name = text("lab_all");
        } elsif ( (lc($in{'profile'}) eq "none") ) {
                
                # keep every no-profiled machines and remove the leading ":" and the profile name
                foreach my $key (keys %ether) {
                        $ether{$key}[2] = $ether{$key}[1];
                        $ether{$key}[2] =~ s|^(.*):.*$|$1|;
                        $ether{$key}[1] =~ m|^(.*):(.*)$|;
                        if ($1 eq "") {
                                $ether{$key}[1] = $2;
                        } else {
                                delete $ether{$key};
                        }
                }
                
                # leading tabs are not selected
                $template->assign('IS_SELECTED', "unselected");
                $template->assign('URL', "?profile=all");
                $template->assign('PROFIL', text("lab_all"));
                $template->parse('mainlist.profils.profil');

                foreach my $key (keys %profiles) {
                        $template->assign('IS_SELECTED', "unselected");
                        $template->assign('URL', "?profile=$key");
                        $template->assign('PROFIL', $key);
                        $template->parse('mainlist.profils.profil');
                }

                # but last is
                $template->assign('IS_SELECTED', "selected");
                $template->assign('URL', "?profile=none");
                $template->assign('PROFIL', text("lab_unprofiled"));
                $template->parse('mainlist.profils.profil');
                
                $profile_key = "none";
                $profile_name = text("lab_unprofiled");
        } else {
                # keep profiled-with-the-selected-profile machines and remove the leading ":" and the profile name
                foreach my $key (keys %ether) {
                        $ether{$key}[2] = $ether{$key}[1];
                        $ether{$key}[2] =~ s|^(.*):.*$|$1|;
                        $ether{$key}[1] =~ m|^(.*):(.*)$|;
                        if ($1 eq $in{'profile'}) {
                                $ether{$key}[1] = $2;
                        } else {
                                delete $ether{$key};
                        }
                }
                
                $template->assign('IS_SELECTED', "unselected");
                $template->assign('URL', "?profile=all");
                $template->assign('PROFIL', text("lab_all"));
                $template->parse('mainlist.profils.profil');

                foreach my $key (keys %profiles) {
                        if ($key eq $in{'profile'}) {
                                $template->assign('IS_SELECTED', "selected");
                                $profile_key = $key;
                                $profile_name = $key;
                        } else {
                                $template->assign('IS_SELECTED', "unselected");
                        }
                        $template->assign('URL', "?profile=$key");
                        $template->assign('PROFIL', $key);
                        $template->parse('mainlist.profils.profil');
                }

                # last tab is selected
                $template->assign('IS_SELECTED', "unselected");
                $template->assign('URL', "?profile=none");
                $template->assign('PROFIL', text("lab_unprofiled"));
                $template->parse('mainlist.profils.profil');

        }
        
        $template->parse('mainlist.profils');

        # TOP labels computing
        $template->assign('TB', $tb);

        # first column is hard-coded
        $template->assign('TITLE', "<div style='text-align: center;'>".main::text('lab_name')."</div>");
        $template->parse('mainlist.toprow.topcell');
        
        foreach my $headcallback (@$headcallbacksref) {
                foreach my $label (&$headcallback({'currentprofile' => $in{'profile'}})) {
                        if (defined($label) and $label) {
                                my %localhash=%$label;          
                                $template->assign('TITLE', $localhash{'content'});
                                $template->assign('ATTRIBS', $localhash{'attribs'});
                                $template->parse('mainlist.toprow.topcell');
                        }
                }
        }
        $template->parse('mainlist.toprow');

        my $id = "$baseuri?wol=0";     				# wol options ? 
        $in{wol} = 0 unless $in{wol};
	$id = "$baseuri?wol=1" if ( (%in) && ($in{wol} == 1) );
    
        $template->parse('mainlist.starttable');
        
        my %groups;
	
	%groups = get_all_groups(0, %ether);
	#if ($LRS_HERE) { %groups = get_all_groups(0, %ether); }
        
	$in{group}=""   if (!$in{group});       			# some init;
	$in{wol}=0      if (!$in{wol});
	
	my @allgroups = sort( keys(%groups) );  			# sort groups

        my $lineisodd  = 0;                     # 0 for even, !0 for odd
        
        my @tmpcols;
	foreach my $name (etherGetNames($einfo)) {      # add "/" to every entry to enable sorting
		my $g;

		foreach my $group(sort(keys(%groups))) {		# for each not already displayed group
			if (defined($groups{$group})) {
				my $group_url = urlize($group);
                                my @localcount=split '/', $group;
				my $level=@localcount;
				if ($name =~ m|$group/|) {      		# if the current machine belong to the current group: we must draw the group before
					my $grouplabel = 0;
					
					my $basegroup = $group;
					my $parentgroup = $group;
					
					$group =~ m|(.+)/([^/]+)|;
					$basegroup=$2 || $group;
					$parentgroup =$1 || $group;
					
					if ($in{'group'} eq $group) {      # our selected group ?
						$grouplabel = "<table class='noborder'><tr><td class='noborder' nowrap>" . "&nbsp;" x (5 * ($level-1)) . "<img align='middle' src='$IMAGES_URL/folder-open.gif'>&nbsp;<a name=\"$group_url\" href='$id&profile=$in{profile}&group=$parentgroup#$parentgroup'><b>$basegroup</b></a></td></tr></table>";
					} elsif ($in{'group'} =~ m|$group/|) {  # a parent group ?
						$grouplabel = "<table class='noborder'><tr><td class='noborder' nowrap>" . "&nbsp;" x (5 * ($level-1)) . "<img align='middle' src='$IMAGES_URL/folder-open.gif'>&nbsp;<a name=\"$group_url\" href=\"$id&profile=$in{profile}&group=$group_url#$group_url\"><b>$basegroup</b></a></td></tr></table>";
					} elsif ($group =~ m|^$in{'group'}/|){
						$grouplabel = "<table class='noborder'><tr><td class='noborder' nowrap>" . "&nbsp;" x (5 * ($level-1)) . "<img align='middle' src='$IMAGES_URL/folder-closed.gif'>&nbsp;<a href=\"$id&profile=$in{profile}&group=$group_url#$group_url\"><b>$basegroup</b></a></td></tr></table>";
					} else {
						my $partialgroup = $group;
						if (!($partialgroup =~ s|^(.+/)[^/]+$|$1|)) { # first level group, always displayed  
							$grouplabel = "<table class='noborder'><tr><td class='noborder' nowrap>" . "&nbsp;" x (5 * ($level-1)) . "<img align='middle' src='$IMAGES_URL/folder-closed.gif'>&nbsp;<a href=\"$id&profile=$in{profile}&group=$group_url#$group_url\"><b>$basegroup</b></a></td></tr></table>";
						} elsif ($in{'group'} =~ m|$partialgroup|) {  # a brother / sister group
							$grouplabel = "<table class='noborder'><tr><td class='noborder' nowrap>" . "&nbsp;" x (5 * ($level-1)) . "<img align='middle' src='$IMAGES_URL/folder-closed.gif'>&nbsp;<a href=\"$id&profile=$in{profile}&group=$group_url#$group_url\"><b>$basegroup</b></a></td></tr></table>";
						}
					}
					undef $groups{$group};  		# undef already drawn dirs
					
					if ($grouplabel) {
                                                
                                                # special: name is drown from here
                                                $template->assign('ROWSTYLE', "style='background-color: ".oddorevenline(\$lineisodd).";'");
                                                $template->assign('CONTENT', $grouplabel);
                                                $template->assign('FIRSTCELLARGS', "$nowrap $firstcellwidth");
                                                $template->parse('mainlist.normalrow.firstcell');
                                                foreach my $bodycallback (@$bodycallbacksref) {
                                                        my $profile;
                                                        $profile = $in{'profile'} if ($in{'profile'} ne "none" and $in{'profile'} ne "all");
                                                        foreach my $label (&$bodycallback({'currentprofile' => $in{'profile'}, 'group' => $group, 'profile' => $profile, 'ether' => $ethero } )) {
                                                                if (defined($label) and $label) {
                                                                        my %localhash=%$label;                                                                        
                                                                        $template->assign('CONTENT', $localhash{'content'});
                                                                        $template->assign('ATTRIBS', $localhash{'attribs'});
                                                                        $template->parse('mainlist.normalrow.normalcell');
                                                                }
                                                        }
                                                }

                                                $template->parse('mainlist.normalrow');
					}
				}
			}
		}

		if ( $name =~ m|^(.+)/([^/]+)$| ) {        		# we found a group
			$g  = $1;
			$nn = $2;
			my $indic = 0;
			$indic = 1 if ($in{'group'} =~ m|^$g$|);
			$indic = 1 if ($in{'group'} =~ m|^$g/|);
			next if (!$indic);
		} else {						# single machine
			$g  = "";
			$nn = $name;
                        $nn =~ s|^/(.*)$|$1|;
		}

		my $mac = etherGetMacByName($einfo, $name ) || '?';    # got the mac address
                my $macfile = toMacFileName($mac);      		# it's file

		my $ip = etherGetIpByMac( $einfo, $mac ) || '?';	# and it's IP address
		my $umac = urlize($mac);   				# some translation

		$un = html_escape($nn); 				# « url-ize» a part of the name
		$un = colorStatus( 2, $nn ) if ( (not -f "$home/images/$macfile/header.lst") && $LRS_HERE ); # and colorize it if needed # FIXME: hard coded path

		$name_url ="<img align='middle' src='$IMAGES_URL/computer.gif'>&nbsp;<b>$un</b>&nbsp;";

                my @localcount=split '/', $name;
                my $level=@localcount;
		$name_url = "<table class='noborder'><tr><td class='noborder' nowrap>" . "&nbsp;" x (5 * ($level - 1)) . $name_url . "</td></tr></table>" if ( $g ne "" ); 	# indent if needeed

		if ( $g eq "" ) {       					# hosts not in a group are last on the list
                        # special: name is drown from here
                        my @tmprow;
                        push @tmprow, $name_url;
                        foreach my $bodycallback (@$bodycallbacksref) {
                                foreach my $label (&$bodycallback({'name' => $name, 'mac' => $mac, 'profile' => $ether{$mac}[2], 'currentprofile' => $in{'profile'}, 'ether' => $ethero })) {
                                        if (defined($label) and $label) {
                                                my %localhash=%$label;                                                                        
                                                push @tmprow, $localhash{'content'};
                                        }
                                }
                        }
                        push @tmpcols, \@tmprow;
		} else {
                        # special: name is drown from here
                        $template->assign('ROWSTYLE', "style='background-color: ".oddorevenline(\$lineisodd).";'");
                        $template->assign('CONTENT', $name_url);
                        
                        $template->assign('FIRSTCELLARGS', "$nowrap $firstcellwidth");
                        $template->parse('mainlist.normalrow.firstcell');
                        foreach my $bodycallback (@$bodycallbacksref) {
                                foreach my $label (&$bodycallback({'name' => $name, 'mac' => $mac, 'profile' => $ether{$mac}[2], 'currentprofile' => $in{'profile'}, 'ether' => $ethero })) {
                                        if (defined($label) and $label) {
                                                my %localhash=%$label;                                                                        
                                                $template->assign('CONTENT', $localhash{'content'});
                                                $template->assign('ATTRIBS', $localhash{'attribs'});
                                                $template->parse('mainlist.normalrow.normalcell');
                                        }
                                }
                        }
                        $template->parse('mainlist.normalrow');
		}
	}

        foreach my $row (@tmpcols) {
                $template->assign('ROWSTYLE', "style='background-color: ".oddorevenline(\$lineisodd).";'");
                
                # first cell is always special (dedicated border)
                my $cell = shift @$row;
                $template->assign('CONTENT', $cell);
                $template->assign('FIRSTCELLARGS', "$nowrap $firstcellwidth");
                $template->parse('mainlist.normalrow.firstcell');
                
                foreach my $cell (@$row) {
                        $template->assign('CONTENT', $cell);
                        $template->parse('mainlist.normalrow.normalcell');
                }
                $template->parse('mainlist.normalrow');
        }
        
        if (lc($profile_key) ne "none" and lc($profile_key) ne "all") {
                $template->assign('ACTIONONCURRENTPROF', text('lab_thisprofile', $profile_name));
                foreach my $bodycallback (@$bodycallbacksref) {
                        foreach my $label (&$bodycallback({'currentprofile' => $in{'profile'}, 'profile' => $in{'profile'}, 'ether' => $ethero })) {
                                if (defined($label) and $label) {
                                        my %localhash=%$label;                                                                        
                                        $template->assign('CONTENT', $localhash{'content'});
                                        $template->assign('ATTRIBS', $localhash{'attribs'});
                                        $template->parse('mainlist.endtable.moreactions.uppercell');
                                }
                        }
                }
                $template->parse('mainlist.endtable.moreactions');
        }
        
        $template->parse('mainlist.endtable');
        $template->parse('mainlist');
        $template->out('mainlist');

	return 1;
}

#
# This function is searching the directory with the ETHERNET addreses
# and is giving back the array filled with this addresses 
# taken from function searchEtherInOCS() in lbs_common.php
# FIXME
sub ocsLoad() {
	my ($directory, $etherref)=@_;
	# FIXME: chemin_csv should be taken from lbs-inventory's conf
	# (or perhaps lbs-inventory should take it's conf from lbs_common ?)
	my $basedir="/var/lib/ocsinventory/Network";
		
	# list the ethernet mac address found in the OCS inventory dir
	if (opendir OCSDIR, $basedir) {
		my @maclist = grep { -r "$basedir/$_" } grep { -l "$basedir/$_" } readdir OCSDIR;

		foreach my $macaddr (@maclist) {
			my $newmacaddr=$macaddr;
                        $newmacaddr =~ s|
                                ([0-9A-F]{2})
                                ([0-9A-F]{2})
                                ([0-9A-F]{2})
                                ([0-9A-F]{2})
                                ([0-9A-F]{2})
                                ([0-9A-F]{2})
                                |$1:$2:$3:$4:$5:$6|x;
                        if (!$etherref->{"$macaddr"}) {
                                open INVENTORY, "$basedir/$macaddr";
                                while (<INVENTORY>) {
                                        if (m/(^[^\;]+);.*;$newmacaddr;[^\;]+;([^\;]+)/) {
						my $name = $1;
						my $ip = $2;
						
						# Remove -2005-03-16-19-15-50 at the end of the name (OCSv3)
						$name =~ s/-[1-9][0-9][0-9][0-9]-[-0-9]+$//;
                                                $etherref->{"$newmacaddr"}=[$ip, $name];
                                        }
                                }
                                close INVENTORY;
                        }
		}
        }
}

# colorStatus($status,$text)
# Change an HTML text color depending the $status value (0,1 or 2).
#
sub colorStatus {
 my $status = shift ;
 my $msg = join(" ",@_) ;
 my $c ;
 
 if    ($status == 0) { $c = "#000000" ;}
 elsif ($status == 1) { $c = "#cc7000" ;}
 else  { $c = "#BB0000" ;}
 
 return "<font color=$c>$msg</font>" ;
}

# get the user's language
# return : ISO language
sub get_language() {
	
	if ($current_lang) {
		return $current_lang;
	} else {
		return $gconfig{'lang_root'};
	}
	
}

# convert the MAC from NOT-colums notation to colums notation
# param 1 : $mac : the mac adress with (or not ;) columns
# return : the mac address without any column
sub mac_remove_columns($) {
my $mac=shift;
        $mac =~ tr/://d if $mac;
        return $mac;
}

# convert the MAC from NOT-colums notation to colums notation
# param 1 : $mac : the mac adress without columns
# return : the mac address with some column
sub mac_add_columns($) {
my $mac=shift;

        return join ':', grep /[0-9A-Fa-f]{2}/, split /([0-9A-Fa-f]{2})/, $mac      if $mac;
}

# encode query in uuencode form
# param 1: the query
# return: the encoded query
sub url_encode {
    my $text = shift;
    $text =~ s/([^a-z0-9_.!~*'(  ) -])/sprintf "%%%02X", ord($1)/ei     if $text;
    $text =~ tr/ /+/    						if $text;
    return $text;
}

# decode query in uuencode form
# param 1: the encoded query
# return: the query
sub url_decode {
    my $text = shift;
    $text =~ tr/\+/ /;
    $text =~ s/%([a-f0-9][a-f0-9])/chr( hex( $1 ) )/ei;
    return $text;
}

# display the free disk space
# param 1 : $path : the path belonging to the partition
# return: nothing #FIXME
sub show_free_disk {
my $path=shift;
my @list;
my @header;
my @lol=();
my $i;

$path=$TFTPBOOT unless $path;

	@header=(text('lab_disk'), text('lab_total'), text('lab_used'), text('lab_free'), "%", text('lab_mount'));
	@list=split ' ',`df -Ph $path | tail -1`;
	push @lol,[@list];
	print make_html_table(text('lab_space'), \@header, \@lol, {});
}

# display some versions
sub show_versions {
my $path=shift;
my @list;
my @header;
my @lol=();
my @webminmodules=qw '  lbs             lbs-cd          lbs_common
                        lbs-inventory   lbs-vnc         backuppc';

my @lrsmodules=qw '     backuppc        php4-cgi        lbs
                        iproute';

	@header=(text('lab_module'), text('lab_version'));
	@list=("kernel", (get_server_kernel_version() or text('lab_unknown')));
	push @lol,[@list];
	@list=("initrd", (get_client_initrd_version() or text('lab_unknown')));
	push @lol,[@list];
	@list=("revoboot", (get_client_revoboot_version() or text('lab_unknown')));
	push @lol,[@list];

        foreach my $package (sort @lrsmodules) {
                @list=($package, (
                                        get_debian_package_version($package)
                                or
                                        text('lab_unknown')
                      ));
                push @lol,[@list];
        }

        foreach my $package (sort @webminmodules) {
                @list=("webmin-$package", (
                                        get_webmin_package_version($package)
                                or
                                        get_debian_package_version("webmin-$package")
                                or
                                        text('lab_unknown')));
                push @lol,[@list];
        }
        
	print make_html_table(text('lab_versions'),\@header,\@lol, {});
}


# lolRotate(\@lol )
# Rotation d'un tableau 2D. Les lignes deviennent des colonnes, ou inversement.
# Argument: la ref d'une LoL (List of Lists).
# Retourne toujours 1.
# Note: toutes les lignes (ou colonne) doivent avoir le meme nombre d'elements.
#
sub lolRotate($) {
my $out = $_[0] ;
my @lol = ( @{$_[0]} ) ;  # Copie reelle de l'argument.
my @row ;
my ($x, $y) ;

	@{$out} = () ;
	
	for ($x=0; $x<scalar(@{$lol[0]}); $x++) {
		@row = () ;
		
		for ($y=0; $y<scalar(@lol) ; $y++) {
			push @row, $lol[$y][$x] ;
		}
		
		push @{$out}, [ @row ] ;
	}

}

# message($title, $message)
#
sub message {
 &header($_[0], "", "index", 1, 1, undef, undef);
 print "<p>" . $_[1] . "</p>" ;
 &footer(undef,undef) ;
}

#
# Check if get client response runs, and output a message if not
#
sub checkfordaemon {
    if (! -r $config{'lbs_conf'}) { return; }
        
    my $run = system ("ps ax|grep -v grep|grep -q getClientResponse");
    my $run2 = system ("ps ax|grep -v grep|grep -q lrsd");
    if ($run != 0 && $run2 != 0)
	{
	    print "<font size='+2' color='red'><br>";
	    print $text{'err_gcr_not_running'};
	    print "<br><br></font>";
	}
}

#
# get a directory's size, using du
sub get_directory_size {
my $directory=shift;
my $fake = shift;
my $cachefile="$directory/.directorysize.txt";
my $ducmd="/usr/bin/du -ks";
	
        return if defined $fake;

	return 0 if (! -d $directory);

        # cache created if doesn't exists
	if (! -r $cachefile) {
		system("$ducmd $directory > $cachefile");
	}

        my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks) = stat ($cachefile);
        my ($dev2,$ino2,$mode2,$nlink2,$uid2,$gid2,$rdev2,$size2,$atime2,$mtime2,$ctime2,$blksize2,$blocks2) = stat ("$directory/.");
        
        # cache is flushed if current directory has been changed
        if ($ctime2 > $mtime) {
		system("$ducmd $directory > $cachefile");
        }
        
        # read the cache once flushed
	open CACHEFILE, $cachefile;
	while(<CACHEFILE>) {
		return $1 if m/^([0-9]+)\s+.*$/;
		
	}
	close CACHEFILE;
}

#
# get a directory's number of images, using du
sub get_directory_numofimages {
my $directory=shift;
my $fake = shift;
my $cachefile="$directory/.directorynumofimages.txt";
my $ducmd="/usr/bin/du -k";
my $nb=0;
	
        return if defined $fake;

	return 0 if (! -d $directory);
        
        # cache created if doesn't exists
	if (! -r $cachefile) {
		system("$ducmd $directory > $cachefile");
	}
        my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks) = stat ($cachefile);
        my ($dev2,$ino2,$mode2,$nlink2,$uid2,$gid2,$rdev2,$size2,$atime2,$mtime2,$ctime2,$blksize2,$blocks2) = stat ("$directory/.");
        
        # cache is flushed every hour
        if ($ctime2 > $mtime) {   
		system("$ducmd $directory > $cachefile");
        }
        
        # read the cache once flushed
	open CACHEFILE, $cachefile;
	while(<CACHEFILE>) {
		$nb++ if ( !/Backup-[BL]/ );
	}
	close CACHEFILE;

       	$nb-- if ( $nb > 0 );
        
        return $nb;
}


#
# get a directory's size, using du
#
sub get_group_size {
    my ($group, $profile, $etherref, $fake )=@_;
    my $home=$lbsconf{'basedir'};
    my %ether;
    my $size=0;

    return if $fake;

    if (!$etherref) {
	etherLoad("$home/etc/ether" , \%ether);
	$etherref = \%ether;
    }

    normalize_machine_names($etherref);

    foreach my $mac (etherGetMacsFilterName($etherref, "^.*:?$group\/")) {
	if ($profile) {
	    $size += get_directory_size("$home/images/" . mac_remove_columns ($mac) )
		if (etherGetNameByMac($etherref, $mac) =~ m|^$profile:$group/|);
	} else {
	    $size += get_directory_size("$home/images/" . mac_remove_columns ($mac) )
	}
    }
    return $size;
}

#
# get a directory's number of images, using du
#
sub get_group_numofimages {
    my ($group, $profile, $etherref, $fake)=@_;
    my $home=$lbsconf{'basedir'};
    my %ether;
    my $count=0;

    return if $fake;

    if (!$etherref) {
	etherLoad("$home/etc/ether" , \%ether);
	$etherref = \%ether;
    }
    
    normalize_machine_names($etherref);
    
    foreach my $mac (etherGetMacsFilterName($etherref, "^.*:?$group\/")) {
	if ($profile) {
	    $count += get_directory_numofimages("$home/images/" . mac_remove_columns ($mac) )
		if (etherGetNameByMac($etherref, $mac) =~ m|^$profile:$group/|);
	} else {
	    $count += get_directory_numofimages("$home/images/" . mac_remove_columns ($mac) )
	}
	
    }
    return $count;
}


# lbsSetLang($lang) # FIXME: simple proto included from lbs-lib.pl, what it it supposed to contain ?
#
sub lbsSetLang
{
1;
}

sub oddorevenline ($) {
        my $lineisoddref=shift;
        $$lineisoddref = !$$lineisoddref;

        return "#F0F0F0" if ($$lineisoddref);
        return "#F9F9F9";
}

# returns all profiles { profile => # of machines in profile }
sub get_all_profiles() {
        my $home=$lbsconf{'basedir'};
        my %profiles;
        my %ether=@_;
        
	foreach (etherGetNames(\%ether) ) {      		# subdivide groups (yes, dirty, but enough for now)
		$profiles{"$1"}++ if (m|^(.+):.*$|);
	}
        
        return %profiles;
}

# returns all groups { group => # of machines in group }
sub get_all_groups() {
        my %groups;
        my ($Ishouldremoveleadingcolumns, %ether)=@_;
        
        if ($Ishouldremoveleadingcolumns) {
                foreach (etherGetNames(\%ether) ) {      		# subdivide groups (yes, dirty, but enough for now)
                        $groups{"$1"}++ if (m|^.*:(.+)/[^/]+$|);
                        $groups{"$1"}++ if (m|^.*:(.+)/[^/]+/[^/]+$|);
                        $groups{"$1"}++ if (m|^.*:(.+)/[^/]+/[^/]+/[^/]+$|);
                        $groups{"$1"}++ if (m|^.*:(.+)/[^/]+/[^/]+/[^/]+/[^/]+$|);
                        $groups{"$1"}++ if (m|^.*:(.+)/[^/]+/[^/]+/[^/]+/[^/]+/[^/]+$|);
                        $groups{"$1"}++ if (m|^.*:(.+)/[^/]+/[^/]+/[^/]+/[^/]+/[^/]+/[^/]+$|);
                        $groups{"$1"}++ if (m|^.*:(.+)/[^/]+/[^/]+/[^/]+/[^/]+/[^/]+/[^/]+/[^/]+$|);
                }
        } else {
                foreach (etherGetNames(\%ether) ) {      		# subdivide groups (yes, dirty, but enough for now)
                        $groups{"$1"}++ if (m|^(.+)/[^/]+$|);
                        $groups{"$1"}++ if (m|^(.+)/[^/]+/[^/]+$|);
                        $groups{"$1"}++ if (m|^(.+)/[^/]+/[^/]+/[^/]+$|);
                        $groups{"$1"}++ if (m|^(.+)/[^/]+/[^/]+/[^/]+/[^/]+$|);
                        $groups{"$1"}++ if (m|^(.+)/[^/]+/[^/]+/[^/]+/[^/]+/[^/]+$|);
                        $groups{"$1"}++ if (m|^(.+)/[^/]+/[^/]+/[^/]+/[^/]+/[^/]+/[^/]+$|);
                        $groups{"$1"}++ if (m|^(.+)/[^/]+/[^/]+/[^/]+/[^/]+/[^/]+/[^/]+/[^/]+$|);
                }
        }
        
        return %groups;
        
}

# normalize machine names
sub normalize_machine_names ($) {
        my $etheerref=shift;
        
        foreach my $key (keys %$etheerref) {
                # add a ":" in front of if no profile specified
                $etheerref->{$key}[1] =~ s|^([^:]*)$|:$1|;
                # add a "/" in front of if no profile specified
                $etheerref->{$key}[1] =~ s|^(.*:)([^/]*)$|$1/$2|;
        }
        # from now each machine has a name like this: profile:group/subgroup/../machine
        
}

# retain only machines belonging to the given group and profile

sub filter_machines_names($$$) {
        my ($profile, $group, $etheerref)=@_;
        
        lbs_common::normalize_machine_names($etheerref);
        
        foreach my $mac(keys %$etheerref) {
                my $name=$etheerref->{$mac}[1];
                delete $etheerref->{$mac} unless (    ($name =~ m/^$profile:$group/)
                        ||
                        (($profile eq "") and ($name =~ m|:?/?$group|))
                        ||
                        (($group eq "") and ($name =~ m/^$profile:/))
                   );
        }
        

}

# displays a date $timestamp using $datefmt
sub timestamp2date ($) {
        my $timestamp = shift;
        my $datefmt   = "%Y-%m-%d %H:%M";
        
        my $commandline="/bin/date -d '1970-01-01 UTC $timestamp seconds' +\"$datefmt\"";
        return `$commandline`;
}

# return the client's initrd version
sub get_client_initrd_version {
        my $initrdversion = `$REALPATH $TFTPBOOT/bin/initrd.gz`;
        $initrdversion =~ s|.*\.([^\.]+)\.gz|$1|;
        $initrdversion =~ tr/_/-/;
        return $initrdversion;
}

# return the client's revoboot version
sub get_client_revoboot_version {
        my $revobootversion = `$REALPATH $TFTPBOOT/bin/revoboot.pxe`;
        $revobootversion =~ s|.*\.([^\.]+)$|$1|;
        $revobootversion =~ tr/_/-/;
        return $revobootversion or text('lab_unknown');
}

# return the server's kernel version
sub get_server_kernel_version {
        return `/bin/uname -r` or text('lab_unknown');

}

# return the available space
sub get_server_free_space {
        return `/bin/df -h` or text('lab_unknown');
}

# return the network configuration
sub get_server_net_conf {
        return `/sbin/ifconfig` or text('lab_unknown');
}

# return the available ram
sub get_server_free_memory {
        return `/usr/bin/free` or text('lab_unknown');
}

# return /tftpboot/revoboot content
sub get_server_tftpboot_content {
        return `ls -lR $TFTPBOOT` or text('lab_unknown');
}

# return a server's package version
sub get_debian_package_version {
        my $package = shift;
        my @lines = grep {/^ii\W+$package/} split '\n', `/usr/bin/dpkg -l $package`;
        my $version = pop @lines;
        $version =~ s/^ii\W+[^ ]+\W+([^ ]+)\W+.*/$1/;
        return $version;
}

# return a server's package version
sub get_webmin_package_version {
        my $package = shift;
        my $config_file = "$root_directory/$package/module.info";
        my $version;
        
        open CONFIGFILE, $config_file or return undef;
        
        while (<CONFIGFILE>) {
                $version = $1 if m/^version\s*=\s*(.*)$/;
        }

        close CONFIGFILE;
        return $version;
}

# return a list of machines corresponding to some criteria (name / ig / group / profile)
# first arg is a regular hashref
# second arg is a regexp
sub keep_machines_by_name {
        my $regexp = shift;
        my $hashref = shift;
        my $argsforregexp = shift;
        
        foreach my $key (keys %$hashref) {
                if (lc($argsforregexp) eq "i") {
                        delete ${%$hashref}{$key} unless ${%$hashref}{$key}[1] =~ m/$regexp/i;
                } else {
                        delete ${%$hashref}{$key} unless ${%$hashref}{$key}[1] =~ m/$regexp/;
                }
        }
}

sub keep_machines_by_id {
        my $regexp = shift;
        my $hashref = shift;
        my $argsforregexp = shift;
        my %ether2 = dup_machines_list(%$hashref);
        normalize_machine_names(\%ether2);
        
        foreach my $key (keys %ether2) {
                $ether2{$key}[1] =~ s|.*/([^/]+)$|$1|;
        }
        
        keep_machines_by_name($regexp, \%ether2, $argsforregexp);

        foreach my $key (keys %$hashref) {
                delete ${%$hashref}{$key} unless $ether2{$key};
        }
}


sub keep_machines_by_group {
        my $regexp = shift;
        my $hashref = shift;
        my $argsforregexp = shift;
        my %ether2 = dup_machines_list(%$hashref);
        normalize_machine_names(\%ether2);
        
        foreach my $key (keys %ether2) {
                $ether2{$key}[1] =~ s|.*:([^:]+)/[^/]*$|$1|;
        }
        
        keep_machines_by_name($regexp, \%ether2, $argsforregexp);

        foreach my $key (keys %$hashref) {
                delete ${%$hashref}{$key} unless $ether2{$key};
        }
}

sub keep_machines_by_profile {
        my $regexp = shift;
        my $hashref = shift;
        my $argsforregexp = shift;
        my %ether2 = dup_machines_list(%$hashref);
        normalize_machine_names(\%ether2);
        
        foreach my $key (keys %ether2) {
                $ether2{$key}[1] =~ s|([^:]*):.*$|$1|;
        }
        
        keep_machines_by_name($regexp, \%ether2, $argsforregexp);

        foreach my $key (keys %$hashref) {
                delete ${%$hashref}{$key} unless $ether2{$key};
        }
}

sub keep_machines_by_mac {
        my $regexp = shift;
        my $hashref = shift;

        foreach my $key (keys %$hashref) {
                my $newkey = mac_remove_columns($key);
                my $newregexp = mac_remove_columns($regexp);
                
                delete ${%$hashref}{$key} unless $newkey =~ m/$newregexp/i;
        }
}

sub merge_machines_list {
}

# duplicate a machine list
sub dup_machines_list {
        my (%hash) = @_;
        
        my %newhash;
        
        foreach my $key (keys %hash) {
                $newhash{$key}[0] = $hash{$key}[0];
                $newhash{$key}[1] = $hash{$key}[1];
                $newhash{$key}[2] = $hash{$key}[2];
        }
        
        return %newhash;
}

1;
