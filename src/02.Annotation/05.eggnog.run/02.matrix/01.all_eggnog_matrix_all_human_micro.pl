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
print STDERR "05.eggnog.run step5.3 \nparameters: $project\n$workdir\n$database\n";

open (PG, "<$workdir/05.eggnog.run/00.lib/$database\_eggnog_progroup_annotations.txt") or die $!;
my $line = 0;
my %pgcog;
my @headanno;
my $queryi; my $cogi;
while (<PG>) {
	chomp; s/\r//g;
	$line ++;
	if ($line == 1) {
		@headanno = split /\t/;
		for my $i (0..$#headanno) {
			if ($headanno[$i] eq "#query") {
				$queryi = $i;
			}
			if ($headanno[$i] eq "eggNOG_OGs") {
				$cogi = $i;
			}
		}
	}else{
		my @data = split /\t/;
		my $query = $data[$queryi];
		my $cog = $data[$cogi];
		if ($cog ne "") {
			$pgcog{$query} = $cog;
		}
	}
}
close PG;

system("ls $workdir/01.pg/*_all.tsv > $workdir/05.eggnog.run/02.matrix/all.tsv.tmp");
open (TMP, "<$workdir/05.eggnog.run/02.matrix/all.tsv.tmp") or die $!;
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
	open (OUT, ">$workdir/05.eggnog.run/02.matrix/$type/$filepre\_cogmatrix.tsv") or die $!;
	my $line = 0;
	my @head; my %cogq;
	while (<IN>) {
		chomp; s/\r//g;
		$line ++;
		if ($line == 1) {
			@head = split /\t/;
			my $headp = join "\t", "COGnum", @head[1..$#head];
			print OUT "$headp\n";
		}else{
			my @data = split /\t/;
			my $pg = (split /\s+/, $data[0])[0];
			my $cog = $pgcog{$pg};
			if ($cog ne "") {
				my @cogsp = split /\,/, $cog;
				for my $cogsp (@cogsp) {
					for my $i (1..$#head) {
						if ($data[$i] ne "NA") {
							$cogq{$cogsp}{$head[$i]} += $data[$i];
						}
					}
				}
			}
		}
	}
	close IN;
	for my $k1 (sort keys %cogq) {
		my @cogp;
		for my $i (1..$#head) {
			if ($cogq{$k1}{$head[$i]} eq "") {
				$cogq{$k1}{$head[$i]} = "NA";
			}
			push @cogp, $cogq{$k1}{$head[$i]};
		}
		my $cogpj = join "\t", @cogp;
		print OUT "$k1\t$cogpj\n";
	}
	close OUT;
}
close TMP;

