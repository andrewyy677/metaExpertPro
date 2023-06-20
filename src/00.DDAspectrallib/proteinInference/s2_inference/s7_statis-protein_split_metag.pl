#!/usr/bin/perl
use strict;
my ($s2dir, $workdir, $help);

use Getopt::Long;
GetOptions(	's2dir|s2d=s'	=>	\$s2dir,
			'help|h!'		=>	\$help,);
if ($help==1) {
	open HELP, "<$0";
	while (<HELP>) {	print "$_" if (/^##/);	}
	close HELP;	exit(0);
}
print STDERR "step2.7 parameters: $s2dir\n$workdir\n$help\n";

my %metahash;
open (META, "<$s2dir/output/Metagroup.txt") or die $!;
while (<META>) {
	chomp; s/\r//g;
	my $metapro1;
	my @meta = split /\,/;
	if (@meta > 2) {
		$metapro1 = join "\,", @meta[1..$#meta];
	}else{
		$metapro1 = $meta[1];
	}
	my $metaname = $meta[0];
	my @metasp = split /\;/, $metapro1;
	for my $metasp (@metasp) {
		$metahash{$metaname}{$metasp} ++;
	}
}

my %pephash; my %prohash;
my $pg = 0;
my $multihits = 0;
my $singlehits = 0;
my $metapro = 0;
my $uniquepro = 0;
open (PRO, "<$s2dir/output/subset-v10-leave-pro2pep_rmone.txt") or die $!;
while (<PRO>) {
	chomp; s/\r//g;
	$pg ++;
	my @data = split /\,/; my $pro;
	if (@data > 2) {
		$pro = join "\,", $data[0..$#data-1];
	}else{
		$pro = $data[0];
	}
	
	my $pepcom = $data[-1];
	if ($pepcom =~ /\;/) {
		my @pep = split /\;/, $pepcom;
		for my $pep (@pep) {
			$pephash{$pep} ++;
		}
	}else{
		$pephash{$pepcom} ++;
	}
	if ($pro =~ /Metagroup/) {
		my @metaprocom = keys %{$metahash{$pro}};
		for my $metaprocom (@metaprocom) {
			$prohash{$metaprocom} ++;
		}
		if ($pepcom =~ /\;/) {
			$multihits += @metaprocom;
		}else{
			$singlehits += @metaprocom;
		}
		$metapro ++;
	}else{
		$prohash{$pro} ++;
		$uniquepro ++;
		if ($pepcom =~ /\;/) {
			$multihits ++;
		}else{
			$singlehits ++;
		}
	}
}
my $count = keys %prohash;
print "protein_name\t$count\nmulti_hits\t$multihits\nsingle_hits\t$singlehits\nprotein_groups\t$pg\nunique_pro\t$uniquepro\nmetaprotein\t$metapro\n";
my $pepcount = keys %pephash;
my $uniquepep = 0;
for my $pepk (keys %pephash) {
	if ($pephash{$pepk} eq "1") {
		$uniquepep ++;
	}
}
print "pep_total\t$pepcount\nunique_pep\t$uniquepep\n";

close;