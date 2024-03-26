use strict;

my ($workdir, $database, $help);
use Getopt::Long;
GetOptions( 'workdir|wd=s'	=>	\$workdir,
			'database|db=s'		=>	\$database,
			'help|h!'		=>	\$help,);
if ($help==1) {
	open HELP, "<$0";
	while (<HELP>) {	print "$_" if (/^##/);	}
	close HELP;	exit(0);
}

open (UNI, "<$workdir/04.pep2taxon/00.lib/03.microbiome.unique/$database\_lib_peptide_micro_oriseq-pept2lca.tsv") or die $!;
open (OUT1, ">$workdir/04.pep2taxon/00.lib/$database\_lib_micro_peptide2taxon.csv") or die $!;
print OUT1 "Peptide\,Taxon_rank\,Taxon_name\,Taxon_id\,Taxon_name_all\n";

my @unirank = qw /superkingdom_name phylum_name class_name order_name family_name genus_name species_name strain_name/;
my @uniranks = qw /k p c o f g s t/;
my @unirank2 = qw /superkingdom phylum class order family genus species strain/;
my %link;
for my $i (0..$#unirank) {
	$link{$unirank2[$i]} = $unirank[$i];
}
my @unirankall;
my @uhead; my @uindex; 
#my $total_pep = 496393; 
my $unipept_pep = 0; my $taxon_pep = 0; my $norank_pep = 0;

my %utaxon_allhash; my %utaxon_idhash; my %utaxon_namehash; my %utaxon_rankhash;
my %ctaxon_pep; my %crank_taxon;
my %staxon_rank; my %staxon_name;
#my %srank_taxon; my %srank_use_taxon;
my %srank_taxon_name; my %srank_use_taxon_name;
my %staxon_rank_pep; my %staxon_use_rank_pep;
my $line = 0; my $pepi; my $taxidi; my $taxnamei; my $taxranki; my $knamei;
while (<UNI>) {
	chomp; s/\r//g;
	$line ++;
	if ($line == 1) {
		@uhead = split /\t/;
		for my $i (0..$#uhead) {
			if ($uhead[$i] eq "peptide") {
				$pepi = $i;
			}
			if ($uhead[$i] eq "taxon_id") {
				$taxidi = $i;
			}
			if ($uhead[$i] eq "taxon_name") {
				$taxnamei = $i;
			}
			if ($uhead[$i] eq "taxon_rank") {
				$taxranki = $i;
			}
			if ($uhead[$i] eq "superkingdom_name") {
				$knamei = $i;
			}
		}
		for my $i (0..$#uhead) {
			for my $unirank (@unirank) {
				if ($uhead[$i] eq $unirank) {
					push @uindex, $i;
				}
			}
		}
		for my $i ($knamei..$#uhead) {
			if ($uhead[$i] =~ /(.*)_name/) {
				push @unirankall, $1;
			}
		}
	}else{
		$unipept_pep ++;
		my @urank;
		my @udata = split /\t/;
		my $upep = $udata[$pepi];
		my $utaxon_id = $udata[$taxidi];
		my $utaxon_name = $udata[$taxnamei];
		my $utaxon_rank = $udata[$taxranki];
		if (($utaxon_rank ne "no rank") and ($utaxon_rank ne "")) {
			my $flag = "yes";
			#if ($udata[$knamei] eq "Eukaryota") {
			#	if (($udata[13] eq "Ascomycota") or ($udata[13] eq "Chytridiomycota") or ($udata[13] eq "Basidiomycota") or ($udata[13] eq "Mucoromycota") or ($udata[13] eq "Zoopagomycota")) {
			#		$flag = "yes";
			#	}
			#}else{
			#	$flag = "yes";
			#}
			if ($flag eq "yes") {
				$staxon_rank{$utaxon_rank} ++;
				$staxon_name{$utaxon_name} ++;
				$srank_taxon_name{$utaxon_rank}{$utaxon_name} ++;
				$staxon_rank_pep{$utaxon_rank}{$upep} ++;
				$taxon_pep ++;
				if (grep /^$utaxon_rank$/, @unirank2) {
					$srank_use_taxon_name{$utaxon_rank}{$utaxon_name} ++;
					$staxon_use_rank_pep{$utaxon_rank}{$upep} ++;
					my $maxi;
					for my $uindex (@uindex) {
						if ($uhead[$uindex] =~ /^$link{$utaxon_rank}$/) {
							$maxi = $uindex;
						}
					}
					for my $uindex (@uindex) {
						if ($uindex <= $maxi) {
							push @urank, $udata[$uindex];
						}
					}
					my @uranknew;
					for my $uranki (0..$#urank) {
						$urank[$uranki] =~ s/\s+/\_/g;
						$urank[$uranki] =~ s/\.//g;
						$urank[$uranki] =~ s/\[//g;
						$urank[$uranki] =~ s/\]//g;
						my $uranknew = $uniranks[$uranki]."__".$urank[$uranki];
						#if ($uniranks[$uranki] eq "") {
						#	print STDERR "@urank\t$maxi\t$uranki\t$urank[$uranki]\t$utaxon_name\n";
						#}
						for my $uranki2 (reverse (0..$uranki)) {
							if ($urank[$uranki2] eq "") {
								$uranknew = $uniranks[$uranki]."__".$urank[$uranki2-1]."_noname";
							}else{
								last;
							}
						}
						push @uranknew, $uranknew;
					}
					my $uranknewj = join "\|", @uranknew;
					print OUT1 "$upep\,$utaxon_rank\,$utaxon_name\,$utaxon_id\,$uranknewj\n";
					$utaxon_allhash{$upep} = $uranknewj;
					$utaxon_idhash{$upep} = $utaxon_id;
					$utaxon_namehash{$upep} = $utaxon_name;
					$utaxon_rankhash{$upep} = $utaxon_rank;
					$crank_taxon{$utaxon_rank}{$uranknewj} ++;
					$ctaxon_pep{$uranknewj}{$upep} ++;
				}
			}
		}else{
			$norank_pep ++;
		}
	}
}
my $staxon_rankcount = keys %staxon_rank;
my $staxon_namecount = keys %staxon_name;
=cut
print OUT3 "Total_pep\,$total_pep\nUnipept_pep\,$unipept_pep\nTaxon_pep\,$taxon_pep\nNorank_pep\,$norank_pep\n";
print OUT3 "Taxon_rank\,$staxon_rankcount\nTaxon_name\,$staxon_namecount\n";

for my $i (0..$#unirankall) {
	my $rankcount = keys %{$srank_taxon_name{$unirankall[$i]}};
	my $rankpepcount = keys %{$staxon_rank_pep{$unirankall[$i]}};
	my $rankpepratio = $rankpepcount / $total_pep;
	print OUT3 "$unirankall[$i]\,$rankcount\,$rankpepcount\,$rankpepratio\n";
}

for my $i (0..$#unirank2) {
	my $rankcount = keys %{$srank_use_taxon_name{$unirank2[$i]}};
	my $rankpepcount = 0;
	if ($i < $#unirank2) {
		for my $k ($i..$#unirank2) {
			$rankpepcount += keys %{$staxon_use_rank_pep{$unirank2[$k]}};
		}
	}else{
		$rankpepcount = keys %{$staxon_use_rank_pep{$unirank2[$i]}};
	}
	my $rankpepratio = $rankpepcount / $total_pep;
	print OUT3 "$unirank2[$i]\,$rankcount\,$rankpepcount\,$rankpepratio\n";
}