use strict;
open (MAT, "<ko00001_20220118.keg") or die $!;
open (KDAT, ">kegg_database_format.txt") or die $!;
my $mline = 0; my $A; my $B; my $C; my $D; my %hash;
while (<MAT>) {
	chomp; s/\r//g;
	$mline ++;
	if (/^A(.*)/) {
		$A = $1;
	}
	if (/^B\s+(.*)/) {
		$B = $1;
	}
	if (/^C\s+(.*)/) {
		$C = $1;
	}
	if (/^D\s+(.*)/) {
		$D = $1;
	}
	my @Dsp = split /\s+/, $D;
	my $ko = $Dsp[0];
	my $kname = join " ", @Dsp[1..$#Dsp];
	my $anno = join "\t", $kname, $C, $B, $A;
	$hash{$ko}{$anno} ++;
	#print KDAT "$ko\t$kname\t$C\t$B\t$A\n";
}
close MAT;
print KDAT "KEGG num\tGene name\tC\tB\tA\n";
for my $k1 (sort keys %hash) {
	if ($k1 ne "") {
		for my $k2 (sort keys %{$hash{$k1}}) {
			print KDAT "$k1\t$k2\n";
		}
		
	}
	
}
=cut
open (COG, "<kegg_procount.txt") or die $!;
my $cline = 0;
while (<COG>) {
	chomp; s/\r//g;
	$cline ++;
	if ($cline == 1) {
		print "KEGG num\tGene name\tC\tB\tA\n";
	}else{
		my @cdata = split /\t/;
		my $ccat = $cdata[0];
		print "$ccat\t$hash{$ccat}\n";
	}
}
close COG;