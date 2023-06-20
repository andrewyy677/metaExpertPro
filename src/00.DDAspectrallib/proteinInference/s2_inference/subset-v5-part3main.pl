use strict;
#use Data::Dump qw (dump);

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
print STDERR "parameters for part3main: $s2dir\n$srcdir\n$mylog\n$biggest\n";

my $combnumbiggest = $biggest;
my $combnum = $ARGV[0];


my $linenum;
open FILE, "<$s2dir/output/trim/in/${combnum}.in.txt";
while (<FILE>) { s/\r//g; chomp;
	$linenum ++;
}
print STDERR "$linenum\n";
close FILE;

# merge results in previous step and write to *.out file
my $combnumnext = $combnum + 1;
if (-e "$s2dir/output/trim/out/$combnumnext.out") { print STDERR "start file exists\n" } else { system ("cat $s2dir/output/trim/tmp/*.out > $s2dir/output/trim/out/$combnumnext.out && rm -rf $s2dir/output/trim/tmp/*.out"); }

#if ($linenum >= 1000) {
	my $newline = int($linenum/20);
	unlink "$s2dir/output/trim/subset-v5-part3sh.txt";
	open SH, ">>$s2dir/output/trim/subset-v5-part3sh.txt" or die;
	for my $i (0 .. 20) {
		my $ifile = sprintf "%02d", $i; unlink "$s2dir/output/trim/x$ifile";
		print SH "$srcdir/subset-v5-part3sub $combnum $s2dir/output/trim/x$ifile -s2d $s2dir -n $biggest 2>> $mylog &\n"; 
	}
	close SH;
	system ("split -l $newline $s2dir/output/trim/in/${combnum}.in.txt -d $s2dir/output/trim/x");
	system ("sh $s2dir/output/trim/subset-v5-part3sh.txt");
#} else {
#	system ("subset-v5-part3sub $combnum $combnum");
#}

