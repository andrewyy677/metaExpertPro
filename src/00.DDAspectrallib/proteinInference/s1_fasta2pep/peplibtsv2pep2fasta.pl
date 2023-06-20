use strict;
my ($peptidetsv, $library, $help, $outdir);

use Getopt::Long;
GetOptions(	'peptsv|pept=s'	=>	\$peptidetsv,
			'lib|l=s'		=>	\$library,
			'out|o=s'		=>	\$outdir,
			'help|h!'		=>	\$help,);
if ($help==1) {
	open HELP, "<$0";
	while (<HELP>) {	print "$_" if (/^##/);	}
	close HELP;	exit(0);
}
print STDERR "step1 parameters: $peptidetsv\n$library\n$outdir\n";

open (LIB, "<$library") or die $!;
my $line = 0; my @head; my $pepi; my %libpep;
while (<LIB>) {
	chomp; s/\r//g;
	$line ++;
	if ($line == 1) {
		@head = split /\t/;
		for my $i (0..$#head) {
			if ($head[$i] eq "PeptideSequence") {
				$pepi = $i;
			}
		}
	}else{
		my @data = split /\t/;
		my $pep = $data[$pepi];
		$pep =~ s/I/B/g;
		$pep =~ s/L/B/g;
		$libpep{$pep} ++;
	}
}

open (TSV, "<$peptidetsv") or die $!;
open (OUT, ">$outdir/pep2fasta.txt") or die $!;
my $line = 0; my %pro; my %tsvpep2pro; my %tsvpep;
while (<TSV>) {
	chomp; s/\r//g;
	$line ++;
	if ($line > 1) {
		my ($pep, $pro, $procom) = (split /\t/)[0,10,16];
		#print STDERR "$pro\n$procom\n";
		$pep =~ s/I/B/g;
		$pep =~ s/L/B/g;
		if (exists $libpep{$pep}) {
			$tsvpep{$pep} ++;
			my @procomsp = split /\,/, $procom;
			for my $procomsp (@procomsp) {
				$procomsp =~ s/\s+//g;
				if ($procomsp =~ /^rev/) {
				}else{
					$pro{$procomsp} ++;
					$tsvpep2pro{$pep}{$procomsp} ++;
				}
			}
			$pro =~ s/\s+//g;
			if ($pro =~ /^rev/) {
			}else{
				$pro{$pro} ++;
				$tsvpep2pro{$pep}{$pro} ++;
			}
		}
	}
}
my $proc = keys %pro;
#print "$proc\n";
my %tsvpep2procomb; my $tsvpep2pro = 0;
for my $k1 (sort keys %tsvpep2pro) {
	$tsvpep2pro ++;
	my @arr = keys %{$tsvpep2pro{$k1}};
	@arr = sort @arr;
	my $arrj = join "\;", @arr;
	$tsvpep2procomb{$k1} = $arrj;
	print OUT "$k1\,$arrj\n";
}