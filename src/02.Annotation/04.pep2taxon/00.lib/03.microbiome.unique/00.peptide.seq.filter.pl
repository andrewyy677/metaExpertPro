use strict;

my ($database, $workdir, $help);
use Getopt::Long;
GetOptions( 'workdir|wd=s'	=>	\$workdir,
			'database|db=s'		=>	\$database,
			'help|h!'		=>	\$help,);
if ($help==1) {
	open HELP, "<$0";
	while (<HELP>) {	print "$_" if (/^##/);	}
	close HELP;	exit(0);
}

my @unirank2 = qw /superkingdom phylum class order family genus species strain/;
my %rank2index;
for my $i (0..7) {
	$rank2index{$unirank2[$i]} = $i;
}
my %seqnew; my %filter2ori; my %ori2filter; my %ori2filter_nouse;
open (SEQ, "<$workdir/04.pep2taxon/00.lib/03.microbiome.unique/$database\_lib_peptide_micro.seq") or die $!;
while (<SEQ>) {
	chomp; s/\r//g;
	my @seq = split //;
	my @seqnew;
	for my $i (0..$#seq) {
		if (($seq[$i] eq "K") or ($seq[$i] eq "R")) {
			if ($seq[$i + 1] ne "P") {
				$seq[$i] = $seq[$i]."\,";
			}
		}
		push @seqnew, $seq[$i];
	}
	my $seqnewj = join "", @seqnew;
	#print STDERR "$seqnewj\n";
	my @seqfinal = split /\,/, $seqnewj;
	for my $seqfinal (@seqfinal) {
		my @seqfinalsp = split //, $seqfinal;
		my $seqletter = @seqfinalsp;
		if (($seqfinal ne "") and ($seqletter >= 5) and ($seqletter <= 50)) {
			$seqnew{$seqfinal} ++;
			$filter2ori{$seqfinal}{$_} ++;
			$ori2filter{$_}{$seqfinal} ++;
		}else{
			$ori2filter_nouse{$_}{$seqfinal} ++;
		}
	}
}
for my $k1 (sort keys %ori2filter_nouse) {
	my @p;
	for my $k2 (sort keys %{$ori2filter_nouse{$k1}}) {
		push @p, $k2;
	}
	my $pj = join "\;", @p;
	#print STDERR "$k1\t$pj\n";
}
open (FIL, ">$workdir/04.pep2taxon/00.lib/03.microbiome.unique/$database\_lib_peptide_micro_filter_manual.seq") or die $!;
for my $k (sort keys %seqnew) {
	print FIL "$k\n";
}

open (F2O, ">$workdir/04.pep2taxon/00.lib/03.microbiome.unique/$database\_lib_peptide_micro_filter2ori.seq") or die $!;
open (O2F, ">$workdir/04.pep2taxon/00.lib/03.microbiome.unique/$database\_lib_peptide_micro_ori2filter.seq") or die $!;
print F2O "filter\tori\n";
print O2F "ori\tfilter\n";
for my $k1 (sort keys %filter2ori) {
	my @parr = sort keys %{$filter2ori{$k1}};
	my $pj = join "\;", @parr;
	print F2O "$k1\t$pj\n";
}

for my $k1 (sort keys %ori2filter) {
	my @parr = sort keys %{$ori2filter{$k1}};
	my $pj = join "\;", @parr;
	print O2F "$k1\t$pj\n";
}
open (UNI, "<$workdir/04.pep2taxon/00.lib/03.microbiome.unique/$database\_lib_peptide_micro_filter_unipept_pept2lca.csv") or die $!;
my $line = 0; my %pep2tax; my %pep2rank; my %pep2all; my %pep2taxmatch; my %taxmatch2all; my %taxname2all; my %taxname2alltax; my %taxname2rank; my %taxname2id;
my @pept2lcahead; my $pepi; my $taxidi; my $taxnamei; my $taxranki; my $knamei;
while (<UNI>) {
	chomp; s/\r//g;
	$line ++;
	if ($line == 1) {
		@pept2lcahead = split /\,/;
		for my $i (0..$#pep2lcahead) {
			if ($pep2lcahead[$i] eq "peptide") {
				$pepi = $i;
			}
			if ($pep2lcahead[$i] eq "taxon_id") {
				$taxidi = $i;
			}
			if ($pep2lcahead[$i] eq "taxon_name") {
				$taxnamei = $i;
			}
			if ($pep2lcahead[$i] eq "taxon_rank") {
				$taxranki = $i;
			}
			if ($pep2lcahead[$i] eq "superkingdom_name") {
				$knamei = $i;
			}
		}
	}else{
		my @data = split /\,/;
		my $pep = $data[$pepi];
		my $taxname = $data[$taxnamei];
		my $taxrank = $data[$taxranki];
		my $taxid = $data[$taxidi];
		$pep2tax{$pep} = $taxname;
		$pep2rank{$pep} = $taxrank;
		my $taxonall = join "\t", @data[$taxidi..$#data];
		my $taxonmatch = join "\t", @data[$knamei..$#data];
		$taxonall =~ s/\[//g;
		$taxonall =~ s/\]//g;
		$taxonmatch =~ s/\[//g;
		$taxonmatch =~ s/\]//g;
		$pep2all{$pep} = $taxonall;
		$pep2taxmatch{$pep} = $taxonmatch;
		$taxmatch2all{$taxonmatch} = $taxonall;
		$taxname2all{$taxname} = $taxonall;
		$taxname2rank{$taxname} = $taxrank;
		$taxname2id{$taxname} = $taxid;
	}
}
open (O2FMUL, ">$workdir/04.pep2taxon/00.lib/03.microbiome.unique/$database\_lib_peptide_micro_ori2filter_all_unipept.output") or die $!;
open (O2FCON, ">$workdir/04.pep2taxon/00.lib/03.microbiome.unique/$database\_lib_peptide_micro_ori2filter_conflict_unipept.output") or die $!;
print O2FMUL "ori\tfilter\tfilter_taxon_name\tfilter_taxon_rank\n";
print O2FCON "Line_type\tori\tfilter\tfilter_taxon_name\tfilter_taxon_rank\tTaxon_type\n";
open (O2F1, ">$workdir/04.pep2taxon/00.lib/03.microbiome.unique/$database\_lib_peptide_micro_ori2filter_one.output") or die $!;
print O2F1 "Line_type\tori\tfilter\tfilter_taxon_name\tfilter_taxon_rank\tTaxon_type\n";
open (O2F, "<$workdir/04.pep2taxon/00.lib/03.microbiome.unique/$database\_lib_peptide_micro_ori2filter.seq") or die $!;
my %pep2allnew;
my $line = 0;
while (<O2F>) {
	chomp; s/\r//g;
	$line ++;
	if ($line > 1) {
		my ($ori, $filter) = split /\t/;
		if ($filter =~ /\;/) {
			my %filtertaxU; my @filtertax;
			my %filterrankU; my @filterrank;
			my %filtertaxU2rank;
			my @filtersp = split /\;/, $filter;
			my %filterpepU;
			for my $filtersp (@filtersp) {
				if (($pep2tax{$filtersp} ne "") and ($pep2tax{$filtersp} ne "root")) {
					$filtertaxU{$pep2tax{$filtersp}} = $pep2taxmatch{$filtersp};
					$filtertaxU2rank{$pep2tax{$filtersp}} = $pep2rank{$filtersp};
					$filterrankU{$pep2rank{$filtersp}} ++;
					push @filtertax, $pep2tax{$filtersp};
					push @filterrank, $pep2rank{$filtersp};
					$filterpepU{$filtersp} ++;
				}
			}
			
			my $filterp = join "\;", @filtertax;
			my $filterrankp = join "\;", @filterrank;
			my $countrank = keys %filterrankU;
			## Are the taxons belong to the same branch?
			my $flag; my $oricount = 0; my $highest; my $highestname; my $lowest; my $lowestname;
			for my $k1 (sort keys %filtertaxU) {
				my $sbcount = 0;
				for my $k2 (sort keys %filtertaxU) {
					if ($filtertaxU{$k2} =~ /$filtertaxU{$k1}/) {
						$sbcount ++;
					}
				}
				if ($sbcount == keys %filtertaxU) {
					$flag = "same branch";
					last;
				}
			}
			
			my $strainname;
			if ($flag eq "same branch") {
				my %sbname2rank;
				for my $k1 (sort keys %filtertaxU) {
					my @taxonall = split /\t/, $filtertaxU{$k1};
					my $taxoncount = @taxonall;
					$sbname2rank{$k1} = $taxoncount;
				}
				my $count = 0;
				for my $k (sort {$sbname2rank{$b} <=> $sbname2rank{$a}} keys %sbname2rank) {
					$count ++;
					if ($count == 1) {
						$lowestname = $k;
						$lowest = $sbname2rank{$k}
					}
				}
				print O2FCON "OriLine\t$ori\t$filter\t$filterp\t$filterrankp\n";
				print O2FCON "NewLine\t$ori\t$filter\t$lowestname\t$filtertaxU2rank{$lowestname}\tsamebranch\n";
				$pep2allnew{$ori} = $taxname2all{$lowestname};
				print O2FMUL "$ori\t$filter\t$filterp\t$filterrankp\n";

			}else{
				my %kingdom;
				for my $k (sort keys %filtertaxU) {
					my $kingdom = (split /\t/, $filtertaxU{$k})[0];
					$kingdom{$kingdom} ++;
					print STDERR "diffbranch_kingdom\t$kingdom\n";
				}
				my @kingdom = keys %kingdom;
				my $kingdomflag = "allna";
				for my $k (sort keys %kingdom) {
					if ($k ne "") {
						$kingdomflag = "notallna";
						last;
					}
				}
				if ((@kingdom == 1)) {
					my %dbname2rank; my %dbnamesp;
					for my $k1 (sort keys %filtertaxU) {
						my @taxonall = split /\t/, $filtertaxU{$k1};
						for my $i (0..$#taxonall) {
							$dbname2rank{$taxonall[$i]} = $i;
							if (($taxonall[$i] =~ /^\d/) or ($taxonall[$i] eq "")) {
							}else{
								$dbnamesp{$taxonall[$i]} ++;
							}
						}
					}
					my @alltax = keys %filtertaxU;
					my %dbnamecommon;
					for my $k (sort keys %dbnamesp) {
						if ($dbnamesp{$k} == @alltax) {
							$dbnamecommon{$k} = $dbname2rank{$k};
						}
					}
					my $count = 0;
					for my $k (sort {$dbnamecommon{$b} <=> $dbnamecommon{$a}} keys %dbnamecommon) {
						$count ++;
						if ($count == 1) {
							$highestname = $k;
							$highest = $dbnamecommon{$k};
						}
					}
					my @taxallsp = split /\t/, $taxname2all{$highestname};
					my $taxall = join "\t", $taxname2id{$highestname}, $highestname, $taxname2rank{$highestname}, @taxallsp[3..($highest+4)];
					$pep2allnew{$ori} = $taxall;
					print O2FCON "OriLine\t$ori\t$filter\t$filterp\t$filterrankp\n";
					print O2FCON "NewLine\t$ori\t$filter\t$highestname\t$taxname2rank{$highestname}\tmultitaxon_diffbranch\n";
					print O2FMUL "$ori\t$filter\t$filterp\t$filterrankp\n";
				}else{
					#print O2FCON "OriLine\t$ori\t$filter\t$filterp\t$filterrankp\n";
					#print O2FCON "NewLine\t$ori\t$filter\t$highestname\t$taxname2rank{$highestname}\tmultitaxon_diffbranch_kingdom\t@kingdom\n";
				}
			}
			#print STDERR "**LOWANDHIGH**\t$lowest\t$lowestname\t$highest\t$highestname\n";
		}else{
			$pep2allnew{$ori} = $pep2all{$filter};
			print O2FMUL "$ori\t$filter\t$pep2tax{$filter}\t$pep2rank{$filter}\n";
		}
	}
}
my $count = keys %pep2allnew;
print STDERR "pep2allnew_oripep\t$count\n";
open (ORIUNI, ">$workdir/04.pep2taxon/00.lib/03.microbiome.unique/$database\_lib_peptide_micro_oriseq-pept2lca.tsv") or die $!;
my $head = join "\t", @pept2lcahead;
print ORIUNI "$head\n";
open (ORI, "<$workdir/04.pep2taxon/00.lib/03.microbiome.unique/$database\_lib_peptide_micro.seq") or die $!;
while (<ORI>) {
	chomp; s/\r//g;
	my @data = split /\t/, $pep2allnew{$_};
	my $rank = $data[2];
	my $name = $data[1];
	#print STDERR "$data[-1]\n";
	#my $strain;
	#if ($rank eq "strain") {
#		$strain = $name;
#	}else{
#		$strain = "";
#	}
	my $p = join "\t", $_, @data[0..$#data];
	print ORIUNI "$p\n";
}