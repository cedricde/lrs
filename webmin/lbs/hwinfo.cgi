#!/usr/bin/perl

require "lbs-common.pl" ;
initLbsConf($config{'lbs_conf'}) or exit(0) ;
#require "lbs-lib.pl" ;

%partypes = (
	 '0', 'Empty',
	 '1', 'FAT12',
	 '2', 'XENIX root',
	 '3', 'XENIX usr',
	 '4', 'FAT16 <32M',
	 '6', 'FAT16',
	 '7', 'HPFS/NTFS',
	 '8', 'AIX',
	 '9', 'AIX bootable',
	 'a', 'OS/2 boot manager',
	 'b', 'Win95 FAT32',
	 'c', 'Win95 FAT32 LBA',
	 'e', 'Win95 FAT16 LBA',
	'10', 'OPUS',
	'11', 'Hidden FAT12',
	'12', 'Compaq diagnostic',
	'14', 'Hidden FAT16 < 32M',
	'16', 'Hidden FAT16',
	'17', 'Hidden HPFS/NTFS',
	'18', 'AST Windows swapfile',
	'1b', 'Hidden Win95 FAT (1b)',
	'1c', 'Hidden Win95 FAT (1c)',
	'1e', 'Hidden Win95 FAT (1e)',
	'24', 'NEC DOS',
	'3c', 'PartitionMagic recovery',
	'40', 'Venix 80286',
	'41', 'PPC PReP boot',
	'42', 'SFS',
	'4d', 'QNX 4.x',
	'4e', 'QNX 4.x 2nd partition',
	'4f', 'QNX 4.x 3rd partition',
	'50', 'OnTrack DM',
	'51', 'OnTrack DM6 Aux1',
	'52', 'CP/M',
	'53', 'OnTrack DM6 Aux3',
	'54', 'OnTrack DM6',
	'55', 'EZ-Drive',
	'56', 'Golden Bow',
	'5c', 'Priam Edisk',
	'61', 'SpeedStor',
	'63', 'GNU HURD or SysV',
	'64', 'Novell Netware 286',
	'65', 'Novell Netware 386',
	'70', 'DiskSecure Multi-Boot',
	'75', 'PC/IX',
	'80', 'Old Minix',
	'81', 'Minix / Old Linux / Solaris',
	'82', 'Linux swap',
	'83', 'Linux',
	'84', 'OS/2 hidden C: drive',
	'85', 'Linux extended',
	'86', 'NTFS volume set (86)',
	'87', 'NTFS volume set (87)',
	'8e', 'Linux LVM',
	'93', 'Amoeba',
	'94', 'Amoeba BBT',
	'a0', 'IBM Thinkpad hibernation',
	'a5', 'BSD/386',
	'a6', 'OpenBSD',
	'a7', 'NeXTSTEP',
	'b7', 'BSDI filesystem',
	'b8', 'BSDI swap',
	'c1', 'DRDOS/sec FAT12',
	'c4', 'DRDOS/sec FAT16 <32M',
	'c6', 'DRDOS/sec FAT16',
	'c7', 'Syrinx',
	'db', 'CP/M / CTOS',
	'e1', 'DOS access',
	'e3', 'DOS read-only',
	'e4', 'SpeedStor',
	'eb', 'BeOS',
	'f1', 'SpeedStor',
	'f4', 'SpeedStor large partition',
	'f2', 'DOS secondary',
	'fd', 'Linux raid',
	'fe', 'LANstep',
	'ff', 'BBT',
) ;

#//////////////////////////////////////////////////////////////////////////////

# bool getPartParams(\%ini, $disk, \@params, \@lol)
# Fonction specifique aux parametres disque concernant les partitions.
# Args:
#	\%ini: Hache des infos retourne par iniLoad()
#	$disk: Nom de la section du disque recherche.
#	\@params: Liste des parametres demandes
#	\@lol: Tableau 2D (liste de listes) qui recevra les valeurs des
#	       parametres demandes (dans l'ordre), a raison d'une liste par
#	       partition.
#
# Retourne le nombre de partitions trouvees.
#
sub getPartParams {
my ($ini, $disk, $params, $lol) = @_ ;
my ($i, $p, $row) ;
my @curp ;

 @{$lol} = () ;

 for ($i=0; $i<10; $i++) {
 	$p = $$params[0] . $i ;
	@row = iniGetValues( $ini, $disk, $p ) ;

	if (length $row[0] >0) {
		@curp = map { $_.$i } @$params ;
		@row = iniGetValues($ini, $disk, @curp ) ;
		$row[1] = parttype("0x$row[1]");

		push @$lol, [ @row ] ;
	}
	else {
		last ;
	}
 }
	
return scalar(@$lol) ;
}

