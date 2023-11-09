use strict;
my ($total_dir, $db_split, $dda_peplen_min, $dda_peplen_max, $dda_miss_cleav, $dda_precur_tole, $dda_frag_unit, $dda_frag_tole, $help);

use Getopt::Long;
GetOptions(	'total_dir|td=s'	=>	\$total_dir,
			'db_split|dbs=s'	=>	\$db_split,
			'dda_peplen_min|dpeplmin=s'		=>	\$dda_peplen_min,
			'dda_peplen_max|dpeplmax=s'		=>	\$dda_peplen_max,
			'dda_miss_cleav|dmissc=s'		=>	\$dda_miss_cleav,
			'dda_precur_tole|dpret=s'		=>	\$dda_precur_tole,
			'dda_frag_unit|dfrau=s'		=>	\$dda_frag_unit,
			'dda_frag_tole|dfrgt=s'		=>	\$dda_frag_tole,
			'help|h!'		=>	\$help,);
if (($dda_frag_unit ne "0") and ($dda_frag_unit ne "1")) {
	print STDERR "unrecognized dda_frag_unit (0 for Da, 1 for ppm)\n";
	exit(0);
}
if ($help==1) {
	open HELP, "<$0";
	while (<HELP>) {	print "$_" if (/^##/);	}
	close HELP;	exit(0);
}

print STDERR "fragpipe workflow: total_dir\t$total_dir\ndb_split\t$db_split\ndda_peplen_min\t$dda_peplen_min\ndda_peplen_max\t$dda_peplen_max\ndda_miss_cleav\t$dda_miss_cleav\ndda_precur_tole\t$dda_precur_tole\ndda_frag_unit(0 for Da, 1 for ppm)\t$dda_frag_unit\ndda_frag_tole\t$dda_frag_tole\n";

my $workflow = `ls $total_dir/src/00.DDAspectrallib/*.workflow`;
my $workflowanme = (split /\//, $workflow)[-1];

my $fastadecoy = `ls $total_dir/Results/00.DDAspectrallib/*.fasta.fas`;

open (OUT, ">$total_dir/Results/00.DDAspectrallib/$workflowanme") or die $!;
open (IN, "<$workflow") or die $!;
while (<IN>) {
	chomp; s/\r//g;
	my $new;
	if (/^database.db-path=/) {
		$new = "database.db-path=$fastadecoy";
	}elsif (/^msfragger.misc.slice-db=(\d+)/) {
		s/$1/$db_split/;
		$new = $_;
	}elsif (/^msfragger.digest_min_length=(\d+)/) {
		s/$1/$dda_peplen_min/;
		$new = $_;
	}elsif (/^msfragger.digest_max_length=(\d+)/) {
		s/$1/$dda_peplen_max/;
		$new = $_;
	}elsif (/^msfragger.allowed_missed_cleavage_1=(\d+)/) {
		s/$1/$dda_miss_cleav/;
		$new = $_;
	}elsif (/^msfragger.allowed_missed_cleavage_2=(\d+)/) {
		s/$1/$dda_miss_cleav/;
		$new = $_;
	}elsif (/^msfragger.precursor_true_tolerance=(\d+)/) {
		s/$1/$dda_precur_tole/;
		$new = $_;
	}elsif (/^msfragger.fragment_mass_tolerance=(\d+)/) {
		s/$1/$dda_frag_tole/;
		$new = $_;
	}elsif (/^msfragger.fragment_mass_units=(\d+)/) {
		s/$1/$dda_frag_unit/;
		$new = $_;
	}else{
		$new = $_;
	}
	print OUT "$new\n";
}
