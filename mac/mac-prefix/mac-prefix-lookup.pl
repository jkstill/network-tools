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

my $prefixToCheck = $ARGV[0];
die "Usage: $0 <MAC Prefix>\n" unless defined $prefixToCheck;

if (exists $prefixHash->{$ARGV[0]}) {
	 print "$prefixToCheck $prefixHash->{$prefixToCheck}\n";
} else {
	 print "Prefix $prefixToCheck found.\n";
}


