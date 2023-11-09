use strict;

my ($workdir, $project, $database, $help);

use Getopt::Long;
GetOptions(	'workdir|wd=s'		=>	\$workdir,
			'project|proj=s'		=>	\$project,
			'database|db=s'		=>	\$database,
			'help|h!'		=>	\$help,);
if ($help==1) {
	open HELP, "<$0";
	while (<HELP>) {	print "$_" if (/^##/);	}
	close HELP;	exit(0);
}
print STDERR "06.kegg.run step6.4 \nparameters: $project\n$workdir\n$database\n";

open (PG, "<$workdir/06.kegg.run/00.lib/$database\_kegg_progroup.txt") or die $!;
my $line = 0;
my %pgkegg;
while (<PG>) {
	chomp; s/\r//g;
	$line ++;
	if ($line > 1) {
		my @data = split /\t/;
		my $query = $data[0];
		my $kegg = $data[1];
		if ($kegg ne "") {
			$pgkegg{$query} = $kegg;
		}
	}
}
close PG;
system("ls $workdir/01.pg/*_all.tsv > $workdir/06.kegg.run/02.matrix/all.tsv.tmp");
open (TMP, "<$workdir/06.kegg.run/02.matrix/all.tsv.tmp") or die $!;
while (<TMP>) {
	chomp; s/\r//g;
	my $path = $_;
	my $filepre;
	if ($path =~ /01.pg\/(.*).tsv/) {
		$filepre = $1;
	}
	my $type;
	if ($path =~ /01.pg\/$project\_diann_$database\_(.*)_all.tsv/) {
		$type = $1;
	}
	open (IN, "<$path") or die $!;
	open (OUT, ">$workdir/06.kegg.run/02.matrix/$type/$filepre\_keggmatrix.tsv") or die $!;
	my $line = 0;
	my @head; my %keggq;
	while (<IN>) {
		chomp; s/\r//g;
		$line ++;
		if ($line == 1) {
			@head = split /\t/;
			my $headp = join "\t", "KEGGnum", @head[1..$#head];
			print OUT "$headp\n";
		}else{
			my @data = split /\t/;
			my $pg = (split /\s+/, $data[0])[0];
			my $kegg = $pgkegg{$pg};
			if ($kegg ne "") {
				my @keggsp = split /\//, $kegg;
				for my $keggsp (@keggsp) {
					for my $i (1..$#head) {
						if ($data[$i] ne "NA") {
							$keggq{$keggsp}{$head[$i]} += $data[$i];
						}
					}
				}
			}
		}
	}
	close IN;
	for my $k1 (sort keys %keggq) {
		my @keggp;
		for my $i (1..$#head) {
			if ($keggq{$k1}{$head[$i]} eq "") {
				$keggq{$k1}{$head[$i]} = "NA";
			}
			push @keggp, $keggq{$k1}{$head[$i]};
		}
		my $keggpj = join "\t", @keggp;
		print OUT "$k1\t$keggpj\n";
	}
	close OUT;
}
close TMP;

