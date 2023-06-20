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

open (META, "<$workdir/06.kegg.run/00.lib/Metagroup.txt") or die $!;
my %metahash;
while (<META>) {
	chomp; s/\r//g;
	my @meta = split /\,/;
	my $metaprog;
	if (@meta > 2) {
		$metaprog = join "\,", @meta[1..$#meta];
	}else{
		$metaprog = $meta[1];
	}
	my @metaprogarr;
	if ($metaprog =~ /\;/) {
		my @metaprogsp = split /\;/, $metaprog;
		for my $metaprogsp (@metaprogsp) {
			my $metaprogspname;
			if ($metaprogsp =~ /\s+/) {
				$metaprogspname = (split /\s+/, $metaprogsp)[0];
			}else{
				$metaprogspname = $metaprogsp;
			}
			#$metaproall{$metaprogspname} ++;
			push @metaprogarr, $metaprogspname;
		}
	}else{
		print STDERR "NOTmetagroup\,$_\n";
	}
	my $metaprogarrj = join "\;", @metaprogarr;
	$metahash{$meta[0]} = $metaprogarrj;
}

open (KEGG, "<$workdir/06.kegg.run/00.lib/user.out.top") or die $!;
open (OUT1, ">$workdir/06.kegg.run/00.lib/$database\_kegg_progroup.txt") or die $!;
print OUT1 "ProteinGroup\tKEGGNumber\tSecondOrganisms\tThirdOrganisms\tGenusNCBI\tKEGGGene\tKEGGScore\n";
my %kno; my %k2orga; my %k3orga; my %kgenus; my %kgene; my %kscore;
while (<KEGG>) {
	chomp; s/\r//g;
	my @kdata = split /\t/;
	if ($kdata[6] >= 60) {
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
open (OUT2, ">$workdir/06.kegg.run/00.lib/$database\_kegg_metagroup.txt") or die $!;
print OUT2 "Metagroup\tProteinGroup\tKEGGNumber\tSecondOrganisms\tThirdOrganisms\tGenusNCBI\tKEGGGene\tKEGGScore\n";
for my $k (sort keys %metahash) {
	my @mprog; my %mkno; my %mk2orga;
	my %mk3orga; my %mkgenus; my %mkgene; my @mkscore;
	my @metapro = split /\;/, $metahash{$k};
	for my $metapro (@metapro) {
		if ($kscore{$metapro} >= 60) {
			if ($metapro ne "") {
				push @mprog, $metapro;
			}
			if ($kno{$metapro} ne "") {
				$mkno{$kno{$metapro}} ++;
			}
			if ($k2orga{$metapro} ne "") {
				$mk2orga{$k2orga{$metapro}} ++;
			}
			if ($k3orga{$metapro} ne "") {
				$mk3orga{$k3orga{$metapro}} ++;
			}
			if ($kgenus{$metapro} ne "") {
				$mkgenus{$kgenus{$metapro}} ++;
			}
			if ($kgene{$metapro} ne "") {
				$mkgene{$kgene{$metapro}} ++;
			}
			if ($kscore{$metapro} ne "") {
				push @mkscore, $kscore{$metapro};
			}
		}
	}
	my $mprogp = join "\;", @mprog;
	my $mknop = join "\;", (sort keys %mkno);
	my $mk2orgap = join "\;", (sort keys %mk2orga);
	my $mk3orgap = join "\;", (sort keys %mk3orga);
	my $mkgenusp = join "\;", (sort keys %mkgenus);
	my $mkgenep = join "\;", (sort keys %mkgene);
	my $mkscorep = join "\;", @mkscore;
	#if ($mprogp ne "") {
		print OUT2 "$k\t$mprogp\t$mknop\t$mk2orgap\t$mk3orgap\t$mkgenusp\t$mkgenep\t$mkscorep\n";
	#}
}