# MAIN ////////////////////////////////////////////////////////////////////////

my $lbs_home = $lbsconf{'basedir'} ;
my $infofile ;
my %ini ;
my ($table, $subtable) ;
my @toprow ;
my @subrow ;
my @row ;
my @lol ;
my @sublol ;
my $i ;

# Attributs d'une table:
my %tabattr = (
	'rotate'	=> 0 ,
	'tr_header'	=> $tb ,
	'tr_body'	=> $cb ,
) ;

# Attributs de la table 'Main':
my %mainattr = (
	'rotate'	=> 1 ,
	'tr_header'	=> $tb ,
	'tr_body'	=> $cb ,
) ;


# Attributs d'une sous-table:
my %subattr = (
	'rotate'	=> 0 ,
	'tr_header'	=> $tb ,
	'tr_body'	=> $cb ,
	'border'	=> '' ,
) ;


error(text("err_dnf",$lbs_home)) if (not -d $lbs_home) ;

ReadParse() ;

	if (not exists($in{'mac'})) {
		error($text{'err_invalcgi_nomac'}) ;
		die ;
	}

$infofile = $lbs_home . "/log/" . toMacFileName( $in{'mac'} ) . ".ini" ;

	if (not -f $infofile) {
		error(text("err_hwinfo_noini",$in{'mac'})) ;
	}

iniLoad($infofile, \%ini) ;


&header($text{'tit_hwinfo'}, "", "index", 1, 1, undef, $text{'author'});
&tabs(1);

	print "<h2 align=center>Client ", $in{'mac'}, "</h2>" ;

	# --- Sous-table 'Memory' a inclure dans la table 'Main':
	@toprow = qw( LowMem HighMem TotalMem) ;
	@row = iniGetValues(\%ini, "MAIN", @toprow) ;
	push @lol, [ @row ] ;
	$subtable = mkHtmlTable("", \@toprow, \@lol, \%subattr ) ;

	# --- MAIN
	@toprow = qw( Memory CpuVendor Model Freq ) ;
	@row = iniGetValues(\%ini, "MAIN", @toprow) ;
	$row[0] = $subtable ;	# Inclusion de la sous-table.
	@lol = () ;
	push @lol, [ @row ] ;

	print mkHtmlTable( $text{'tab_hwinfo_main'} , \@toprow, \@lol,
	                   \%mainattr) ;

	print "<p>\n" ;

	# --- PCI DEVICES
	@toprow = qw(Bus Func Vendor Device Class Type) ;
	@lol = () ;

	foreach $i (grep m/^PCI/i, iniGetSections(\%ini)) {
		@row = iniGetValues(\%ini, $i, @toprow) ;
		push @lol, [ @row ] ;
	}
	
	print mkHtmlTable( $text{'tab_hwinfo_pci'} , \@toprow, \@lol, \%tabattr) ;
	
	print "<p>\n" ;


	# --- DISKS
	#	
	@toprow = qw(Name Cyl Head Sector Capacity Partitions) ;
	@subrow = qw(PartNum PartType PartLength) ;
	@lol = () ;

	foreach $i (grep m/^DISK/gi, iniGetSections(\%ini)) {
		@sublol = ();
		@row = iniGetValues(\%ini, $i, @toprow) ;

		# --- Sous table Partitions:
		if ( getPartParams(\%ini, $i, \@subrow, \@sublol) ) {

			$subtable = mkHtmlTable("", \@subrow, \@sublol, \%subattr) ;
			pop @row ;
			push @row, $subtable ;
		}

		push @lol, [ @row ] ;
	}

	$table = mkHtmlTable( $text{'tab_hwinfo_disks'} , \@toprow,
	                      \@lol, \%tabattr) ;
	print $table ;


&footer("", $text{'index'}) ;

