use strict;
my ($workdir, $project, $database, $profile, $help);

use Getopt::Long;
GetOptions(	'workdir|wd=s'		=>	\$workdir,
			'project|proj=s'		=>	\$project,
			'database|db=s'		=>	\$database,
			'profile|prof=s'		=>	\$profile,
			'help|h!'		=>	\$help,);
if ($help==1) {
	open HELP, "<$0";
	while (<HELP>) {	print "$_" if (/^##/);	}
	close HELP;	exit(0);
}
print STDERR "00.rawdata step2.0 \nparameters: $workdir\n$project\n$database\n$profile\n";


open (META, "<$workdir/00.rawdata/Metagroup.txt") or die $!;
my %metah; my %metac; my %metam;
my %metatype; my %metatype_sta;
my $humanU = 0; my $microU = 0; my $contamU = 0; my $HMshared = 0; my $HCshared = 0; my $MCshared = 0;
while (<META>) {
	chomp; s/\r//g;
	my @data = split /\,/;
	my $meta = $data[0];
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
	$metah{$meta} = $humanf;
	$metac{$meta} = $contamf;
	$metam{$meta} = $microf;
	if ($humanf > 0) {
		$metatype{$meta}{"human"} = 1;
	}else{
		$metatype{$meta}{"human"} = 0;
	}
	if ($contamf > 0) {
		$metatype{$meta}{"contam"} = 1;
	}else{
		$metatype{$meta}{"contam"} = 0;
	}
	if ($microf > 0) {
		$metatype{$meta}{"micro"} = 1;
	}else{
		$metatype{$meta}{"micro"} = 0;
	}
	if (($humanf > 0) and ($microf > 0)) {
		$metatype_sta{$meta} = "HMshared";
		$HMshared ++;
	}
	if (($humanf > 0) and ($contamf > 0)) {
		$metatype_sta{$meta} = "HCshared";
		$HCshared ++;
	}
	if (($microf > 0) and ($contamf > 0)) {
		$metatype_sta{$meta} = "MCshared";
		$MCshared ++;
	}
	if (($humanf > 0) and ($microf == 0) and ($contamf == 0)) {
		$metatype_sta{$meta} = "Human_unique";
		$humanU ++;
	}
	if (($humanf == 0) and ($microf > 0) and ($contamf == 0)) {
		$metatype_sta{$meta} = "Micro_unique";
		$microU ++;
	}
	if (($humanf == 0) and ($microf == 0) and ($contamf > 0)) {
		$metatype_sta{$meta} = "Contam_unique";
		$contamU ++;
	}
}
#open (METAOT1, ">$workdir/00.rawdata/02.0.pro.classify.error") or die $!;
#print METAOT1 "HumanUnique\t$humanU\nMicroUnique\t$microU\nContamUnique\t$contamU\nMHShared\t$HMshared\nHCshared\t$HCshared\nMCshared\t$MCshared\n";
my @type = qw /human micro contam/;
open (OUT, ">$workdir/00.rawdata/Metagroup_protein_classify.txt") or die $!;
print OUT "Metagroup\tHuman\tMicro\tContam\n";
for my $k (sort keys %metatype) {
	my @p;
	for my $type (@type) {
		push @p, $metatype{$k}{$type};
	}
	my $pj = join "\t", @p;
	print OUT "$k\t$pj\n";
}

open (PRO, "<$profile") or die $!;
my $humanU = 0; my $microU = 0; my $contamU = 0; my $HMshared = 0; my $HCshared = 0; my $MCshared = 0;
my %protype; my %protype_sta;
while (<PRO>) {
	chomp; s/\r//g;
	my @data = split /\t/;
	my $prosp = $data[0];
	if (! ($prosp =~ /\;/)) {
		my $humanf = 0;
		my $microf = 0;
		my $contamf = 0;
		if ($prosp =~ /^Metagroup/) {
			$humanf += $metah{$prosp};
			$contamf += $metac{$prosp};
			$microf += $metam{$prosp};
		}elsif ($prosp =~ /Human/i) {
			$humanf ++;
		}elsif ($prosp =~ /^MAX/) {
			$contamf ++;
		}else{
			$microf ++;
		}
		if ($humanf > 0) {
			$protype{$prosp}{"human"} = 1;
		}else{
			$protype{$prosp}{"human"} = 0;
		}
		if ($contamf > 0) {
			$protype{$prosp}{"contam"} = 1;
		}else{
			$protype{$prosp}{"contam"} = 0;
		}
		if ($microf > 0) {
			$protype{$prosp}{"micro"} = 1;
		}else{
			$protype{$prosp}{"micro"} = 0;
		}
		if (($humanf > 0) and ($microf > 0)) {
			$protype_sta{$prosp} = "HMshared";
			$HMshared ++;
		}
		if (($humanf > 0) and ($contamf > 0)) {
			$protype_sta{$prosp} = "HCshared";
			$HCshared ++;
		}
		if (($microf > 0) and ($contamf > 0)) {
			$protype_sta{$prosp} = "MCshared";
			$MCshared ++;
		}
		if (($humanf > 0) and ($microf == 0) and ($contamf == 0)) {
			$protype_sta{$prosp} = "Human_unique";
			$humanU ++;
		}
		if (($humanf == 0) and ($microf > 0) and ($contamf == 0)) {
			$protype_sta{$prosp} = "Micro_unique";
			$microU ++;
		}
		if (($humanf == 0) and ($microf == 0) and ($contamf > 0)) {
			$protype_sta{$prosp} = "Contam_unique";
			$contamU ++;
		}
	}
}
open (SUM, ">$workdir/00.rawdata/02.0.pg.classify.error") or die $!;
print SUM "HumanUnique\t$humanU\nMicroUnique\t$microU\nContamUnique\t$contamU\nMHShared\t$HMshared\nHCshared\t$HCshared\nMCshared\t$MCshared\n";
my @type = qw /human micro contam/;
open (OUT, ">$workdir/00.rawdata/$project\_diann1.8_$database\_protein_classify.txt") or die $!;
print OUT "Protein.Group\tHuman\tMicro\tContam\n";
for my $k (sort keys %protype) {
	my @p;
	for my $type (@type) {
		push @p, $protype{$k}{$type};
	}
	my $pj = join "\t", @p;
	print OUT "$k\t$pj\n";
}