use strict;
my %hash;
while (<>) {
	chomp; s/\r//g;
	my @data = split /\,/;
	my $pep = $data[0];
	my $procomb = join "\,", @data[1..$#data];
	my @procomb = split /\;/, $procomb;
	for my $procomb (@procomb) {
		$hash{$procomb} ++;
	}
}
my $count = keys %hash;
print "PGnum\t$count\n";
close;