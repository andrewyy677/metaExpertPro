#!/usr/bin/perl
##
## pick lost pep back; probility (sum) max > count (sum) max; undistinguished under the 1st and 2nd principle; and merge s6_planC with s5_subset; back same into metapg; transform data to pep infor; generate new lib
## Update: 20211113
##         20220102 (rmone)
## Usage: perl s6_planC.pl 2> s6_planC.error
##
use strict;
#use Data::Dump qw (dump);

my ($s2dir, $workdir, $help, $analysis_type, $date, $fasta, $library);

use Getopt::Long;
GetOptions(	's2dir|s2d=s'	=>	\$s2dir,
			'workdir|wd=s'		=>	\$workdir,
			'fasta|f=s'	=>	\$fasta,
			'lib|l=s'		=>	\$library,
			'date|d=s'		=>	\$date,
			'analysis_type|a=s'	=>	\$analysis_type,
			'help|h!'		=>	\$help,);
if ($help==1) {
	open HELP, "<$0";
	while (<HELP>) {	print "$_" if (/^##/);	}
	close HELP;	exit(0);
}
print STDERR "step2.6 parameters: $s2dir\n$workdir\n$help\n";
open (LERR, ">$s2dir/output/s6_planC.error") or die $!;
##lost
open (LOST, "<$s2dir/output/subset-v10_lostpep2pro.txt") or die $!;
my $seed; my $seedcount = 0; my %hash;
while (<LOST>) {
	chomp; s/\r//g;
	my @lost = split /\t/;
	if (@lost == 1) {
		$seed = $_;
		$seedcount ++;
	}else{
		$hash{$seed}{$_} ++;
	}
}
close LOST;
print STDERR "$seedcount\n";
#dump %hash;
## planC
my $undiscount1 = 0; my $undiscount2 = 0;
my %leavepro_final;
for my $k1 (sort keys %hash) {
	my $maxprob = 0; my $maxspecount = 0; 
	my $leavepro; my %progroup; my @leavepro_arr;
	
	print LERR "$k1\n";
	for my $k2 (sort keys %{$hash{$k1}}) {
		my ($pepcom, $samepronum, $pepcombprob, $pepcombcount, $sumprob, $sumspecount, $multiprob) = split /\t/, $k2;
		$progroup{$sumprob}{$sumspecount}{$k2} ++;
	}
	for my $k2 (sort keys %{$hash{$k1}}) {
		my ($pepcom, $samepronum, $pepcombprob, $pepcombcount, $sumprob, $sumspecount, $multiprob) = split /\t/, $k2;
		if ($sumprob > $maxprob) {
			$maxprob = $sumprob;
			$maxspecount = $sumspecount;
			$leavepro = $k2;
		}elsif ($sumprob == $maxprob) {
			print LERR "**\n";
			$undiscount1 ++;
			if ($sumspecount > $maxspecount) {
				$maxspecount = $sumspecount;
				$leavepro = $k2;
			}
		}
	}
	my $k3i = 0;
	for my $k3 (sort keys %{$progroup{$maxprob}{$maxspecount}}) {
		$k3i ++;
		if ($k3i > 1) {
			$undiscount2 ++;
			print LERR "**\n";
		}
		my $leavepro_f = (split /\t/, $k3)[0];
		$leavepro_final{$leavepro_f} ++;
		print LERR "$k3\n";
	}
}
print STDERR "undiscount1\tundiscount2\n$undiscount1\t$undiscount2\n";
open (OUT, ">$s2dir/output/subset-v10_rm5B_lostpep_s6_planCback.out") or die $!;
for my $leavepro_finalk (sort keys %leavepro_final) {
	print OUT "$leavepro_finalk\n";
}
close OUT;
## leave
open (S5, "<$s2dir/output/subset-v10-leave.out") or die $!;
while (<S5>) {
	chomp; s/\r//g;
	$leavepro_final{$_} ++;
}
## index2pepcom
open (MAT, "<$s2dir/output/trim/subset.trim.list") or die $!;
my %mathash;
while (<MAT>) {
	chomp; s/\r//g;
	my ($matpep, $matindex) = split /\t/;
	$mathash{$matindex} = $matpep;
}
close MAT;
## merge
open (MER, ">$s2dir/output/subset-v10-leave_planCback_merge.out") or die $!;
my %mergepep; my %index2pro;
for my $leavepro_finalk (sort keys %leavepro_final) {
	print MER "$leavepro_finalk\n";
	my @index2pro;
	my @pepcomb = split /\;/, $leavepro_finalk;
	for my $pepcomb (@pepcomb) {
		$mergepep{$pepcomb} ++;
		push @index2pro, $mathash{$pepcomb};
	}
	my $index2proj = join "\;", @index2pro;
	$index2pro{$index2proj} ++;
}
close MER;
my $mergepepcount = keys %mergepep;
print STDERR "mergepep_check\t$mergepepcount\n";
system ("wc -l $s2dir/output/subset-v10-leave_planCback_merge.out");


## same back
open (ORI, "<$s2dir/output/pep2fasta_2pro_sort.txt") or die $!;
my %leave_pepcom2pro; my %leave_pro2pepcom;
while (<ORI>) {
	chomp; s/\r//g;
	my @oridata = split /\,/;
	my $oripepcom = $oridata[-1];
	my $oripro;
	if (@oridata > 2) {
		$oripro = join "\,", @oridata[0..$#oridata-1];
	}else{
		$oripro = $oridata[0];
	}
	if (exists $index2pro{$oripepcom}) {
		$leave_pro2pepcom{$oripro}{$oripepcom} ++;
		$leave_pepcom2pro{$oripepcom}{$oripro} ++;
	}
}
close ORI;
open (CHECK1, ">check_singlehit.txt") or die $!;
for my $k1 (sort keys %leave_pro2pepcom) {
	my $count = keys %{$leave_pro2pepcom{$k1}};
	if ($count == 1) {
		print CHECK1 "$k1\n";
	}
}

## pepcom2pro and generate metagroup
open (CHEK, ">$s2dir/output/check_metagroup.txt") or die $!;
my $metai = 0; my %metagroup; my %pepcom2pro_addmeta;
for my $pepcom2prok1 (sort keys %leave_pepcom2pro) {
	my @pepcom2prok1 = sort keys %{$leave_pepcom2pro{$pepcom2prok1}};
	my $pepcom2prok1j = join "\;", @pepcom2prok1;
	print CHEK "$pepcom2prok1j\,$pepcom2prok1\n";
	if (@pepcom2prok1 > 1) {
		$metai ++;
		$metagroup{"Metagroup".$metai} = $pepcom2prok1j;
		$pepcom2pro_addmeta{$pepcom2prok1} = "Metagroup".$metai;
	}else{
		$pepcom2pro_addmeta{$pepcom2prok1} = $pepcom2prok1j;
	}
}
close CHEK;
## print metagroup
open (META, ">$s2dir/output/Metagroup.txt") or die $!;
for my $metagroupk1 (sort keys %metagroup) {
	print META "$metagroupk1\,$metagroup{$metagroupk1}\n";
}
close META;

## generate pro2pep_rmone and pep2pro_rmone hash (addmeta)
my %leave_pep2pro; my %rmonepep; 
for my $pepcom2pro_addmetak (sort keys %pepcom2pro_addmeta) {
	#print PRO2PEP "$pepcom2pro_addmeta{$pepcom2pro_addmetak}\,$pepcom2pro_addmetak\n";
	my @pepcom2pro_addmetaksp = split /\;/, $pepcom2pro_addmetak;
	for my $pepcom2pro_addmetaksp (@pepcom2pro_addmetaksp) {
		$leave_pep2pro{$pepcom2pro_addmetaksp}{$pepcom2pro_addmeta{$pepcom2pro_addmetak}} ++;
	}
}
## pep2procom hash (addmeta)
my %procheck; my %pep2procom;
for my $leave_pep2prok1 (sort keys %leave_pep2pro) {
	my @pep2pro = sort keys %{$leave_pep2pro{$leave_pep2prok1}};
	for my $pep2pro (@pep2pro) {
		$procheck{$pep2pro} ++;
	}
	my $pep2proj = join "\;", @pep2pro;
	$pep2procom{$leave_pep2prok1} = $pep2proj;
	#print PEP2PRO "$leave_pep2prok1\,$pep2proj\n";
}
my $procheck = keys %procheck;
print STDERR "pep2pro-procheck\t$procheck\n";



## generate lib


#open (TSVOUT, ">uhgp_90_ddafile_20211027_NEW_20211119.tsv") or die $!;
open (TSVOUT, ">$s2dir/output/$analysis_type\_irt_contam_ddafile_NEW_rmone_spectral_library_$date\.tsv") or die $!;
open (TSVOUT1, ">$s2dir/output/$analysis_type\_irt_contam_ddafile_NEW_rmone_$date\_peplost.tsv") or die $!;
open (TSV, "<$library") or die $!;
my %tprohash; my %tpephash; my %thash; my %thead_hash; my %tsvpro; my %tsvpro_rmone;
my %tpep2procom;
while (<TSV>) {
	chomp; s/\r//g;
	if (/^Precursor/) {
		my @thead = split /\t/;
		for my $theadi (0..$#thead) {
			if ($thead[$theadi] eq "ProteinId") {
				$thead_hash{"ProteinId"} = $theadi;
			}
			if ($thead[$theadi] eq "PeptideSequence") {
				$thead_hash{"PeptideSequence"} = $theadi;
			}
		}
		print TSVOUT "$_\n";
	}else{
		my @tdata = split /\t/;
		my $tname = $tdata[$thead_hash{"ProteinId"}];
		my $tpep = $tdata[$thead_hash{"PeptideSequence"}];
		my $tpepori = $tpep;
		$tprohash{$tname} ++;
		$tpep =~ s/I/B/gi;
		$tpep =~ s/L/B/gi;
		if (exists $pep2procom{$tpep}) {
			$tpep2procom{$tpepori} = $pep2procom{$tpep};
			my $tsvp = join "\t", @tdata[0..($thead_hash{"ProteinId"}-1)], $pep2procom{$tpep}, @tdata[($thead_hash{"ProteinId"}+1)..$#tdata];
			$tsvpro{$pep2procom{$tpep}} ++;
			print TSVOUT "$tsvp\n";
		}else{
			print TSVOUT1 "$_\n";
		}
	}
}
close TSV;
close TSVOUT;
close TSVOUT1;
## check
open (TSVIN, "<$s2dir/output/$analysis_type\_irt_contam_ddafile_NEW_rmone_spectral_library_$date\.tsv") or die $!;
my %check_tpro; my %check_tpro_1;
while (<TSVIN>) {
	chomp; s/\r//g;
	if (/^Precursor/) {
		next;
	}else{
		my $tpro = (split /\t/)[$thead_hash{"ProteinId"}];
		my @tprosp = split /\;/, $tpro;
		for my $tprosp (@tprosp) {
			$check_tpro{$tprosp} ++;
		}
	}
}
my $check_tprocount = keys %check_tpro;
print STDERR "check_tpro\t$check_tprocount\n";

## print pro2pep and pep2pro matrix
open (PRO2PEP, ">$s2dir/output/subset-v10-leave-pro2pep_rmone.txt") or die $!;
open (PEP2PRO, ">$s2dir/output/subset-v10-leave-pep2pro_rmone.txt") or die $!;
my %tpro2pep;
for my $k (sort keys %tpep2procom) {
	print PEP2PRO "$k\,$tpep2procom{$k}\n";
	my @procom = split /\;/, $tpep2procom{$k};
	for my $procom (@procom) {
		$tpro2pep{$procom}{$k} ++;
	}
}
for my $k1 (sort keys %tpro2pep) {
	my @pepcom = sort keys %{$tpro2pep{$k1}};
	my $pepcomj = join "\;", @pepcom;
	print PRO2PEP "$k1\,$pepcomj\n";
}

## generate fasta

my %fseqhash; my $fseqname;
open (FAS, "<$fasta") or die $!;
while (<FAS>) {
	chomp; s/\r//g;
	if (/>(.*)/) {
		$fseqname = $1;
		$fseqname = (split /\s+/, $fseqname)[0];
	}else{
		$fseqhash{$fseqname} .= $_;
	}
}
close FAS;
system ("wc -l $s2dir/output/subset-v10-leave-pep2pro_rmone.txt");

my %tsvprohash; my %tsvpro_rmonehash;
#open (TFAS, ">uhgp_90_ddafile_20211027_NEW_20211119.fasta") or die $!;
open (TFAS, ">$s2dir/output/$analysis_type\_irt_contam_ddafile_NEW_rmone_$date\.fasta") or die $!;
for my $tsvprok (sort keys %tsvpro) {
	my @tsvproksp = split /\;/, $tsvprok;
	for my $tsvproksp (@tsvproksp) {
		if ($tsvproksp =~ /Metagroup/) {
			$tsvproksp = $metagroup{$tsvproksp};
			my @metaprosp = split /\;/, $tsvproksp;
			for my $metaprosp (@metaprosp) {
				$tsvprohash{$metaprosp} = $fseqhash{$metaprosp};
			}
		}else{
			$tsvprohash{$tsvproksp} = $fseqhash{$tsvproksp};
		}
	}
	
}

for my $tfask (sort keys %tsvprohash) {
	print TFAS ">$tfask\n$tsvprohash{$tfask}\n";
}
#system ("grep \">\" uhgp_90_ddafile_20211027_NEW_20211119.fasta | wc -l");
system ("grep \">\" $s2dir/output/$analysis_type\_irt_contam_ddafile_NEW_rmone_$date\.fasta | wc -l");
close TFAS;