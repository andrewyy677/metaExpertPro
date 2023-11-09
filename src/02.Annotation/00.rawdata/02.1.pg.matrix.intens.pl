use strict;
my ($workdir, $project, $database, $profile, $filesample, $help);

use Getopt::Long;
GetOptions(	'workdir|wd=s'		=>	\$workdir,
			'project|proj=s'		=>	\$project,
			'database|db=s'		=>	\$database,
			'profile|prof=s'		=>	\$profile,
			'filesample|fs=s'		=>	\$filesample,
			'help|h!'		=>	\$help,);
if ($help==1) {
	open HELP, "<$0";
	while (<HELP>) {	print "$_" if (/^##/);	}
	close HELP;	exit(0);
}
print STDERR "00.rawdata step2.1 \nparameters: $workdir\n$project\n$database\n$profile\n$filesample\n";

open (SAM, "<$filesample") or die $!;
my %batchID; my %sampleID; my %rep_lab; my %sam_lab;
my $line = 0;
my @heads; my $filenamei; my $batchidi; my $samidi; my $replabi; my $samlabi;
my $filetype;
while (<SAM>) {
	chomp; s/\r//g;
	$line ++;
	if ($line == 1) {
		@heads = split /\,/;
		for my $i (0..$#heads) {
			if ($heads[$i] eq "NameNew") {
				$filenamei = $i;
			}
			if ($heads[$i] eq "BatchID") {
				$batchidi = $i;
			}
			if ($heads[$i] eq "SampleID") {
				$samidi = $i;
			}
			if ($heads[$i] eq "Rep_label") {
				$replabi = $i;
			}
			if ($heads[$i] eq "Sample_label") {
				$samlabi = $i;
			}
		}
	}else{
		my @data = split /\,/;
		my $filename = $data[$filenamei];
		$filetype = (split /\./, $filename)[-1];
		$batchID{$filename} = $data[$batchidi];
		$sampleID{$filename} = $data[$samidi];
		$rep_lab{$filename} = $data[$replabi];
		$sam_lab{$filename} = $data[$samlabi];
	}
}

open (CLA, "<$workdir/00.rawdata/$project\_diann_$database\_protein_classify.txt") or die $!;
my $cline = 0;
my %protype;
while (<CLA>) {
	chomp; s/\r//g;
	$cline ++;
	if ($cline > 1) {
		my ($pro, $human, $micro, $contam) = split /\t/;
		if (($human == 1) and ($micro == 0) and ($contam == 0)) {
			$protype{$pro} = "Human_unique";
		}
		if (($human == 0) and ($micro == 1) and ($contam == 0)) {
			$protype{$pro} = "Micro_unique";
		}
		if ($contam == 1) {
			$protype{$pro} = "Contam";
		}
	}
}

open (MAT, "<$profile") or die $!;
open (BREP, ">$workdir/01.pg/$project\_diann_$database\_protein_biorep.tsv") or die $!;
open (TREP, ">$workdir/01.pg/$project\_diann_$database\_protein_techrep.tsv") or die $!;
open (POOL, ">$workdir/01.pg/$project\_diann_$database\_protein_pool.tsv") or die $!;
open (QC, ">$workdir/01.pg/$project\_diann_$database\_protein_qc.tsv") or die $!;
open (OUT, ">$workdir/01.pg/$project\_diann_$database\_protein_sample.tsv") or die $!;
open (ALL, ">$workdir/01.pg/$project\_diann_$database\_protein_all.tsv") or die $!;

open (BREP1, ">$workdir/01.pg/$project\_diann_$database\_humanprotein_biorep.tsv") or die $!;
open (TREP1, ">$workdir/01.pg/$project\_diann_$database\_humanprotein_techrep.tsv") or die $!;
open (POOL1, ">$workdir/01.pg/$project\_diann_$database\_humanprotein_pool.tsv") or die $!;
open (QC1, ">$workdir/01.pg/$project\_diann_$database\_humanprotein_qc.tsv") or die $!;
open (OUT1, ">$workdir/01.pg/$project\_diann_$database\_humanprotein_sample.tsv") or die $!;
open (ALL1, ">$workdir/01.pg/$project\_diann_$database\_humanprotein_all.tsv") or die $!;

open (BREP2, ">$workdir/01.pg/$project\_diann_$database\_microprotein_biorep.tsv") or die $!;
open (TREP2, ">$workdir/01.pg/$project\_diann_$database\_microprotein_techrep.tsv") or die $!;
open (POOL2, ">$workdir/01.pg/$project\_diann_$database\_microprotein_pool.tsv") or die $!;
open (QC2, ">$workdir/01.pg/$project\_diann_$database\_microprotein_qc.tsv") or die $!;
open (OUT2, ">$workdir/01.pg/$project\_diann_$database\_microprotein_sample.tsv") or die $!;
open (ALL2, ">$workdir/01.pg/$project\_diann_$database\_microprotein_all.tsv") or die $!;


my $line = 0; my @head;
my @hsample; my @hall; my @hbiorep; my @htechrep; my @hpool; my @hqc;
my @samplei; my @alli; my @biorepi; my @techrepi; my @pooli; my @qci;
my $sampstai; my $pgi;
while (<MAT>) {
	chomp; s/\r//g;
	$line ++;
	if ($line == 1) {
		@head = split /\t/;
		for my $i (0..$#head) {
			if ($head[$i] eq "Protein.Group") {
				$pgi = $i;
			}
			if ($head[$i] =~ /\.$filetype/) {
				$sampstai = $i;
				last;
			}
		}
		for my $i ($sampstai..$#head) {
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
		my $hallj = join "\t", "Protein.Group", @hall;
		print ALL "$hallj\n";
		print ALL1 "$hallj\n";
		print ALL2 "$hallj\n";
		my $hsamplej = join "\t", "Protein.Group", @hsample;
		print OUT "$hsamplej\n";
		print OUT1 "$hsamplej\n";
		print OUT2 "$hsamplej\n";
		my $hbiorepj = join "\t", "Protein.Group", @hbiorep;
		print BREP "$hbiorepj\n";
		print BREP1 "$hbiorepj\n";
		print BREP2 "$hbiorepj\n";
		my $htechrepj = join "\t", "Protein.Group", @htechrep;
		print TREP "$htechrepj\n";
		print TREP1 "$htechrepj\n";
		print TREP2 "$htechrepj\n";
		my $hpoolj = join "\t", "Protein.Group", @hpool;
		print POOL "$hpoolj\n";
		print POOL1 "$hpoolj\n";
		print POOL2 "$hpoolj\n";
		my $hqcj = join "\t", "Protein.Group", @hqc;
		print QC "$hqcj\n";
		print QC1 "$hqcj\n";
		print QC2 "$hqcj\n";
	}else{
		my @data = split /\t/;
		my $pg = $data[$pgi];
		my @dataall; my @datasample; my @databiorep; my @datatechrep; my @datapool; my @dataqc;
		if ((!($pg =~ /\;/)) and ($protype{$pg} ne "Contam")) {
			for my $i ($sampstai..$#head) {
				if ($data[$i] eq "") {
					$data[$i] = "NA";
				}
			}
			my $all_notNA = 0;
			for my $i (@alli) {
				push @dataall, $data[$i];
				if ($data[$i] ne "NA") {
					$all_notNA ++;
				}
			}
			my $sample_notNA = 0;
			for my $i (@samplei) {
				push @datasample, $data[$i];
				if ($data[$i] ne "NA") {
					$sample_notNA ++;
				}
			}
			my $biorep_notNA = 0;
			for my $i (@biorepi) {
				push @databiorep, $data[$i];
				if ($data[$i] ne "NA") {
					$biorep_notNA ++;
				}
			}
			my $techrep_notNA = 0;
			for my $i (@techrepi) {
				push @datatechrep, $data[$i];
				if ($data[$i] ne "NA") {
					$techrep_notNA ++;
				}
			}
			my $pool_notNA = 0;
			for my $i (@pooli) {
				push @datapool, $data[$i];
				if ($data[$i] ne "NA") {
					$pool_notNA ++;
				}
			}
			my $qc_notNA = 0;
			for my $i (@qci) {
				push @dataqc, $data[$i];
				if ($data[$i] ne "NA") {
					$qc_notNA ++;
				}
			}
			if ($all_notNA != 0) {
				my $dataallj = join "\t", @dataall;
				print ALL "$pg\t$dataallj\n";
				if ($protype{$pg} eq "Human_unique") {
					if (! ($pg =~ /^Metagroup/)) {
						print ALL1 "$pg\t$dataallj\n";
					}
				}
				if ($protype{$pg} eq "Micro_unique") {
					print ALL2 "$pg\t$dataallj\n";
				}
			}
			if ($sample_notNA != 0) {
				my $datasamplej = join "\t", @datasample;
				print OUT "$pg\t$datasamplej\n";
				if ($protype{$pg} eq "Human_unique") {
					if (! ($pg =~ /^Metagroup/)) {
						print OUT1 "$pg\t$datasamplej\n";
					}
				}
				if ($protype{$pg} eq "Micro_unique") {
					print OUT2 "$pg\t$datasamplej\n";
				}
			}
			if ($biorep_notNA != 0) {
				my $databiorepj = join "\t", @databiorep;
				print BREP "$pg\t$databiorepj\n";
				if ($protype{$pg} eq "Human_unique") {
					if (! ($pg =~ /^Metagroup/)) {
						print BREP1 "$pg\t$databiorepj\n";
					}
				}
				if ($protype{$pg} eq "Micro_unique") {
					print BREP2 "$pg\t$databiorepj\n";
				}
			}
			if ($techrep_notNA != 0) {
				my $datatechrepj = join "\t", @datatechrep;
				print TREP"$pg\t$datatechrepj\n";
				if ($protype{$pg} eq "Human_unique") {
					if (! ($pg =~ /^Metagroup/)) {
						print TREP1 "$pg\t$datatechrepj\n";
					}
				}
				if ($protype{$pg} eq "Micro_unique") {
					print TREP2 "$pg\t$datatechrepj\n";
				}
			}
			if ($pool_notNA != 0) {
				my $datapoolj = join "\t", @datapool;
				print POOL "$pg\t$datapoolj\n";
				if ($protype{$pg} eq "Human_unique") {
					if (! ($pg =~ /^Metagroup/)) {
						print POOL1 "$pg\t$datapoolj\n";
					}
				}
				if ($protype{$pg} eq "Micro_unique") {
					print POOL2 "$pg\t$datapoolj\n";
				}
			}
			if ($qc_notNA != 0) {
				my $dataqcj = join "\t", @dataqc;
				print QC "$pg\t$dataqcj\n";
				if ($protype{$pg} eq "Human_unique") {
					if (! ($pg =~ /^Metagroup/)) {
						print QC1 "$pg\t$dataqcj\n";
					}
				}
				if ($protype{$pg} eq "Micro_unique") {
					print QC2 "$pg\t$dataqcj\n";
				}
			}
		}
	}
}
