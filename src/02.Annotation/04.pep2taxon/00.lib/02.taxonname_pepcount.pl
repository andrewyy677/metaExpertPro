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

my @unirank2 = qw /superkingdom phylum class order family genus species strain/;
open (IN, "<$workdir/04.pep2taxon/00.lib/$database\_lib_micro_peptide2taxon.csv") or die $!;
open (OUT, ">$workdir/04.pep2taxon/00.lib/$database\_lib_micro_taxonname_pepcount.csv") or die $!;
print OUT "Taxon_name_all\,Taxon_name_short\,Taxon_name_id\,Peptide_count\n";
my $line = 0; my %rank_taxon; my %name_short;
while (<IN>) {
	chomp; s/\r//g;
	$line ++;
	if ($line > 1) {
		my ($pep, $rank, $name, $id, $name_all) = split /\,/;
		$rank_taxon{$rank}{$name_all} ++;
		my $name_short = (split /\|/, $name_all)[-1];
		$name_short{$name_all} = $name_short;
	}
}
open (IN, "<$workdir/04.pep2taxon/00.lib/$database\_lib_micro_peptide2taxon.csv") or die $!;
my $line = 0; my %taxon_pep;
while (<IN>) {
	chomp; s/\r//g;
	$line ++;
	if ($line > 1) {
		my ($pep, $rank, $name, $id, $name_all) = split /\,/;
		my @name_allsp = split /\|/, $name_all;
		for my $k (keys %name_short) {
			if (/$name_short{$k}/) {
				$taxon_pep{$k}{$pep} ++;
			}
		}
	}
}
my %name_id;
for my $unirank2 (@unirank2) {
	my $num = 0;
	for my $k (sort keys %{$rank_taxon{$unirank2}}) {
		$num ++;
		my $name_id = (split //, $name_short{$k})[0].$num;
		$name_id{$unirank2}{$k} = $name_id;
	}
}
for my $unirank2 (@unirank2) {
	for my $k (sort keys %{$name_id{$unirank2}}) {
		my $pepcount = keys %{$taxon_pep{$k}};
		print OUT "$k\,$name_short{$k}\,$name_id{$unirank2}{$k}\,$pepcount\n";
	}
}