while (<>) {
	chomp; s/\r//g;
	if (/\;/) {
		@pep = split /\;/;
		for $pep (@pep) {
			$hash{$pep} ++;
		}
	}else{
		$hash{$_} ++;
	}
}
$count = keys %hash;
print "$count\n";