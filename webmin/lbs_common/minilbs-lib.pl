#!/usr/bin/perl
#
# $Id$
#

# @list etherGetNames(\%einfo)
# Retourne la liste des noms des machines
# Se base sur la structure retournee par etherLoad().
#
sub etherGetNames
{
my $k ;
my @out ;

	foreach $k (etherGetMacs($_[0])) {
		push @out, etherGetNameByMac($_[0], $k) ;
	}

return sort(@out) ;
}


# @list etherGetMacs(\%einfo)
# Retourne la liste des adresses MAC des machines.
# Se base sur la structure retournee par etherLoad().
#
sub etherGetMacs
{
 return sort( keys %{$_[0]} ) ;
}

# $macaddr etherGetMacByName (\%einfo, $name)
# Retourne une adresse MAC a partir d'un nom d'hote.
# Se base sur la structure retournee par etherLoad().
#
sub etherGetMacByName
{
my $einfo = shift ;
my $name = shift ;
my ($k,$v, $l) ;

	# Ne pas differencier maj/min:
	$name = lc($name) ;
	
	foreach $k ( keys %{$einfo} ) {
		$v = ${$einfo}{$k} ;
		$l = lc( $$v[1] ) ;
		return $k if ($l eq $name) ;
	}

 # Echec:
 #lbsError("etherGetMacByName","HOST_UNK", $name) ;

 return ;
}

# $mac macFileName ($mac)
# Formatage d'une adresse MAC, pour servir de nom de fichier.
# Typiquement on supprime les ':', et on met le tout en majuscules.
#
sub toMacFileName
{
my $mac = shift ;
 $mac = uc($mac) ;
 $mac =~ s/:+//g ;
 return $mac ;
}

# $name etherGetIpByMac (\%einfo, $mac)
# Retourne d'adresse IP d'un hote à partir de son adresse MAC.
# Se base sur la structure retournee par etherLoad().
#
sub etherGetIpByMac
{
my $einfo = shift ;
my $mac = shift ;

 if ( exists($$einfo{$mac}) ) {
	return $$einfo{$mac}[0] ;
 }
 else {
 	#lbsError("etherGetIpByMac","MAC_BAD", $mac) ;
	return ;
 }
}

# $name etherGetNameByMac (\%einfo, $mac)
# Retourne un nom d'hote à partir de son adresse MAC.
# Se base sur la structure retournee par etherLoad().
#
sub etherGetNameByMac
{
my $einfo = shift ;
my $mac = shift ;

 if ( exists($$einfo{$mac}) ) {
	return $$einfo{$mac}[1] ;
 }
 else {
 	lbsError("etherGetNameByMac","MAC_BAD", $mac) ;
	return ;
 }
}


1;
