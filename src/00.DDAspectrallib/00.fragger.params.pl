use strict;
my ($total_dir, $dda_threads, $dda_peplen_min, $dda_peplen_max, $dda_miss_cleav, $dda_precur_tole, $dda_frag_unit, $dda_frag_tole, $help);

use Getopt::Long;
GetOptions(	'total_dir|dir=s'	=>	\$total_dir,
			'dda_threads|dth=s'		=>	\$dda_threads,
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

print STDERR "fragpipe parameters: total_dir\t$total_dir\ndda_threads\t$dda_threads\ndda_peplen_min\t$dda_peplen_min\ndda_peplen_max\t$dda_peplen_max\ndda_miss_cleav\t$dda_miss_cleav\ndda_precur_tole\t$dda_precur_tole\ndda_frag_unit(0 for Da, 1 for ppm)\t$dda_frag_unit\ndda_frag_tole\t$dda_frag_tole\n";

open (OUT1, ">$total_dir/src/00.DDAspectrallib/cycle1/fragger.params") or die $!;
open (OUT2, ">$total_dir/src/00.DDAspectrallib/cycle2/fragger.params") or die $!;
open (OUT3, ">$total_dir/src/00.DDAspectrallib/cycle3/fragger.params") or die $!;
open (IN, "<$total_dir/src/00.DDAspectrallib/fragger.params") or die $!;
while (<IN>) {
	chomp; s/\r//g;
	my $new;
	if (/^num_threads = (\d+)/) {
		print OUT1 "$_\n";
		print OUT2 "$_\n";
		s/$1/$dda_threads/;
		print OUT3 "$_\n";
	}elsif (/^precursor_true_tolerance = (\d+)/) {
		s/$1/$dda_precur_tole/;
		$new = $_;
	}elsif (/^fragment_mass_tolerance = (\d+)/) {
		s/$1/$dda_frag_tole/;
		$new = $_;
	}elsif (/^fragment_mass_units = (\d+)/) {
		s/$1/$dda_frag_unit/;
		$new = $_;
	}elsif (/^allowed_missed_cleavage = (\d+)/) {
		s/$1/$dda_miss_cleav/;
		$new = $_;
	}elsif (/^digest_min_length = (\d+)/) {
		s/$1/$dda_peplen_min/;
		$new = $_;
	}elsif (/^digest_max_length = (\d+)/) {
		s/$1/$dda_peplen_max/;
		$new = $_;
	}else{
		$new = $_;
	}
	print OUT1 "$new\n";
	print OUT2 "$new\n";
	print OUT3 "$new\n";
}
