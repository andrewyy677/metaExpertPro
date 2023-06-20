#!/usr/bin/perl

##
## Name:	strB_ori_fasta_pep_tsv.pl
## Date:	20220108
## All Rights Reserved.
## Usage:
## EXAMPLE:	perl strB_ori_fasta_pep_tsv.pl -f GNHS_protein_add_other.fasta -l library.tsv 2> rm_otherfas.error
##
use strict;

my ($fasta, $library, $help, $date, $analysis_type, $outdir);

use Getopt::Long;
GetOptions(	'fasta|f=s'	=>	\$fasta,
			'lib|l=s'		=>	\$library,
			'date|d=s'		=>	\$date,
			'analysis_type|a=s'		=>	\$analysis_type,
			'out|o=s'		=>	\$outdir,
			'help|h!'		=>	\$help,);
if ($help==1) {
	open HELP, "<$0";
	while (<HELP>) {	print "$_" if (/^##/);	}
	close HELP;	exit(0);
}
print STDERR "step1 parameters: $fasta\n$library\n$date\n$analysis_type\n$outdir\n";
my %fseqhash_ori; my %fseqhash_strB;
my $fseqname;
open (FAS, "<$fasta") or die $!;
while (<FAS>) {
	chomp; s/\r//g;
	if (/^>(.*)/) {
		$fseqname = $1;
	}else{
		$fseqhash_ori{$fseqname} .= $_;
		s/I/B/gi;
		s/L/B/gi;
		$fseqhash_strB{$fseqname} .= $_;
	}
}
close FAS;

open (TSV1, "<$library") or die $!;
open (TSVOUT, ">$outdir/$analysis_type\_irt_contam_ddafile_$date\_strB.tsv") or die $!;
open (FASOUT1, ">$outdir/$analysis_type\_irt_contam_ddafile_$date\.fasta") or die $!;
open (FASOUT2, ">$outdir/$analysis_type\_irt_contam_ddafile_$date\_strB.fasta") or die $!;
open (PEP1, ">$outdir/$analysis_type\_irt_contam_ddafile_$date\_pep.seq") or die $!;
open (PEP2, ">$outdir/$analysis_type\_irt_contam_ddafile_$date\_pep_strB.seq") or die $!;
my %tprohash; 
my %tpep_ori; my %tpep_strB;
while (<TSV1>) {
	chomp; s/\r//g;
	if (/^Precursor/) {
		print TSVOUT "$_\n";
	}else{
		my @tdata = split /\t/;
		my $tname = $tdata[3];
		my $tpep = $tdata[5];
		$tprohash{$tname} ++;
		$tpep_ori{$tpep} ++;
		$tpep =~ s/I/B/gi;
		$tpep =~ s/L/B/gi;
		$tpep_strB{$tpep} ++;
		my $tsvp = join "\t", @tdata[0..4], $tpep, @tdata[6..$#tdata];
		print TSVOUT "$tsvp\n";
	}
}

my $procount = keys %tprohash;
my $pepcount_ori = keys %tpep_ori;
my $pepcount_strB = keys %tpep_strB;
for my $k1 (sort keys %fseqhash_ori) {
	print FASOUT1 ">$k1\n$fseqhash_ori{$k1}\n";
	print FASOUT2 ">$k1\n$fseqhash_strB{$k1}\n";
}
print STDERR "PG_tsv\t$procount\nPEPori\t$pepcount_ori\nPEPstrB\t$pepcount_strB\n";
for my $k1 (sort keys %tpep_ori) {
	print PEP1 "$k1\n";
}

for my $k2 (sort keys %tpep_strB) {
	print PEP2 "$k2\n";
}
close TSV;
close TSVOUT;
close FASOUT1;
close FASOUT2;
close PEP1;
close PEP2;