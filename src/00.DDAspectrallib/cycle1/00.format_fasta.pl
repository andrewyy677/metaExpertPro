use strict;

my $file = $ARGV[0];
my $fileprex;
if ($file =~ /(.*)\.fas/) {
	$fileprex = $1;
}
my $name; my %fasta;
open (IN, "<$file") or die $!;
while (<IN>) {
	chomp; s/\r//g;
	if (/>(.*)/) {
		$name = $1;
	}else{
		$fasta{$name} .= $_;
	}
}
open (OUT, ">$fileprex\_MetaEx_format.fasta") or die $!;
my $fasta_num = 0;
for my $k (sort keys %fasta) {
	print OUT ">$k\n$fasta{$k}\n";
	$fasta_num += 2;
}
print STDERR "$fasta_num\n";
my $fasta_numsp = int($fasta_num / 10) + 1;
if ($fasta_numsp % 2 != 0) {
	$fasta_numsp += 1;
}
print STDERR "$fasta_numsp\n";

system("mkdir -p fasta_split");
system("split -l $fasta_numsp $fileprex\_MetaEx_format.fasta -d fasta_split/fasta_split_");
