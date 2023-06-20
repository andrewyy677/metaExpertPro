#!/usr/bin/perl
##
## trim and simplify the pep information to easier codes, downsize half; group by pep num and generate .in files
## Update: 20211112
## Usage: perl s2_subset.trim.pl
##

use strict;
#use Data::Dump qw (dump);

my ($help, $input, $outdir);

use Getopt::Long;
GetOptions(	'input|i=s'	=>	\$input,
			'out|o=s'		=>	\$outdir,
			'help|h!'		=>	\$help,);
if ($help==1) {
	open HELP, "<$0";
	while (<HELP>) {	print "$_" if (/^##/);	}
	close HELP;	exit(0);
}

my %unit; my %callr;
my $i;
open LIST, ">$outdir/trim/subset.trim.list" or die;
open TOTAL, "<$input" or die;
while (<TOTAL>) { s/\r//g; chomp;
	my ($combnum, $comb) = split /\t/;
	my @unit = split /\;/, $comb; # @unit = sort @unitcomb;
	for my $unit ( @unit ) {
		if (not exists $unit{$unit}) {
			$i ++; $unit{$unit} = "h${i}t"; print LIST join ("\t" => $unit, $unit{$unit}), "\n";
		}
	}
}
close TOTAL;

open TOTAL, "<$input" or die;
my $combnumbiggest;
while (<TOTAL>) { s/\r//g; chomp;
	my ($combnum, $comb) = split /\t/;
#	$combnum = 50 if $combnum > 50;
	if ($combnumbiggest < $combnum) {
		$combnumbiggest = $combnum
	}
	my @unit = split /\;/, $comb;
	my @unitnew; for my $unit ( @unit ) { push @unitnew, $unit{$unit}; }
	open FILE, ">>$outdir/trim/in/${combnum}.in.txt" or die;
	print FILE join ("\;", @unitnew), "\n";
	close FILE;
}
open (NUM, ">$outdir/trim/combnumbiggest.txt") or die $!;
print NUM "$combnumbiggest\n";
close TOTAL;
