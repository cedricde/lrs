#!/usr/bin/perl

use Compress::Zlib;

open(FILE, "<$ARGV[0]");
$data = '';
while (<FILE>)
{
	$data .= $_
}
close(FILE);

$d = Compress::Zlib::inflateInit() or die $!;
($data, $status) = $d->inflate($data);

print $data;
