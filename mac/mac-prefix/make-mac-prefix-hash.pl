#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;
use Text::CSV;

use Data::Dumper;
$Data::Dumper::Terse = 1; # do not output variable names
$Data::Dumper::Indent = 1; # Looks better, just a preference
$Data::Dumper::Sortkeys = 1; # To keep changes minimal in source control

my $DEBUG = 0;

my $input_file = shift @ARGV or die "Usage: $0 <input_file>\n";
open my $fh, '<:encoding(utf8)', $input_file or die "Could not open file '$input_file': $!\n";
my %prefixHash;

my $csv = Text::CSV->new({ binary => 1, auto_diag => 1 }); # auto_diag for error reporting

while (my $row = $csv->getline($fh)) {
	my ($dummy,$prefix, $value) = @$row;
	$prefix = formatPrefix($prefix);
	if ($DEBUG) {
		print "---------------------\n";
		print "prefix: $prefix\n";
		print "value: $value\n";
	}
	$prefixHash{$prefix} = $value;
}


#print Data::Dumper->Dump([\%prefixHash], ['prefixHash']);

my $hashFile = 'mac-prefix-hash.pl';

open my $hashHandle, '>', $hashFile or die "Cannot open $hashFile $!";
print $hashHandle Data::Dumper->Dump([\%prefixHash], ['prefixHash']);
close $hashHandle;

print "Hash dumped to $hashFile\n";

sub formatPrefix {
	 my ($prefix) = @_;
	 1 while $prefix =~ s/^(-?\w+)(\w{2})/$1:$2/;
	 return $prefix;
}


