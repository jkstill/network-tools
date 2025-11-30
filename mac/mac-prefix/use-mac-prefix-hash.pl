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

print "FC:F6:47 $prefixHash->{'FC:F6:47'}\n";

