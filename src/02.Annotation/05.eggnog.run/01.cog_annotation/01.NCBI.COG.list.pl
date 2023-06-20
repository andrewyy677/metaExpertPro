use strict;
use utf8;
open (NCBI1, "<cog-20.def.tab") or die $!;
my %ncogcat; my %ncogdes;
while (<NCBI1>) {
	chomp; s/\r//g;
	my @data = split /\t/;
	$ncogcat{$data[0]} = $data[1];
	$ncogdes{$data[0]} = $data[2];
}
open (NCBI2, "<ar14.arCOGdef19.tab") or die $!;
while (<NCBI2>) {
	chomp; s/\r//g;
	my @data = split /\t/;
	$ncogcat{$data[0]} = $data[1];
	$ncogdes{$data[0]} = $data[3];
}
open (NCBI3, "<kog") or die $!;
while (<NCBI3>) {
	chomp; s/\r//g;
	if (/^\[(.*)\]\s+([A-Z]+\d+)\s+(.*)/) {
		$ncogcat{$2} = $1;
		$ncogdes{$2} = $3;
	}
}
open (NCBI4, "<fun-20.tab") or die $!;
my %ncogcatdes;
while (<NCBI4>) {
	chomp; s/\r//g;
	my ($cogcat, $nouse, $cogcatdes) = split /\t/;
	$ncogcatdes{$cogcat} = $cogcatdes;
}
open (OUT, ">01.NCBI.COG.list.txt") or die $!;
print OUT "COGnum\tNCBICOGcat\tNCBICOGdes\tNCBICOGcatdes\n";
for my $k (sort keys %ncogcat) {
	print OUT "$k\t$ncogcat{$k}\t$ncogdes{$k}\t$ncogcatdes{$ncogcat{$k}}\n";
}