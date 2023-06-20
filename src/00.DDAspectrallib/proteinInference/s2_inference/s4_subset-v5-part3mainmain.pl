
my ($s2dir, $srcdir, $mylog, $help, $biggest);

use Getopt::Long;
GetOptions(	's2dir|s2d=s'	=>	\$s2dir,
			'srcdir|srcd=s'	=>	\$srcdir,
			'mylog|log=s'	=>	\$mylog,
			'num|n=s'		=>	\$biggest,
			'help|h!'		=>	\$help,);
if ($help==1) {
	open HELP, "<$0";
	while (<HELP>) {	print "$_" if (/^##/);	}
	close HELP;	exit(0);
}
print STDERR "parameters for part3mainmain.pl: $s2dir\n$srcdir\n$mylog\n$biggest\n";
my $max = 9;
#my $xfilemax = sprintf "%02d", 20;

for my $i (reverse (0..$max)) {
	if ($i > 0) {
		system ("perl $srcdir/subset-v5-part3main.pl $i -s2d $s2dir -srcd $srcdir -n $biggest -log $mylog 2>> $mylog");
		my $end = "no";
		while ($end = "no") {
			system ("ps -aux > psaux.txt");
			open (PS, "<psaux.txt") or die $!;
			my $count = 0;
			while (<PS>) {
				chomp; s/\r//g;
				if (/subset-v5-part3sub/) {
					$count ++;
				}
			}
			if ($count == 0) {
				$end = "yes";
				last;
			}else{
				$end = "no";
			}
			print STDERR "$i\t$count\t$end\n";
		}
	}else{

		system ("cat $s2dir/output/trim/tmp/*.out > $s2dir/output/trim/out/1.out && rm -rf $s2dir/output/trim/tmp/*.out && rm -rf $s2dir/output/trim/x*");
	}
	
}

=cut

perl subset-v5-part3main.pl 9 && \
perl subset-v5-part3main.pl 8 && \
perl subset-v5-part3main.pl 7 && \
perl subset-v5-part3main.pl 6 && \
perl subset-v5-part3main.pl 5 && \
perl subset-v5-part3main.pl 4 && \
perl subset-v5-part3main.pl 3 && \
perl subset-v5-part3main.pl 2 && \
perl subset-v5-part3main.pl 1