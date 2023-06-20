
use Getopt::Long;
GetOptions(	'workdir|wd=s'	=>	\$workdir,
			'faspre|fp=s'	=>	\$faspre,
			'fasta_ori|fas=s'		=>	\$fasta_ori,
			'help|h!'		=>	\$help,);
if ($help==1) {
	open HELP, "<$0";
	while (<HELP>) {	print "$_" if (/^##/);	}
	close HELP;	exit(0);
}

print STDERR "parameters: $workdir\t$faspre\t$fasta_ori\n";

system("ls $workdir/psm > $workdir/psm.tmp");
open (NAME, "<$workdir/psm.tmp") or die $!;
while (<NAME>) {
	chomp; s/\r//g;
	$filename = $_;
	if ($filename =~ /(.*)\.($faspre\_\d+)\.\d+/) {
		$file = $1;
		$fasta = $2;
		$filehash{$file}{$filename} ++;
	}
}
close NAME;
$count1 = keys %filehash;
print STDERR "$count1\n";

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
#dump %fashash;
close FAS;
for $k1 (sort keys %filehash) {
	open (OUT, ">$workdir/$k1.cycle1.fasta") or die $!;
	for $k2 (sort keys %{$filehash{$k1}}) {
		open (PSM, "$workdir/psm/$k2") or die $!;
		@head; $protein; $mapprotein;
		while (<PSM>) {
			chomp; s/\r//g;
			if (/^Spectrum/) {
				@head = split /\t/;
				for $i (0..$#head) {
					if ($head[$i] eq "Protein") {
						$protein = $i;
					}
					if ($head[$i] eq "Mapped Proteins") {
						$mapprotein = $i;
					}
				}
			}else{
				@data = split /\t/;
				$pro1 = $data[$protein];
				$pro2 = $data[$mapprotein];
				if ($pro1 =~ /\,/) {
					@pro1sp = split /\,/, $pro1;
					for $pro1sp (@pro1sp) {
						$pro1sp =~ s/\s+//g;
						if (! ($pro1sp =~ /^rev\_/)) {
							
							$prohash{$k1}{$pro1sp} = $fashash{$pro1sp};
						}
					}
				}else{
					$pro1 =~ s/\s+//g;
					if (! ($pro1 =~ /^rev\_/)) {
						
						$prohash{$k1}{$pro1} = $fashash{$pro1};
					}
				}
				if ($pro2 =~ /\,/) {
					@pro2sp = split /\,/, $pro2;
					for $pro2sp (@pro2sp) {
						$pro2sp =~ s/\s+//g;
						if (! ($pro2sp =~ /^rev\_/)) {
							
							$prohash{$k1}{$pro2sp} = $fashash{$pro2sp};
						}
					}
				}else{
					$pro2 =~ s/\s+//g;
					if (! ($pro2 =~ /^rev\_/)) {
						
						$prohash{$k1}{$pro2} = $fashash{$pro2};
					}
				}
			}
		}
	}

	for $k3 (sort keys %{$prohash{$k1}}) {
		if ($k3 ne "") {
			print OUT ">$k3\n$prohash{$k1}{$k3}\n";
		}	
	}
	$count2 = keys %{$prohash{$k1}};
	print STDERR "$count2\n";
	close OUT;
}
