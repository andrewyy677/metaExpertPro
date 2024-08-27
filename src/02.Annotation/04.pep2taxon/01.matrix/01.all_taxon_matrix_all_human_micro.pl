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
open (IN, "<$workdir/02.pr/$project\_diann_$database\_micropeptide_all.tsv") or die $!;
my $mari = 0; my @mhead; my %ueachcount; my %taxpepcount; my %taxquan; my %taxeachpepcount;
while (<IN>) {
	chomp; s/\r//g;
	$mari ++;
	if ($mari == 1) {
		@mhead = split /\t/;
	}else{
		my @mdata = split /\t/;
		if ($taxname_all{$mdata[0]} ne "") {
			my @taxallspnew = split /\|/, $taxname_all{$mdata[0]};
			for my $taxallspnew (@taxallspnew) {
				$taxeachpepcount{$taxallspnew} ++;
			}
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

open (MED, ">$workdir/04.pep2taxon/01.matrix/01.add_unipept_info/$project\_diann_$database\_micropeptide_all_unipept.tsv") or die $!;
open (MEDF1, ">$workdir/04.pep2taxon/01.matrix/01.add_unipept_info/$project\_diann_$database\_micropeptide_all_unipept_filter1.tsv") or die $!;
open (MEDF2, ">$workdir/04.pep2taxon/01.matrix/01.add_unipept_info/$project\_diann_$database\_micropeptide_all_unipept_filter2.tsv") or die $!;
open (MEDF3, ">$workdir/04.pep2taxon/01.matrix/01.add_unipept_info/$project\_diann_$database\_micropeptide_all_unipept_filter3.tsv") or die $!;
open (MEDF4, ">$workdir/04.pep2taxon/01.matrix/01.add_unipept_info/$project\_diann_$database\_micropeptide_all_unipept_filter5.tsv") or die $!;
open (MEDF5, ">$workdir/04.pep2taxon/01.matrix/01.add_unipept_info/$project\_diann_$database\_micropeptide_all_unipept_filter10.tsv") or die $!;
open (MEDF6, ">$workdir/04.pep2taxon/01.matrix/01.add_unipept_info/$project\_diann_$database\_micropeptide_all_unipept_filter15.tsv") or die $!;
open (MEDF7, ">$workdir/04.pep2taxon/01.matrix/01.add_unipept_info/$project\_diann_$database\_micropeptide_all_unipept_filter20.tsv") or die $!;
open (MAR, "<$workdir/02.pr/$project\_diann_$database\_micropeptide_all.tsv") or die $!;
my $mari = 0; my @mhead;
while (<MAR>) {
	chomp; s/\r//g;
	$mari ++;
	if ($mari == 1) {
		@mhead = split /\t/;
		my $mheadp = join "\t", $mhead[0], "taxon_id", "taxon_name", "taxon_rank", "taxon_all", "taxon_count", @mhead[1..$#mhead];
		print MED "$mheadp\n";
		print MEDF1 "$mheadp\n";
		print MEDF2 "$mheadp\n";
		print MEDF3 "$mheadp\n";
		print MEDF4 "$mheadp\n";
		print MEDF5 "$mheadp\n";
		print MEDF6 "$mheadp\n";
		print MEDF7 "$mheadp\n";
	}else{
		my @mdata = split /\t/;
		my @taxnamesp = split /\|/, $taxname_all{$mdata[0]};
		my $taxname = $taxnamesp[-1];
		my $taxidnew; my $taxnamenew; my $taxranknew; my $taxname_allnew;
		if ($taxid{$mdata[0]} eq "") {
			$taxidnew = "No_taxon";
			$taxnamenew = "No_taxon";
			$taxranknew = "No_taxon";
			$taxname_allnew = "No_taxon";
		}else{
			$taxidnew = $taxid{$mdata[0]};
			$taxnamenew = $taxname{$mdata[0]};
			$taxranknew = $taxrank{$mdata[0]};
			$taxname_allnew = $taxname_all{$mdata[0]};
		}
		my $mdatap = join "\t", $mdata[0], $taxidnew, $taxnamenew, $taxranknew, $taxname_allnew, $taxeachpepcount{$taxname}, @mdata[1..$#mdata];
		print MED "$mdatap\n";
		if ($taxeachpepcount{$taxname} >= 1) {
			print MEDF1 "$mdatap\n";
		}
		if ($taxeachpepcount{$taxname} >= 2) {
			print MEDF2 "$mdatap\n";
		}
		if ($taxeachpepcount{$taxname} >= 3) {
			print MEDF3 "$mdatap\n";
		}
		if ($taxeachpepcount{$taxname} >= 5) {
			print MEDF4 "$mdatap\n";
		}	
		if ($taxeachpepcount{$taxname} >= 10) {
			print MEDF5 "$mdatap\n";
		}	
		if ($taxeachpepcount{$taxname} >= 15) {
			print MEDF6 "$mdatap\n";
		}	
		if ($taxeachpepcount{$taxname} >= 20) {
			print MEDF7 "$mdatap\n";
		}	
	}
}
close MED; close MEDF1; close MEDF2; close MEDF3; close MEDF4; close MEDF5; close MEDF6; close MEDF7; close MAR;


my @filter = qw /1 2 3 5 10 15 20/;

for my $filter (@filter) {
	system("mkdir $workdir/04.pep2taxon/01.matrix/02.taxon_matrix/filter$filter");
	for my $k1 (sort keys %taxpepcount) {
		open (OUT, ">$workdir/04.pep2taxon/01.matrix/02.taxon_matrix/filter$filter/$project\_diann_$database\_micropeptide_all_unipept_filter$filter\_$k1\_matrix.txt") or die $!;
		my $headp = join "\t", "Taxon_name", @mhead[1..$#mhead];
		print OUT "$headp\n";
		for my $k2 (sort keys %{$taxpepcount{$k1}}) {
			my @data;
			for my $i (1..$#mhead) {
				my $taxnow = (split /\|/, $k2)[-1];
				my $pepcount = $taxeachpepcount{$taxnow};
				#my $pepcount = keys %{$taxpepcount{$k1}{$k2}{$mhead[$i]}};
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