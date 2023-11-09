use strict;

my ($database, $workdir, $help);
use Getopt::Long;
GetOptions( 'workdir|wd=s'	=>	\$workdir,
			'database|db=s'		=>	\$database,
			'help|h!'		=>	\$help,);
if ($help==1) {
	open HELP, "<$0";
	while (<HELP>) {	print "$_" if (/^##/);	}
	close HELP;	exit(0);
}

open (PEP2PRO, "<$workdir/04.pep2taxon/00.lib/library_pep2pro.txt") or die $!;
open (OUTS, ">$workdir/04.pep2taxon/00.lib/01.all.peptide/$database\_lib_peptide.seq") or die $!;
open (OUTS1, ">$workdir/04.pep2taxon/00.lib/02.human.unique/$database\_lib_peptide_human.seq") or die $!;
open (OUTS2, ">$workdir/04.pep2taxon/00.lib/03.microbiome.unique/$database\_lib_peptide_micro.seq") or die $!;
my %protype; my %protype_sta;
my $humanU = 0; my $microU = 0; my $contamU = 0; my $HMshared = 0; my $HCshared = 0; my $MCshared = 0;
while (<PEP2PRO>) {
	chomp; s/\r//g;
	my @data = split /\,/;
	my $pepseq = $data[0];
	my $procomb;
	if (@data > 2) {
		$procomb = join "\,", @data[1..$#data];
	}else{
		$procomb = $data[1];
	}
	my @prosp = split /\;/, $procomb;
	my $humanf = 0;
	my $microf = 0;
	my $contamf = 0;
	for my $prosp (@prosp) {
		if ($prosp =~ /Human/i) {
			$humanf ++;
		}elsif ($prosp =~ /^MAX/) {
			$contamf ++;
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
	if (($humanf > 0) and ($microf > 0)) {
		$protype_sta{$pepseq} = "HMshared";
		$HMshared ++;
	}
	if (($humanf > 0) and ($contamf > 0)) {
		$protype_sta{$pepseq} = "HCshared";
		$HCshared ++;
	}
	if (($microf > 0) and ($contamf > 0)) {
		$protype_sta{$pepseq} = "MCshared";
		$MCshared ++;
	}
	print OUTS "$pepseq\n";
	if (($humanf > 0) and ($microf == 0) and ($contamf == 0)) {
		$protype_sta{$pepseq} = "Human_unique";
		$humanU ++;
		print OUTS1 "$pepseq\n";
	}
	if (($humanf == 0) and ($microf > 0) and ($contamf == 0)) {
		$protype_sta{$pepseq} = "Micro_unique";
		$microU ++;
		print OUTS2 "$pepseq\n";
	}
	if (($humanf == 0) and ($microf == 0) and ($contamf > 0)) {
		$protype_sta{$pepseq} = "Contam_unique";
		$contamU ++;
	}
}
print STDERR "HumanUnique\t$humanU\nMicroUnique\t$microU\nContamUnique\t$contamU\nMHShared\t$HMshared\nHCshared\t$HCshared\nMCshared\t$MCshared\n";
my @type = qw /human micro contam/;
open (OUT, ">$workdir/04.pep2taxon/00.lib/$database\_lib_peptide_classify.txt") or die $!;
print OUT "Lib.peptide\tHuman\tMicro\tContam\n";
for my $k (sort keys %protype) {
	my @p;
	for my $type (@type) {
		push @p, $protype{$k}{$type};
	}
	my $pj = join "\t", @p;
	print OUT "$k\t$pj\n";
}