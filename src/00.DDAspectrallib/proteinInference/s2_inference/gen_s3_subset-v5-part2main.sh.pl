use strict;

my ($workdir, $ddathreads, $s2dir, $srcdir, $help, $biggest);

use Getopt::Long;
GetOptions(	's2dir|s2d=s'	=>	\$s2dir,
			'workdir|wd=s'	=>	\$workdir,
			'ddathreads|dth'	=>	\$ddathreads,
			'srcdir|srcd=s'	=>	\$srcdir,
			'num|n=s'		=>	\$biggest,
			'help|h!'		=>	\$help,);
if ($help==1) {
	open HELP, "<$0";
	while (<HELP>) {	print "$_" if (/^##/);	}
	close HELP;	exit(0);
}
print STEDRR "parameters for 2.3_gen: $workdir\n$s2dir\n$ddathreads\n$srcdir\n$help\n$biggest\n";
print "find $s2dir/output/trim/in/ -maxdepth 1 -name \"*.in.txt\" \| \\\n";
print "xargs -n 1 -P $ddathreads -I PREFIX \\\n";
print "sh -c '\n";
print "pre=\$(basename PREFIX)\n";
print "prein=\${pre%%.*}\n";
print "if [ \${prein} -gt \"9\" ]\n";
print "then\n";
print "echo \"in files: PREFIX\"\n";
print "$srcdir/subset-v5-part2 PREFIX -s2d $s2dir -n $biggest 2>> $workdir/mylog.txt\n";
print "fi\n";
print "'\n";