use strict;

my ($workdir, $srcdir, $project, $database, $help);

use Getopt::Long;
GetOptions(	'workdir|wd=s'		=>	\$workdir,
			'srcdir|sd=s'		=>	\$srcdir,
			'project|proj=s'		=>	\$project,
			'database|db=s'		=>	\$database,
			'help|h!'		=>	\$help,);
if ($help==1) {
	open HELP, "<$0";
	while (<HELP>) {	print "$_" if (/^##/);	}
	close HELP;	exit(0);
}
print STDERR "06.kegg.run step6.6 \nparameters: $project\n$srcdir\n$workdir\n$database\n";

open (HASH, "<$srcdir/06.kegg.run/01.kegg_annotation/kegg_database_format.txt") or die $!;
my $line = 0;
my %keggcat;
while (<HASH>) {
	chomp; s/\r//g;
	$line ++;
	if ($line > 1) {
		my @data = split /\t/;
		my $kegg = $data[0];
		my $cat = $data[3];
		$keggcat{$kegg}{$cat} ++;
	}
}

system("ls $workdir/06.kegg.run/02.matrix/KEGGmatrix_all/*_all_keggmatrix.tsv > $workdir/06.kegg.run/03.keggcat.matrix/all.tsv.tmp");
open (TMP, "<$workdir/06.kegg.run/03.keggcat.matrix/all.tsv.tmp") or die $!;
while (<TMP>) {
	chomp; s/\r//g;
	my $path = $_;
	my $filepre;
	if ($path =~ /KEGGmatrix_all\/(.*)_all_keggmatrix.tsv/) {
		$filepre = $1;
	}
	my $type;
	if ($path =~ /KEGGmatrix_all\/$project\_diann_$database\_(.*)_all_keggmatrix.tsv/) {
		$type = $1;
	}
	open (IN, "<$path") or die $!;
	open (OUT, ">$workdir/06.kegg.run/03.keggcat.matrix/$type/$filepre\_keggcatmatrix.tsv") or die $!;
	my $line = 0;
	my @head; my %keggcatq;
	while (<IN>) {
		chomp; s/\r//g;
		$line ++;
		if ($line == 1) {
			@head = split /\t/;
			my $headp = join "\t", "KEGGcat", @head[1..$#head];
			print OUT "$headp\n";
		}else{
			my @data = split /\t/;
			my $kegg = $data[0];
			for my $k2 (sort keys %{$keggcat{$kegg}}) {
				if ($k2 ne "") {
					for my $i (1..$#head) {
						if ($data[$i] ne "NA") {
							$keggcatq{$k2}{$head[$i]} += $data[$i];
						}
					}
				}
			}
		}
	}
	close IN;
	for my $k1 (sort keys %keggcatq) {
		my @keggcatp;
		for my $i (1..$#head) {
			if ($keggcatq{$k1}{$head[$i]} eq "") {
				$keggcatq{$k1}{$head[$i]} = "NA";
			}
			push @keggcatp, $keggcatq{$k1}{$head[$i]};
		}
		my $keggcatpj = join "\t", @keggcatp;
		print OUT "$k1\t$keggcatpj\n";
	}
	close OUT;
}
close TMP;

