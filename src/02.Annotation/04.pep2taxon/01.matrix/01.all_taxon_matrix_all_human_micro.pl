use strict;
my ($workdir, $project, $database, $libpep2tax, $help);

use Getopt::Long;
GetOptions(	'workdir|wd=s'		=>	\$workdir,
			'project|proj=s'		=>	\$project,
			'database|db=s'		=>	\$database,
			'libpep2tax|lp2t=s'	=>	\$libpep2tax,
			'help|h!'		=>	\$help,);
if ($help==1) {
	open HELP, "<$0";
	while (<HELP>) {	print "$_" if (/^##/);	}
	close HELP;	exit(0);
}
print STDERR "04.pep2taxon step4.3 \nparameters: $project\n$workdir\n$database\n$libpep2tax\n";


my %taxrank; my %taxname; my %taxid; my %taxname_all;
open (LIB, "<$libpep2tax") or die $!;
while (<LIB>) {
	chomp; s/\r//g;
	my ($pep, $taxrank, $taxname, $taxid, $taxname_all) = split /\,/;
	$taxrank{$pep} = $taxrank;
	$taxname{$pep} = $taxname;
	$taxid{$pep} = $taxid;
	$taxname_all{$pep} = $taxname_all;
}
my @rank = qw /superkingdom phylum class order family genus species strain/;
my @ranks = qw /k p c o f g s t/;


## pepcount
open (IN, "<$workdir/02.pr/$project\_diann1.8_$database\_micropeptide_all.tsv") or die $!;
my $mari = 0; my @mhead; my %ueachcount; my %taxpepcount; my %taxquan;
while (<IN>) {
	chomp; s/\r//g;
	$mari ++;
	if ($mari == 1) {
		@mhead = split /\t/;
	}else{
		my @mdata = split /\t/;
		if ($taxname_all{$mdata[0]} ne "") {
			for my $m (1..$#mhead) {
				if ($mdata[$m] ne "NA") {
					my @taxallsp = split /\|/, $taxname_all{$mdata[0]};
					for my $taxallsp (@taxallsp) {
						$ueachcount{$taxallsp}{$mhead[$m]} ++;
					}
					for my $i (0..$#taxallsp) {
						my @taxallsp_name;
						if ($i == 0) {
							push @taxallsp_name, $taxallsp[$i];
						}else{
							for my $j (0..$i) {
								push @taxallsp_name, $taxallsp[$j];
							}
						}
						my $taxallsp_namej = join "\|", @taxallsp_name;
						$taxpepcount{$rank[$i]}{$taxallsp_namej}{$mhead[$m]}{$mdata[0]} ++;
						$taxquan{$rank[$i]}{$taxallsp_namej}{$mhead[$m]} += $mdata[$m];
					}
				}
			}
		}
	}
}
close IN;
my @filter = qw /1 2 3 5 10 15 20/;
for my $filter (@filter) {
	for my $k1 (sort keys %taxpepcount) {
		open (OUT, ">$workdir/04.pep2taxon/01.matrix/02.taxon_matrix/filter$filter/$project\_diann1.8_$database\_micropeptide_all_unipept_filter$filter\_$k1\_matrix.txt") or die $!;
		my $headp = join "\t", "Taxon_name", @mhead[1..$#mhead];
		print OUT "$headp\n";
		for my $k2 (sort keys %{$taxpepcount{$k1}}) {
			my @data;
			for my $i (1..$#mhead) {
				my $pepcount = keys %{$taxpepcount{$k1}{$k2}{$mhead[$i]}};
				if ($pepcount >= $filter) {
					if (($taxquan{$k1}{$k2}{$mhead[$i]} == 0) or (($taxquan{$k1}{$k2}{$mhead[$i]} eq ""))){
						$taxquan{$k1}{$k2}{$mhead[$i]} = "NA";
					}
				}else{
					$taxquan{$k1}{$k2}{$mhead[$i]} = "NA";
				}
				push @data, $taxquan{$k1}{$k2}{$mhead[$i]};
			}
			my $nacount;
			my $datacount = @data;
			for my $j (0..$#data) {
				if ($data[$j] eq "NA") {
					$nacount ++;
				}
			}
			my $naflag;
			if ($nacount == $datacount) {
				$naflag = "allNA";
			}else{
				$naflag = "notallNA";
			}
			if ($naflag eq "notallNA") {
				my $datap = join "\t", $k2, @data;
				print OUT "$datap\n";
			}
		}
	}
}

close OUT;