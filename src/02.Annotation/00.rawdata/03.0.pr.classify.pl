use strict;
my ($workdir, $project, $database, $pepfile, $help);

use Getopt::Long;
GetOptions(	'workdir|wd=s'		=>	\$workdir,
			'project|proj=s'		=>	\$project,
			'database|db=s'		=>	\$database,
			'pepfile|pepf=s'	=>	\$pepfile,
			'help|h!'		=>	\$help,);
if ($help==1) {
	open HELP, "<$0";
	while (<HELP>) {	print "$_" if (/^##/);	}
	close HELP;	exit(0);
}
print STDERR "00.rawdata step3.0 \nparameters: $workdir\n$project\n$database\n$pepfile\n";

open (PEP, "<$pepfile") or die $!;
my %protype; my %protype_sta; my %pep2procomb; my %count;
my @head; my $line = 0; my $proi; my $pepi; my $genei;
while (<PEP>) {
	chomp; s/\r//g;
	$line ++;
	if ($line == 1) {
		@head = split /\t/;
		for my $i (0..$#head) {
			if ($head[$i] eq "Protein.Group") {
				$proi = $i;
			}
			if ($head[$i] eq "Stripped.Sequence") {
				$pepi = $i;
			}
			if ($head[$i] eq "Genes") {
				$genei = $i;
			}
		}
	}else{
		my @data = split /\t/;
		my $pepseq = $data[$pepi];
		my $procomb = $data[$proi];
		$pep2procomb{$pepseq} = $procomb;
		my @prosp = split /\;/, $procomb;
		my $humanf = 0;
		my $microf = 0;
		my $contamf = 0;
		for my $prosp (@prosp) {
			if ($prosp =~ /^MAX/) {
				$contamf ++;
			}elsif (($prosp =~ /Human/i) or ($data[$genei] ne "")) {
				$humanf ++;
			}else{
				$microf ++;
			}
		}
		if ($humanf > 0) {
			$protype{$pepseq}{"human"} = 1;
		}else{
			$protype{$pepseq}{"human"} = 0;
		}
		if ($contamf > 0) {
			$protype{$pepseq}{"contam"} = 1;
		}else{
			$protype{$pepseq}{"contam"} = 0;
		}
		if ($microf > 0) {
			$protype{$pepseq}{"micro"} = 1;
		}else{
			$protype{$pepseq}{"micro"} = 0;
		}
	}
}
my $humanU = 0; my $microU = 0; my $contamU = 0; my $HMshared = 0; my $HCshared = 0; my $MCshared = 0;
for my $k1 (sort keys %protype) {
	if (($protype{$k1}{"human"} eq "1") and ($protype{$k1}{"micro"} eq "1")) {
		$HMshared ++;
	}
	if (($protype{$k1}{"human"} eq "1") and ($protype{$k1}{"contam"} eq "1")) {
		$HCshared ++;
	}
	if (($protype{$k1}{"micro"} eq "1") and ($protype{$k1}{"contam"} eq "1")) {
		$HCshared ++;
	}
	if (($protype{$k1}{"human"} eq "1") and ($protype{$k1}{"micro"} eq "0") and ($protype{$k1}{"contam"} eq "0")) {
		$humanU ++;
	}
	if (($protype{$k1}{"human"} eq "0") and ($protype{$k1}{"micro"} eq "1") and ($protype{$k1}{"contam"} eq "0")) {
		$microU ++;
	}
	if (($protype{$k1}{"human"} eq "0") and ($protype{$k1}{"micro"} eq "0") and ($protype{$k1}{"contam"} eq "1")) {
		$contamU ++;
	}
}
open (SUM, ">$workdir/00.rawdata/03.0.pr.classify.error") or die $!;
print SUM "HumanUnique\t$humanU\nMicroUnique\t$microU\nContamUnique\t$contamU\nMHShared\t$HMshared\nHCshared\t$HCshared\nMCshared\t$MCshared\n";
my @type = qw /human micro contam/;
open (OUT, ">$workdir/00.rawdata/$project\_diann_$database\_peptide_classify.txt") or die $!;
print OUT "Stripped.Sequence\tProtein.Group\tHuman\tMicro\tContam\n";
for my $k (sort keys %protype) {
	my @p;
	for my $type (@type) {
		push @p, $protype{$k}{$type};
	}
	my $pj = join "\t", @p;
	print OUT "$k\t$pep2procomb{$k}\t$pj\n";
}