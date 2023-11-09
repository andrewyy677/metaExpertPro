use strict;
my ($workdir, $database, $help);
use Getopt::Long;
GetOptions('database|db=s'		=>	\$database,
			'workdir|wd=s'	=>	\$workdir,
			'help|h!'		=>	\$help,);
if ($help==1) {
	open HELP, "<$0";
	while (<HELP>) {	print "$_" if (/^##/);	}
	close HELP;	exit(0);
}

open (KEGG, "<$workdir/06.kegg.run/00.lib/user.out.top") or die $!;
open (OUT1, ">$workdir/06.kegg.run/00.lib/$database\_kegg_progroup.txt") or die $!;
print OUT1 "ProteinGroup\tKEGGNumber\tSecondOrganisms\tThirdOrganisms\tGenusNCBI\tKEGGGene\tKEGGScore\n";
my %kno; my %k2orga; my %k3orga; my %kgenus; my %kgene; my %kscore;
while (<KEGG>) {
	chomp; s/\r//g;
	my @kdata = split /\t/;
	if ($kdata[-1] >= 60) {
		my $kpro = $kdata[0];
		if ($kpro =~ /^user\:(.*)/) {
			$kpro = $1;
		}
		$kno{$kpro} = $kdata[1];
		$k2orga{$kpro} = $kdata[2];
		$k3orga{$kpro} = $kdata[3];
		$kgenus{$kpro} = $kdata[4];
		$kgene{$kpro} = $kdata[5];
		$kscore{$kpro} = $kdata[6];
		my $out1p = join "\t", $kpro, @kdata[1..$#kdata];
		print OUT1 "$out1p\n";
	}
}
