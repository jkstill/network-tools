#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;

my $filename = './mac-prefix-hash.pl';

# Check if the file exists
unless (-e $filename) {
	die "File '$filename' does not exist.\n";
}

my $prefixHash = do "$filename" or die "Could not parse file '$filename': $@\n";

#print Dumper($prefixHash);

my $vendorToCheck = $ARGV[0];
die "Usage: $0 <Vendor Name>\n" unless defined $vendorToCheck;

my %vendorPrefixes;

foreach my $prefix (keys %$prefixHash) {
	my ($prefix, $vendor) = ($prefix, $prefixHash->{$prefix});
	push @{ $vendorPrefixes{$vendor} }, $prefix if $vendor eq $vendorToCheck;
}

if (exists $vendorPrefixes{$vendorToCheck}) {
	print "MAC address prefixes for vendor '$vendorToCheck':\n";
	foreach my $prefix (@{ $vendorPrefixes{$vendorToCheck} }) {
		print "$prefix\n";
	}
} else {
	print "No prefixes found for vendor '$vendorToCheck'.\n";
}





