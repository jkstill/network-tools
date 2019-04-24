#!/usr/bin/env perl

# based on this article
# http://bradhedlund.com/2008/12/19/how-to-calculate-tcp-throughput-for-long-distance-links/

use Try::Tiny;
use warnings;
use strict;
use Getopt::Long;
use Devel::Confess;

use constant EFFICIENCY => 0.90;
use constant KB => 2**10;
use constant MB => 2**20;
use constant GB => 2**30;
use constant TB => 2**40;

my $dataSize = 1 * TB;
my $dataSizeMB;
my $dataSizeGB;
my $dataSizeTB;

# measure in Megabits per second
my $netSpeed = 1 * GB;
my $latency = 0.040; # 40 milliseconds
# maximum TCP Window size with TCP Window Scaling is about 1G
my $maxTCPWindowBytes = 1 * GB;

my $help=0;

GetOptions (
	"latency=f" => \$latency,
	"netspeed=i" => \$netSpeed,
	"max-tcp-window=i" => \$maxTCPWindowBytes,
	"datasize-mb=i" => \$dataSizeMB,
	"datasize-gb=i" => \$dataSizeGB,
	"datasize-tb=i" => \$dataSizeTB,
	"h|help!" => \$help,
);

usage() if $help;

if ( defined($dataSizeMB)) {
	$dataSize = $dataSizeMB * MB;
}

if ( defined($dataSizeGB)) {
	$dataSize = $dataSizeGB * GB;
}

if ( defined($dataSizeTB)) {
	$dataSize = $dataSizeTB * TB;
}

  print "\n        Net Speed: $netSpeed\n";
    print "          Latency:  $latency\n";
   printf "          Latency: %4d milliseconds\n", $latency * 1000;
   printf "         DataSize:  " . commify($dataSize) . "\n";
   printf "  TCP Window Size:  " . commify($maxTCPWindowBytes) . "\n";
	printf "       Efficiency:  %d%%\n" , EFFICIENCY * 100;

# in megabytes per second
my %transferSeconds=();

# bytes
my $tcpWindowBytes = getTCPWindowSize();
my $tcpWindowBits = $tcpWindowBytes * 8;

print "\nTCP Window Size\n";
printf "    Bits: %10s\n", commify($tcpWindowBits);
printf "   Bytes: %10s\n", commify($tcpWindowBytes);


my $bitsPerSecond = ($tcpWindowBits / $latency) * EFFICIENCY;
my $bytesPerSecond = ($tcpWindowBytes / $latency) * EFFICIENCY;

print "\nMax possible throughput per second \n(latency limited - this is regardles of line speed)\n";
printf "   Bits: %10s\n", commify(sprintf('%d',$bitsPerSecond));
printf "  Bytes: %10s\n", commify(sprintf('%d',$bytesPerSecond));

$transferSeconds{current} = $dataSize / $bytesPerSecond;

#printf "\nTime required to transfer " . commify($dataSize) . " bytes of data: " . commify(sprintf('%d',$transferSeconds{current})) . " seconds\n";

# Bandwidth-in-bits-per-second * Round-trip-latency-in-seconds = TCP window size in bits / 8 = TCP window size in bytes
my $optimalTCPWindowBits = ($netSpeed * $latency );
my $optimalTCPWindowBytes =  $optimalTCPWindowBits / 8;

if ($optimalTCPWindowBytes > $maxTCPWindowBytes) {
	print "\n!! Optimal TCP Window Size of " . commify(sprintf('%d',$optimalTCPWindowBytes)) . " exceeds Max TCP Window of " . commify(sprintf('%d',$maxTCPWindowBytes)) . "\n";
	print "!! Resetting Optimal size to max allowed\n";
	$optimalTCPWindowBytes = $maxTCPWindowBytes;
	$optimalTCPWindowBits = $maxTCPWindowBytes * 8;
}

#print "optimalTCPWindowSize: $optimalTCPWindowSize\n";

print "\n===== Calculate with 'Optimal' TCP Window Size ====\n";
printf "\nOptimal TCP Window Size\n";
printf "    Bits: %10s\n", commify(sprintf('%d',$optimalTCPWindowBits));
printf "   Bytes: %10s\n", commify(sprintf('%d',$optimalTCPWindowBytes));

$bitsPerSecond = ($optimalTCPWindowBits / $latency) * EFFICIENCY;
$bytesPerSecond = ($optimalTCPWindowBytes / $latency) * EFFICIENCY;

print "\nMax possible throughput per second with optimal TCP Window Size\n";
printf "   Bits: %10s\n", commify(sprintf('%d',$bitsPerSecond));
printf "  Bytes: %10s\n", commify(sprintf('%d',$bytesPerSecond));

$transferSeconds{optimal} = $dataSize / $bytesPerSecond;
#printf "\nTime required to transfer " . commify($dataSize) . " bytes of data: " . commify(sprintf('%d',$transferSeconds{optimal})) . " seconds\n";


# there are diminishing returns on using the 'optimal' window sized based on input variables.
# recommend whichever is faster

print "\n===== Recommended TCP Window Size ====\n\n";

print "Seconds to transfer  " . commify($dataSize) .  " bytes of data for current/optimal TCP Window Sizes\n\n";

foreach my $key ( sort keys %transferSeconds ) {
	print "$key: " .  commify(sprintf('%6.1f',$transferSeconds{$key})). "\n";
}

print "\n";

if ($transferSeconds{optimal} < $transferSeconds{current}) {
	print "Recommendation: Set TCP Window size to " . sprintf('%d',$optimalTCPWindowBytes) . "\n";
} else {
	print "Recommendation: Do not change TCP Window size\n";
}


print "\n\n";

sub getTCPWindowSize {
	my $tcpWindowSize;
	try {
		open my $fh, '<', '/proc/sys/net/core/wmem_default';
		$tcpWindowSize = <$fh>;
		chomp $tcpWindowSize;
		close $fh;
	} catch {
		$tcpWindowSize = 256 * KB;
	};

	return $tcpWindowSize;
}

sub commify {
	local $_  = shift;
	1 while s/^(-?\d+)(\d{3})/$1,$2/;
	return $_;
}


sub usage {

	my $exitVal = shift;
	use File::Basename;
	my $basename = basename($0);
	print qq{
$basename

usage: $basename - <SCRIPT DESCRIPTION>

   $basename 

--latency         latency in seconds - 0.040
--netspeed        line speed in bits per seconds
--max-tcp-window  max TCP window size in bytes
--datasize-mb     size of data to transfer in megabytes
--datasize-gb     size of data to transfer in megabytes
--datasize-tb     size of data to transfer in megabytes
--h|help          help

};

	exit eval { defined($exitVal) ? $exitVal : 0 };
}

