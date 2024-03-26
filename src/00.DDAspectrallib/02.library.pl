use strict;
my ($total_dir, $help);

use Getopt::Long;
GetOptions(	'total_dir|td=s'	=>	\$total_dir,
			'help|h!'		=>	\$help,);

if ($help==1) {
	open HELP, "<$0";
	while (<HELP>) {	print "$_" if (/^##/);	}
	close HELP;	exit(0);
}

print STDERR "total_dir\t$total_dir\n";

open (LIB, "<$total_dir/Results/00.DDAspectrallib/library.tsv") or die $!;
open (OUT, ">$total_dir/Results/00.DDAspectrallib/library_pep2pro.txt") or die $!;
my $line = 0;
my @head;
my $proi; my $pepi; my %pep2pro;
while (<LIB>) {
	chomp; s/\r//g;
	$line ++;
	if ($line == 1) {
		@head = split /\t/;
		for my $i (0..$#head) {
			if ($head[$i] eq "ProteinId") {
				$proi = $i;
			}
			if ($head[$i] eq "PeptideSequence") {
				$pepi = $i;
			}
		}
	}else{
		my @data = split /\t/;
		my $pro = $data[$proi];
		my $pep = $data[$pepi];
		$pep2pro{$pep}{$pro} ++;
	}
}
close LIB;
for my $k1 (sort keys %pep2pro) {
	my @pro;
	for my $k2 (sort keys %{$pep2pro{$k1}}) {
		push @pro, $k2;
	}
	my $proj = join "\;", @pro;
	print OUT "$k1\,$proj\n";
}
close OUT;
