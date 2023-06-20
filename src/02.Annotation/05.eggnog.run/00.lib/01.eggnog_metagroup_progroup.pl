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


open (META, "<$workdir/05.eggnog.run/00.lib/Metagroup.txt") or die $!;
my %metahash;
while (<META>) {
	chomp; s/\r//g;
	my @meta = split /\,/;
	my $metaprog;
	if (@meta > 2) {
		$metaprog = join "\,", @meta[1..$#meta];
	}else{
		$metaprog = $meta[1];
	}
	my @metaprogarr;
	if ($metaprog =~ /\;/) {
		my @metaprogsp = split /\;/, $metaprog;
		for my $metaprogsp (@metaprogsp) {
			my $metaprogspname;
			if ($metaprogsp =~ /\s+/) {
				$metaprogspname = (split /\s+/, $metaprogsp)[0];
			}else{
				$metaprogspname = $metaprogsp;
			}
			#$metaproall{$metaprogspname} ++;
			push @metaprogarr, $metaprogspname;
		}
	}else{
		print STDERR "NOTmetagroup\,$_\n";
	}
	my $metaprogarrj = join "\;", @metaprogarr;
	$metahash{$meta[0]} = $metaprogarrj;
}

open (EGG, "<$workdir/05.eggnog.run/00.lib/$database\_irt_contam_ddafile_NEW_rmone_diamond.emapper.annotations") or die $!;
open (OUT1, ">$workdir/05.eggnog.run/00.lib/$database\_eggnog_progroup_annotations.txt") or die $!;
my @head; my %query_coghash; my %query_annotlvl; my %query_cog_cathash; my %query_des; my %query_prefer; my %query_go; my %query_kegg; my %query_keggpath;
my %cognumhash; my %query_cognum_hash; my %cog_cat_hash; 
my %cog_catsphash; my %gohash; my %kegghash;
while (<EGG>) {
	chomp; s/\r//g;
	if (/^\#\#/) {
		next;
	}elsif(/^\#query/) {
		@head = split /\t/;
		print OUT1 "$_\n";
	}else{
		my @cognumarr;
		my @data = split /\t/;
		my $query = $data[0];
		my $eggnog = $data[4];
		my $annotlvl = $data[5];
		my $cog_cat = $data[6];
		my $description = $data[7];
		my $prefer = $data[8];
		my $go = $data[9];
		my $kegg = $data[11];
		my $keggpath = $data[12];
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
open (OUT2, ">$workdir/05.eggnog.run/00.lib/$database\_eggnog_metagroup.txt") or die $!;
print OUT2 "Metagroup\tMetapro_name\tMetapro_num\tCOG_all_comb\tCOG_num_leave\tCOG_num_unique\tCOG_num_count\tCOG_cat\tAnnotlvl\tDescription\tPrefer_name\tKEGG\tKEGG_pathway\tGO\n";
my %metacognumclass;
for my $metahashk (sort keys %metahash) {
	my $metaprocount = 0;
	my %metacoghash; my @metacogarr;
	my @metacognumarr; my %metacognumhash;
	my @metacog_catarr; my %metacogcathash;
	my @mannotlvl; my @mdes; my @mprefer; my @mkegg; my @mkeggpath; my @mgo;
	my %mannotlvl; my %mdes; my %mprefer; my %mkegg; my %mkeggpath; my %mgo;
	my $matrpro = $metahashk;
	if ($matrpro =~ /Metagroup/) {
		my @metaprosp = split /\;/, $metahash{$matrpro};
		for my $metaprosp (@metaprosp) {
			$metaprocount ++;
			my $metacog = $query_coghash{$metaprosp};
			push @metacogarr, $metacog;
			$metacoghash{$metacog} ++;

			my $metacognum = $query_cognum_hash{$metaprosp};
			push @metacognumarr, $metacognum;
			$metacognumhash{$metacognum} ++;

			my $metacog_cat = $query_cog_cathash{$metaprosp};
			push @metacog_catarr, $metacog_cat;
			$metacogcathash{$metacog_cat} ++;

			my $mannotlvl = $query_annotlvl{$metaprosp};
			push @mannotlvl, $mannotlvl;
			$mannotlvl{$mannotlvl} ++;
	
			my $mdes = $query_des{$metaprosp};
			push @mdes, $mdes;
			$mdes{$mdes} ++;
			
			my $mprefer = $query_prefer{$metaprosp};
			push @mprefer, $mprefer;
			$mprefer{$mprefer} ++;

			my $mkegg = $query_kegg{$metaprosp};
			push @mkegg, $mkegg;
			$mkegg{$mkegg} ++;

			my $mkeggpath = $query_keggpath{$metaprosp};
			push @mkeggpath, $mkeggpath;
			$mkeggpath{$mkeggpath} ++;

			my $mgo = $query_go{$metaprosp};
			push @mgo, $mgo;
			$mgo{$mgo} ++;
		}
		my $metacognumhashcount = keys %metacognumhash;
		my $metacognumuniquej = join "\;", sort keys %metacognumhash;
		$metacognumclass{$metacognumhashcount} ++;

		my $mannotlvluniquej = join "\;", sort keys %mannotlvl;
		my $mdesuniquej = join "\;", sort keys %mdes;
		my $mpreferuniquej = join "\;", sort keys %mprefer;
		my $mkegguniquej = join "\;", sort keys %mkegg;
		my $mkeggpathuniquej = join "\;", sort keys %mkeggpath;
		my $mgouniquej = join "\;", sort keys %mgo;

		my $metacogarr = join "\;", @metacogarr;
		my $metacognumarr = join "\;", @metacognumarr;
		my $metacogcatarr = join "\;", @metacog_catarr;
		my $metacogp = join "\t", $matrpro, $metahash{$matrpro}, $metaprocount, $metacogarr, $metacognumarr, $metacognumuniquej, $metacognumhashcount, $metacogcatarr, $mannotlvluniquej, $mdesuniquej, $mpreferuniquej, $mkegguniquej, $mkeggpathuniquej, $mgouniquej;
		print OUT2 "$metacogp\n";
	}
}
for my $kcla (sort keys %metacognumclass) {
	print STDERR "$kcla\t$metacognumclass{$kcla}\n";
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
