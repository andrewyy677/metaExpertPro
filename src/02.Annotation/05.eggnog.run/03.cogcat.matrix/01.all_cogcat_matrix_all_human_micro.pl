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
print STDERR "05.eggnog.run step5.6 \nparameters: $project\n$srcdir\n$workdir\n$database\n";

open (HASH, "<$srcdir/05.eggnog.run/01.cog_annotation/01.NCBI.COG.list.txt") or die $!;
my $line = 0;
my %cogcat;
while (<HASH>) {
	chomp; s/\r//g;
	$line ++;
	if ($line > 1) {
		my @data = split /\t/;
		my $cog = $data[0];
		my $cat = $data[1];
		$cogcat{$cog} = $cat;
	}
}

system("ls $workdir/05.eggnog.run/02.matrix/COGmatrix_all/*_all_cogmatrix.tsv > $workdir/05.eggnog.run/03.cogcat.matrix/all.tsv.tmp");
open (TMP, "<$workdir/05.eggnog.run/03.cogcat.matrix/all.tsv.tmp") or die $!;
while (<TMP>) {
	chomp; s/\r//g;
	my $path = $_;
	my $filepre;
	if ($path =~ /COGmatrix_all\/(.*)_all_cogmatrix.tsv/) {
		$filepre = $1;
	}
	my $type;
	if ($path =~ /COGmatrix_all\/$project\_diann_$database\_(.*)_all_cogmatrix.tsv/) {
		$type = $1;
	}
	open (IN, "<$path") or die $!;
	open (OUT, ">$workdir/05.eggnog.run/03.cogcat.matrix/$type/$filepre\_cogcatmatrix.tsv") or die $!;
	my $line = 0;
	my @head; my %cogcatq;
	while (<IN>) {
		chomp; s/\r//g;
		$line ++;
		if ($line == 1) {
			@head = split /\t/;
			my $headp = join "\t", "COGcat", @head[1..$#head];
			print OUT "$headp\n";
		}else{
			my @data = split /\t/;
			my $cog = $data[0];
			my $cogcat = $cogcat{$cog};
			if ($cogcat ne "") {
				my @cogcatsp = split //, $cogcat;
				for my $cogcatsp (@cogcatsp) {
					for my $i (1..$#head) {
						if ($data[$i] ne "NA") {
							$cogcatq{$cogcatsp}{$head[$i]} += $data[$i];
						}
					}
				}
			}
		}
	}
	close IN;
	for my $k1 (sort keys %cogcatq) {
		my @cogcatp;
		for my $i (1..$#head) {
			if ($cogcatq{$k1}{$head[$i]} eq "") {
				$cogcatq{$k1}{$head[$i]} = "NA";
			}
			push @cogcatp, $cogcatq{$k1}{$head[$i]};
		}
		my $cogcatpj = join "\t", @cogcatp;
		print OUT "$k1\t$cogcatpj\n";
	}
	close OUT;
}
close TMP;

