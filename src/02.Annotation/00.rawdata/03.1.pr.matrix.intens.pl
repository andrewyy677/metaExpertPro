use strict;

my ($workdir, $project, $database, $filesample, $pepfile, $help);

use Getopt::Long;
GetOptions(	'workdir|wd=s'		=>	\$workdir,
			'project|proj=s'		=>	\$project,
			'database|db=s'		=>	\$database,
			'filesample|fs=s'		=>	\$filesample,
			'pepfile|pepf=s'	=>	\$pepfile,
			'help|h!'		=>	\$help,);
if ($help==1) {
	open HELP, "<$0";
	while (<HELP>) {	print "$_" if (/^##/);	}
	close HELP;	exit(0);
}
print STDERR "00.rawdata step 3.1 \nparameters: $workdir\n$project\n$database\n$filesample\n$pepfile\n";


open (SAM, "<$filesample") or die $!;
my %batchID; my %sampleID; my %rep_lab; my %sam_lab;
my $line = 0;
while (<SAM>) {
	chomp; s/\r//g;
	$line ++;
	if ($line > 1) {
		my @data = split /\,/;
		my $filename = $data[1];
		$batchID{$filename} = $data[2];
		$sampleID{$filename} = $data[6];
		$rep_lab{$filename} = $data[4];
		$sam_lab{$filename} = $data[5];
	}
}
open (CLA, "<$workdir/00.rawdata/$project\_diann1.8_$database\_peptide_classify.txt") or die $!;
my $cline = 0;
my %peptype;
while (<CLA>) {
	chomp; s/\r//g;
	$cline ++;
	if ($cline > 1) {
		my ($pep, $pro, $human, $micro, $contam) = split /\t/;
		if (($human == 1) and ($micro == 0) and ($contam == 0)) {
			$peptype{$pep} = "Human_unique";
		}
		if (($human == 0) and ($micro == 1) and ($contam == 0)) {
			$peptype{$pep} = "Micro_unique";
		}
		if ($contam == 1) {
			$peptype{$pep} = "Contam";
		}
	}
}

open (BREP, ">$workdir/02.pr/$project\_diann1.8_$database\_peptide_biorep.tsv") or die $!;
open (TREP, ">$workdir/02.pr/$project\_diann1.8_$database\_peptide_techrep.tsv") or die $!;
open (POOL, ">$workdir/02.pr/$project\_diann1.8_$database\_peptide_pool.tsv") or die $!;
open (QC, ">$workdir/02.pr/$project\_diann1.8_$database\_peptide_qc.tsv") or die $!;
open (OUT, ">$workdir/02.pr/$project\_diann1.8_$database\_peptide_sample.tsv") or die $!;
open (ALL, ">$workdir/02.pr/$project\_diann1.8_$database\_peptide_all.tsv") or die $!;

open (BREP1, ">$workdir/02.pr/$project\_diann1.8_$database\_humanpeptide_biorep.tsv") or die $!;
open (TREP1, ">$workdir/02.pr/$project\_diann1.8_$database\_humanpeptide_techrep.tsv") or die $!;
open (POOL1, ">$workdir/02.pr/$project\_diann1.8_$database\_humanpeptide_pool.tsv") or die $!;
open (QC1, ">$workdir/02.pr/$project\_diann1.8_$database\_humanpeptide_qc.tsv") or die $!;
open (OUT1, ">$workdir/02.pr/$project\_diann1.8_$database\_humanpeptide_sample.tsv") or die $!;
open (ALL1, ">$workdir/02.pr/$project\_diann1.8_$database\_humanpeptide_all.tsv") or die $!;

open (BREP2, ">$workdir/02.pr/$project\_diann1.8_$database\_micropeptide_biorep.tsv") or die $!;
open (TREP2, ">$workdir/02.pr/$project\_diann1.8_$database\_micropeptide_techrep.tsv") or die $!;
open (POOL2, ">$workdir/02.pr/$project\_diann1.8_$database\_micropeptide_pool.tsv") or die $!;
open (QC2, ">$workdir/02.pr/$project\_diann1.8_$database\_micropeptide_qc.tsv") or die $!;
open (OUT2, ">$workdir/02.pr/$project\_diann1.8_$database\_micropeptide_sample.tsv") or die $!;
open (ALL2, ">$workdir/02.pr/$project\_diann1.8_$database\_micropeptide_all.tsv") or die $!;

open (MAT, "<$pepfile") or die $!;
my $line = 0; my %peptideq; my @head;
my @hsample; my @hall; my @hbiorep; my @htechrep; my @hpool; my @hqc;
my @samplei; my @alli; my @biorepi; my @techrepi; my @pooli; my @qci;
while (<MAT>) {
	chomp; s/\r//g;
	$line ++;
	if ($line == 1) {
		@head = split /\t/;
		for my $i (10..$#head) {
			if ($head[$i] =~ /\//) {
				$head[$i] = (split /\//, $head[$i])[-1];
			}
			if ($head[$i] =~ /\\/) {
				$head[$i] = (split /\\/, $head[$i])[-1];
			}
			if (exists $batchID{$head[$i]}) {
				push @alli, $i;
				if ($sam_lab{$head[$i]} =~ /sample/) {
					push @samplei, $i;
				}
				if ($rep_lab{$head[$i]} =~ /biorep/) {
					push @biorepi, $i;
				}
				if ($rep_lab{$head[$i]} =~ /techrep/) {
					push @techrepi, $i;
				}
				if ($rep_lab{$head[$i]} =~ /pool/) {
					push @pooli, $i;
				}
				if ($rep_lab{$head[$i]} =~ /qc/) {
					push @qci, $i;
				}
			}
		}
		for my $i (@alli) {
			push @hall, $batchID{$head[$i]};
		}
		for my $i (@samplei) {
			push @hsample, $sampleID{$head[$i]};
		}
		for my $i (@biorepi) {
			push @hbiorep, $batchID{$head[$i]};
		}
		for my $i (@techrepi) {
			push @htechrep, $batchID{$head[$i]};
		}
		for my $i (@pooli) {
			push @hpool, $batchID{$head[$i]};
		}
		for my $i (@qci) {
			push @hqc, $batchID{$head[$i]};
		}
		my $hallj = join "\t", "Peptide.Seq", @hall;
		print ALL "$hallj\n";
		print ALL1 "$hallj\n";
		print ALL2 "$hallj\n";
		my $hsamplej = join "\t", "Peptide.Seq", @hsample;
		print OUT "$hsamplej\n";
		print OUT1 "$hsamplej\n";
		print OUT2 "$hsamplej\n";
		my $hbiorepj = join "\t", "Peptide.Seq", @hbiorep;
		print BREP "$hbiorepj\n";
		print BREP1 "$hbiorepj\n";
		print BREP2 "$hbiorepj\n";
		my $htechrepj = join "\t", "Peptide.Seq", @htechrep;
		print TREP "$htechrepj\n";
		print TREP1 "$htechrepj\n";
		print TREP2 "$htechrepj\n";
		my $hpoolj = join "\t", "Peptide.Seq", @hpool;
		print POOL "$hpoolj\n";
		print POOL1 "$hpoolj\n";
		print POOL2 "$hpoolj\n";
		my $hqcj = join "\t", "Peptide.Seq", @hqc;
		print QC "$hqcj\n";
		print QC1 "$hqcj\n";
		print QC2 "$hqcj\n";
	}else{
		my @data = split /\t/;
		my $pepseq = $data[6];
		if ($peptype{$pepseq} ne "Contam") {
			for my $i (10..$#head) {
				$peptideq{$pepseq}{$head[$i]} += $data[$i];
			}
		}
	}
}
for my $pepseq (sort keys %peptideq) {
	my @dataall; my @datasample; my @databiorep; my @datatechrep; my @datapool; my @dataqc;
	for my $i (10..$#head) {
		if (($peptideq{$pepseq}{$head[$i]} eq "") or ($peptideq{$pepseq}{$head[$i]} == 0)) {
			$peptideq{$pepseq}{$head[$i]} = "NA";
		}
	}
	my $all_notNA = 0;
	for my $i (@alli) {
		push @dataall, $peptideq{$pepseq}{$head[$i]};
		if ($peptideq{$pepseq}{$head[$i]} ne "NA") {
			$all_notNA ++;
		}
	}
	my $sample_notNA = 0;
	for my $i (@samplei) {
		push @datasample, $peptideq{$pepseq}{$head[$i]};
		if ($peptideq{$pepseq}{$head[$i]} ne "NA") {
			$sample_notNA ++;
		}
	}
	my $biorep_notNA = 0;
	for my $i (@biorepi) {
		push @databiorep, $peptideq{$pepseq}{$head[$i]};
		if ($peptideq{$pepseq}{$head[$i]} ne "NA") {
			$biorep_notNA ++;
		}
	}
	my $techrep_notNA = 0;
	for my $i (@techrepi) {
		push @datatechrep, $peptideq{$pepseq}{$head[$i]};
		if ($peptideq{$pepseq}{$head[$i]} ne "NA") {
			$techrep_notNA ++;
		}
	}
	my $pool_notNA = 0;
	for my $i (@pooli) {
		push @datapool, $peptideq{$pepseq}{$head[$i]};
		if ($peptideq{$pepseq}{$head[$i]} ne "NA") {
			$pool_notNA ++;
		}
	}
	my $qc_notNA = 0;
	for my $i (@qci) {
		push @dataqc, $peptideq{$pepseq}{$head[$i]};
		if ($peptideq{$pepseq}{$head[$i]} ne "NA") {
			$qc_notNA ++;
		}
	}
	if ($all_notNA != 0) {
		my $dataallj = join "\t", @dataall;
		print ALL "$pepseq\t$dataallj\n";
		if ($peptype{$pepseq} eq "Human_unique") {
			print ALL1 "$pepseq\t$dataallj\n";
		}
		if ($peptype{$pepseq} eq "Micro_unique") {
			print ALL2 "$pepseq\t$dataallj\n";
		}
	}
	if ($sample_notNA != 0) {
		my $datasamplej = join "\t", @datasample;
		print OUT "$pepseq\t$datasamplej\n";
		if ($peptype{$pepseq} eq "Human_unique") {
			print OUT1 "$pepseq\t$datasamplej\n";
		}
		if ($peptype{$pepseq} eq "Micro_unique") {
			print OUT2 "$pepseq\t$datasamplej\n";
		}
	}
	if ($biorep_notNA != 0) {
		my $databiorepj = join "\t", @databiorep;
		print BREP "$pepseq\t$databiorepj\n";
		if ($peptype{$pepseq} eq "Human_unique") {
			print BREP1 "$pepseq\t$databiorepj\n";
		}
		if ($peptype{$pepseq} eq "Micro_unique") {
			print BREP2 "$pepseq\t$databiorepj\n";
		}
	}
	if ($techrep_notNA != 0) {
		my $datatechrepj = join "\t", @datatechrep;
		print TREP"$pepseq\t$datatechrepj\n";
		if ($peptype{$pepseq} eq "Human_unique") {
			print TREP1 "$pepseq\t$datatechrepj\n";
		}
		if ($peptype{$pepseq} eq "Micro_unique") {
			print TREP2 "$pepseq\t$datatechrepj\n";
		}	
	}
	if ($pool_notNA != 0) {
		my $datapoolj = join "\t", @datapool;
		print POOL "$pepseq\t$datapoolj\n";
		if ($peptype{$pepseq} eq "Human_unique") {
			print POOL1 "$pepseq\t$datapoolj\n";
		}
		if ($peptype{$pepseq} eq "Micro_unique") {
			print POOL2 "$pepseq\t$datapoolj\n";
		}
	}
	if ($qc_notNA != 0) {
		my $dataqcj = join "\t", @dataqc;
		print QC "$pepseq\t$dataqcj\n";
		if ($peptype{$pepseq} eq "Human_unique") {
			print QC1 "$pepseq\t$dataqcj\n";
		}
		if ($peptype{$pepseq} eq "Micro_unique") {
			print QC2 "$pepseq\t$dataqcj\n";
		}
	}
}
