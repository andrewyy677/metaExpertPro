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


open (PRO, "<$profile") or die $!;
my $humanU = 0; my $microU = 0; my $contamU = 0; my $HMshared = 0; my $HCshared = 0; my $MCshared = 0; my @head; my $line = 0; my $proi;
my %protype; my %protype_sta;
while (<PRO>) {
	chomp; s/\r//g;
	$line ++;
	if ($line == 1) {
		@head = split /\t/;
		for my $i (0..$#head) {
			if ($head[$i] eq "Protein.Group") {
				$proi = $i;
			}
		}
	}else{
		my @data = split /\t/;
		my $prosp = $data[$proi];
		if (! ($prosp =~ /\;/)) {
			my $humanf = 0;
			my $microf = 0;
			my $contamf = 0;
			if ($prosp =~ /Human/i) {
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
}
open (SUM, ">$workdir/00.rawdata/02.0.pg.classify.error") or die $!;
print SUM "HumanUnique\t$humanU\nMicroUnique\t$microU\nContamUnique\t$contamU\nMHShared\t$HMshared\nHCshared\t$HCshared\nMCshared\t$MCshared\n";
my @type = qw /human micro contam/;
open (OUT, ">$workdir/00.rawdata/$project\_diann_$database\_protein_classify.txt") or die $!;
print OUT "Protein.Group\tHuman\tMicro\tContam\n";
for my $k (sort keys %protype) {
	my @p;
	for my $type (@type) {
		push @p, $protype{$k}{$type};
	}
	my $pj = join "\t", @p;
	print OUT "$k\t$pj\n";
}