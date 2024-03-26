use strict;

my ($database, $workdir, $help);
use Getopt::Long;
GetOptions( 'workdir|wd=s'	=>	\$workdir,
			'database|db=s'		=>	\$database,
			'help|h!'		=>	\$help,);
if ($help==1) {
	open HELP, "<$0";
	while (<HELP>) {	print "$_" if (/^##/);	}
	close HELP;	exit(0);
}


open (EGG, "<$workdir/05.eggnog.run/00.lib/$database\_irt_contam_ddafile_diamond.emapper.annotations") or die $!;
open (OUT1, ">$workdir/05.eggnog.run/00.lib/$database\_eggnog_progroup_annotations.txt") or die $!;
my @head; my %query_coghash; my %query_annotlvl; my %query_cog_cathash; my %query_des; my %query_prefer; my %query_go; my %query_kegg; my %query_keggpath;
my %cognumhash; my %query_cognum_hash; my %cog_cat_hash; 
my %cog_catsphash; my %gohash; my %kegghash;
my $queryi; my $eggnogi; my $annotlvli; my $cog_cati; my $descriptioni; my $preferi; my $goi; my $keggi; my $keggpathi;
while (<EGG>) {
	chomp; s/\r//g;
	if (/^\#\#/) {
		next;
	}elsif(/^\#query/) {
		@head = split /\t/;
		for my $i (0..$#head) {
			if ($head[$i] eq "query") {
				$queryi = $i;
			}
			if ($head[$i] eq "eggNOG_OGs") {
				$eggnogi = $i;
			}
			if ($head[$i] eq "max_annot_lvl") {
				$annotlvli = $i;
			}
			if ($head[$i] eq "COG_category") {
				$cog_cati = $i;
			}
			if ($head[$i] eq "Description") {
				$descriptioni = $i;
			}
			if ($head[$i] eq "Preferred_name") {
				$preferi = $i;
			}
			if ($head[$i] eq "GOs") {
				$goi = $i;
			}
			if ($head[$i] eq "KEGG_ko") {
				$keggi = $i;
			}
			if ($head[$i] eq "KEGG_Pathway") {
				$keggpathi = $i;
			}

		}
		print OUT1 "$_\n";
	}else{
		my @cognumarr;
		my @data = split /\t/;
		my $query = $data[$queryi];
		my $eggnog = $data[$eggnogi];
		my $annotlvl = $data[$annotlvli];
		my $cog_cat = $data[$cog_cati];
		my $description = $data[$descriptioni];
		my $prefer = $data[$preferi];
		my $go = $data[$goi];
		my $kegg = $data[$keggi];
		my $keggpath = $data[$keggpathi];
		$query_coghash{$query} = $eggnog;
		$query_annotlvl{$query} = $annotlvl;
		$query_cog_cathash{$query} = $cog_cat;
		$query_des{$query} = $description;
		$query_prefer{$query} = $prefer;
		$query_go{$query} = $go;
		$query_kegg{$query} = $kegg;
		$query_keggpath{$query} = $keggpath;
		my %cognum2rank;
		my %cogrank_numhash;
		my $cognum;
		my $rank;
		if ($eggnog =~ /\,/) {
			my @eggnogsp = split /\,/, $eggnog;
			for my $eggnogsp (@eggnogsp) {
				if ($eggnogsp =~ /(.*[CK]OG\d+)\@(\d+)/) {
					$cognum = $1;
					$rank = $2;
					if (! (exists $cognum2rank{$rank})) {
						$cognum2rank{$rank} = $cognum;
						$cogrank_numhash{$rank}{$cognum} ++;
					}else{
						if (! (exists $cogrank_numhash{$rank}{$cognum})) {
							$cognum2rank{$rank} .= "\,".$cognum;
							$cogrank_numhash{$rank}{$cognum} ++;
						}
					}
				}
			}
		}else{
			if ($eggnog =~ /(.*[CK]OG\d+)\@(\d+)/) {
				$cognum = $1;
				$rank = $2;
				if (! (exists $cognum2rank{$rank})) {
					$cognum2rank{$rank} = $cognum;
					$cogrank_numhash{$rank}{$cognum} ++;
				}else{
					if (! exists $cogrank_numhash{$rank}{$cognum}) {
						$cognum2rank{$rank} .= "\,".$cognum;
						$cogrank_numhash{$rank}{$cognum} ++;
					}
				}
			}
		}
		my $cognumleave = $cognum2rank{$rank};
		$cognumhash{$cognumleave} ++;
		$query_cognum_hash{$query} = $cognumleave;
		my $out1p = join "\t", @data[0..3], $cognumleave, @data[5..$#data];
		print OUT1 "$out1p\n";
		$cog_cat_hash{$cog_cat} ++;
		my @cog_catsp = split //, $cog_cat;
		for my $cog_catsp (@cog_catsp) {
			$cog_catsphash{$cog_catsp} ++;
		}
		my @gosp = split /\,/, $go;
		for my $gosp (@gosp) {
			$gohash{$gosp} ++;
		}
		my @keggsp = split /\,/, $kegg;
		for my $keggsp (@keggsp) {
			$kegghash{$keggsp} ++;
		}
	}
}

my %cognumsp;
for my $k (sort keys %cognumhash) {
	my @cognumsp = split /\,/, $k;
	for my $cognumsp (@cognumsp) {
		$cognumsp{$cognumsp} ++;
	}
}
my $cogcount = keys %cognumhash;
my $cogspcount = keys %cognumsp;
my $gocount = keys %gohash;
my $keggcount = keys %kegghash;
my $cog_cat_count = keys %cog_cat_hash;
my $cog_catsp_count = keys %cog_catsphash;
for my $k (sort keys %cog_cat_hash) {
	print STDERR "$k\n";
}
print STDERR "cog\tcog_sp\tcog_cat\tcog_cat_sp\tgo\tkegg\n$cogcount\t$cogspcount\t$cog_cat_count\t$cog_catsp_count\t$gocount\t$keggcount\n";
close EGG;
close MAT;
