#!/usr/bin/perl
##
## find and rm 5B & find lost pep and mark
## Author: Yingying Sun @Guomics
## Update: 20211113
## Usage: perl s5_subset-v10_rm5B_lostpep_mark.pl 2> s5_subset-v10_rm5B_lostpep_mark.error
##
use strict;

my ($s2dir, $workdir, $help);

use Getopt::Long;
GetOptions(	's2dir|s2d=s'	=>	\$s2dir,
			'workdir|wd=s'		=>	\$workdir,
			'help|h!'		=>	\$help,);
if ($help==1) {
	open HELP, "<$0";
	while (<HELP>) {	print "$_" if (/^##/);	}
	close HELP;	exit(0);
}
print STDERR "step2.5 parameters: $s2dir\n$workdir\n$help\n";

open (SUB, "<$s2dir/output/subset-v10_rm1.out") or die $!;
my @subdata; my %prohash; my %pephash; my %pep2prohash;
while (<SUB>) {
	chomp; s/\r//g;
	push @subdata, $_;
	$prohash{$_} ++;
	my @data = split /\;/;
	for my $data (@data) {
		$pephash{$data} ++;
		$pep2prohash{$data}{$_} ++;
	}
}
close SUB;
#my $pepcount = keys %pephash;
#print $pepcount;

my %deleted; my %leave;
open (LEAVE, ">$s2dir/output/subset-v10-leave.out") or die $!;
open (RM, ">$s2dir/output/subset-v10-rm.out") or die $!;

for my $subdata (@subdata) {
	my @data1 = split /\;/, $subdata;
	my $bool;
	for my $data1 (@data1) {
		$bool = "n";
		if ($pephash{$data1} == 1) {
			last;
		}else{
			$bool = "y";
		}
	}
	if ($bool eq "n") {
		$leave{$subdata} ++;
	}else{
		$deleted{$subdata} ++;
	}
}
my %leavepep; my %deletedpep;
for my $leavek (sort keys %leave) {
	print LEAVE "$leavek\n";
	if ($leavek =~ /\;/) {
		my @leaveksp = split /\;/, $leavek;
		for my $leaveksp (@leaveksp) {
			$leavepep{$leaveksp} ++;
		}
	}else{
		$leavepep{$leavek} ++;
	}
}
my $leavepepcount = keys %leavepep;
for my $deletedk (sort keys %deleted) {
	print RM "$deletedk\n";
	if ($deletedk =~ /\;/) {
		my @deletedsp = split /\;/, $deletedk;
		for my $deletedsp (@deletedsp) {
			$deletedpep{$deletedsp} ++;
		}
	}else{
		$deletedpep{$deletedk} ++;
	}
}
close LEAVE;
close RM;

my $deletedpepcount = keys %deletedpep;
system("wc -l $s2dir/output/subset-v10-rm.out");
print STDERR "rm_pep\t$deletedpepcount\n";
system("wc -l $s2dir/output/subset-v10-leave.out");
print STDERR "leave_pep\t$leavepepcount\n";

my %lostpep;
for my $pephashk (sort keys %pephash) {
	if (! (exists $leavepep{$pephashk})) {
		$lostpep{$pephashk} ++;
	}
}
my $lostpepcount = keys %lostpep;

print STDERR "lostpep\t$lostpepcount\n";

my %lostpep2pro;

for my $lostpepk (sort keys %lostpep) {
	for my $pep2prohashk2 (sort keys %{$pep2prohash{$lostpepk}}) {
		$lostpep2pro{$lostpepk}{$pep2prohashk2} ++;
	}
}

open (MAT, "<$s2dir/output/trim/subset.trim.list") or die $!;
my %mathash;
while (<MAT>) {
	chomp; s/\r//g;
	my ($matpep, $matindex) = split /\t/;
	$mathash{$matpep} = $matindex;
}
close MAT;

my %probhash; my %spechash;
open (PEP, "<$workdir/s1_fasta2pep/input/peptide.tsv") or die $!;
my @pephead; my %pepindex;
while (<PEP>) {
	chomp; s/\r//g;
	if (/^Peptide/) {
		@pephead = split /\t/;
		for my $pepheadi (0..$#pephead) {
			if ($pephead[$pepheadi] eq "Peptide") {
				$pepindex{"pep"} = $pepheadi;
			}
			if ($pephead[$pepheadi] eq "Probability") {
				$pepindex{"prob"} = $pepheadi;
			}
			if ($pephead[$pepheadi] eq "Spectral Count") {
				$pepindex{"specount"} = $pepheadi;
			}
		}
	}else{
		my ($pep, $prob, $specount) = (split /\t/)[$pepindex{"pep"}, $pepindex{"prob"}, $pepindex{"specount"}];
		$pep =~ s/I/B/ig;
		$pep =~ s/L/B/ig;
		$probhash{$mathash{$pep}} = $prob;
		$spechash{$mathash{$pep}} = $specount;
	}
}

open (LOST, ">$s2dir/output/subset-v10_lostpep2pro.txt") or die $!;
for my $k3 (sort keys %lostpep2pro) {
	print LOST "$k3\n";
	for my $k4 (sort keys %{$lostpep2pro{$k3}}) {
		my @pepcomb = split /\;/, $k4;
		my @prob; my @specount;
		my $sumprob = 0; my $multiprob = 1; my $sumspecount = 0;
		for my $pepcomb (@pepcomb) {
			push @prob, $probhash{$pepcomb};
			push @specount, $spechash{$pepcomb};
			$sumprob += $probhash{$pepcomb};
			$multiprob *= $probhash{$pepcomb};
			$sumspecount += $spechash{$pepcomb};
		}
		my $probp = join "\;", @prob;
		my $specountp = join "\;", @specount;
		print LOST "$k4\t1\t$probp\t$specountp\t$sumprob\t$sumspecount\t$multiprob\n";
	}
}
close LOST;
