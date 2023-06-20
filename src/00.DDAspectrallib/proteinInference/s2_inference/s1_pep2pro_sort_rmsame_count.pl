#!/usr/bin/perl
##
## pep2fasta->pro2pep & sort pro & generate pro pepcount & error for check protein num
## Update: 20211112
## Usage: perl s1_pep2pro_sort_rmsame_count.pl 2> s1_pep2pro_sort_rmsame_count.error
##

use strict;
my ($s2, $help);

use Getopt::Long;
GetOptions(	's2dir|s2=s'		=>	\$s2,
			'help|h!'		=>	\$help,);
if ($help==1) {
	open HELP, "<$0";
	while (<HELP>) {	print "$_" if (/^##/);	}
	close HELP;	exit(0);
}
print STDERR "parameters for step2.1: $s2\n";
my %hash;
my %prohash;
open (PEP2F, "<$s2/input/pep2fasta.txt") or die $!;
while (<PEP2F>) {
	chomp; s/\r//g;
	my @p2f = split /\,/;
	my $p2fpro;
	if (@p2f > 2) {
		$p2fpro = join "\,", @p2f[1..$#p2f];
	}else{
		$p2fpro = $p2f[1];
	}
	my $p2fpep = $p2f[0];
	if ($p2fpro =~ /\;/) {
		my @pro = split /\;/, $p2fpro;
		for my $pro (@pro) {
			$prohash{$pro} ++;
			if (! (exists $hash{$pro})) {
				$hash{$pro} = $p2fpep;
			}else{
				$hash{$pro} .= "\;$p2fpep";
			}
		}
	}else{
		$prohash{$p2fpro} ++;
		if (! (exists $hash{$p2fpro})) {
			$hash{$p2fpro} = $p2fpep;
		}else{
			$hash{$p2fpro} .= "\;$p2fpep";
		}
	}
}
close PEP2F;
open (PRO2PEP, ">$s2/output/pep2fasta_2pro_sort.txt") or die $!;
open (PEPCOUNT, ">$s2/output/pep2fasta_2pro_sort_rmsame_count.txt") or die $!;
my %pephash;
for my $k (sort keys %hash) {
	if ($hash{$k} =~ /\;/) {
		my @arr = split /\;/, $hash{$k};
		my $count = @arr;
		my @arrs = sort @arr;
		my $arrs = join "\;", @arrs;
		print PRO2PEP "$k\,$arrs\n";
		$pephash{$arrs} = $count;
	}else{
		my $count = 1;
		print PRO2PEP "$k\,$hash{$k}\n";
		$pephash{$hash{$k}} = $count;
	}
}
for my $k2 (sort keys %pephash) {
	print PEPCOUNT "$pephash{$k2}\t$k2\n";
}
close PRO2PEP;
close PEPCOUNT;
my $i = keys %prohash;
print STDERR "pg_count in pep2fasta.txt\t$i\n";