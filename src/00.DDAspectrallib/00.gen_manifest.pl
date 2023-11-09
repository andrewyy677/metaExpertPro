use strict;
use Getopt::Long;
my ($total_dir, $rawdata_MS_type, $rawdata_format_type, $help);
GetOptions(	'total_dir|td=s'	=>	\$total_dir,
			'rawdata_MS_type|rawmst=s'	=>	\$rawdata_MS_type,
			'rawdata_format_type|rawfort=s'	=>	\$rawdata_format_type,
			'help|h!'		=>	\$help,);
if ($help==1) {
	open HELP, "<$0";
	while (<HELP>) {	print "$_" if (/^##/);	}
	close HELP;	exit(0);
}

print STDERR "parameters: $total_dir\t$rawdata_MS_type\t$rawdata_format_type\n";

system("ls -d $total_dir/DDAraw/*.$rawdata_format_type > $total_dir/Results/00.DDAspectrallib/rawdata_file.txt");
open (RAW, "<$total_dir/Results/00.DDAspectrallib/rawdata_file.txt") or die $!;
open (OUT, ">$total_dir/Results/00.DDAspectrallib/manifest.nogroup.nobiorep.manifest") or die $!;
while (<RAW>) {
	chomp; s/\r//g;
	print OUT "$_\t\t\t$rawdata_MS_type\n";
}