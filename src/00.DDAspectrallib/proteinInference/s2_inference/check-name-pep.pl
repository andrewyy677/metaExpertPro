while (<>) {
	chomp; s/\r//g;
	@data = split /\,/;
	if (@data > 2) {
		$end = $#data - 1;
		$pro = join "\,", @data[0..$end];
	}else{
		$pro = $data[0];
	}
	$pepcom = $data[-1];
	if ($pepcom =~ /\;/) {
		@pep = split /\;/, $pepcom;
		for $pep (@pep) {
			$pephash{$pep} ++;
		}
	}else{
		$pephash{$pepcom} ++;
	}
}
$count = keys %pephash;
print "$count\n";
close;