use Getopt::Long;
GetOptions(	'workdir|wd=s'	=>	\$workdir,
			'fasta_ori|fas=s'		=>	\$fasta_ori,
			'help|h!'		=>	\$help,);
if ($help==1) {
	open HELP, "<$0";
	while (<HELP>) {	print "$_" if (/^##/);	}
	close HELP;	exit(0);
}

print STDERR "parameters: $workdir\t$fasta_ori\n";

system("ls $workdir/*/protein.tsv > $workdir/protein.tmp");

open (FAS, "<$fasta_ori") or die $!;
while (<FAS>) {
	chomp; s/\r//g;
	if (/^>(.*)/) {
		$fasname1 = $1;
		$fasname = (split /\s+/, $fasname1)[0];
	}else{
		$fashash{$fasname} .= $_;
	}
}
close FAS;
open (PSM, "<$workdir/protein.tmp") or die $!;
while (<PSM>) {
	chomp; s/\r//g;
	$file = $_;
	@head; $protein; $undispro;
	open (FILE, "<$file") or die $!;
	while (<FILE>) {
		chomp; s/\r//g;
		if (/^Group/) {
			@head = split /\t/;
			for $i (0..$#head) {
				if ($head[$i] eq "Protein") {
					$protein = $i;
				}
				if ($head[$i] eq "Indistinguishable Proteins") {
					$undispro = $i;
				}
			}
		}else{
			@data = split /\t/;
			$pro1 = $data[$protein];
			$pro2 = $data[$undispro];
			if ($pro1 =~ /\,/) {
				@pro1sp = split /\,/, $pro1;
				for $pro1sp (@pro1sp) {
					$pro1sp =~ s/\s+//g;
					if (! ($pro1sp =~ /^rev\_/)) {
						$prohash{$pro1sp} = $fashash{$pro1sp};
					}
				}
			}else{
				$pro1 =~ s/\s+//g;
				if (! ($pro1 =~ /^rev\_/)) {
					$prohash{$pro1} = $fashash{$pro1};
				}
			}
			if ($pro2 =~ /\,/) {
				@pro2sp = split /\,/, $pro2;
				for $pro2sp (@pro2sp) {
					$pro2sp =~ s/\s+//g;
					if (! ($pro2sp =~ /^rev\_/)) {
						$prohash{$pro2sp} = $fashash{$pro2sp};
					}
				}
			}else{
				$pro2 =~ s/\s+//g;
				if (! ($pro2 =~ /^rev\_/)) {
					$prohash{$pro2} = $fashash{$pro2};
				}
			}
		}
	}
	close FILE;
}
close PSM;
$count = keys %prohash;
print STDERR "$count\n";
open (OUT, ">$workdir/protein_cycle2.fasta") or die $!;
for $k (sort keys %prohash) {
	if ($k ne "") {
		print OUT ">$k\n$prohash{$k}\n";
	}
}
