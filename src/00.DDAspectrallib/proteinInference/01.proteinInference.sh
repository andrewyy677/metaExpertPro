#!/bin/bash

########## set dir, parameters and logfile

workdir=$1/Results/00.DDAspectrallib/proteinInference
cycle3dir=$1/Results/00.DDAspectrallib/03.cycle3
srcdir=$1/src/00.DDAspectrallib/proteinInference
analysis_type=$2
dda_threads=$3
mylog=$4

echo "$mylog"
mydate=`date +%Y%m%d`
echo "[`date`]: Start $analysis_type proteinprophet ..." >> $mylog


## step1 dir, inputfiles and scripts
s1_1dir=$workdir/s1_fasta2pep
s1_inputdir=$s1_1dir/input
s1_outputdir=$s1_1dir/output
s1_scriptsdir=$srcdir/s1_fasta2pep
mkdir -p $s1_inputdir $s1_outputdir

fasta=`ls $cycle3dir/*.fasta`
lib=`ls $cycle3dir/library.tsv`
pep=`ls $cycle3dir/peptide.tsv`
cp $fasta $s1_inputdir
cp $lib $s1_inputdir
cp $pep $s1_inputdir

fasta_ori=`ls $s1_inputdir/*.fasta`
lib_ori=`ls $s1_inputdir/library.tsv`
pep_ori=`ls $s1_inputdir/peptide.tsv`

echo "my s1_inputdir: $s1_inputdir" >> $mylog && \
echo "my s1_outputdir: $s1_outputdir" >> $mylog && \
echo "my s1_scriptsdir: $s1_scriptsdir" >> $mylog && \
echo "my s1_1dir: $s1_1dir" >> $mylog && \

echo "my original fasta file: $fasta_ori" >> $mylog && \
echo "my original library: $lib_ori" >> $mylog && \
echo "my original peptide.tsv file: $pep_ori" >> $mylog && \


## step2 dir, inputfiles and scripts
s2dir=$workdir/s2_inference
s2_inputdir=$s2dir/input
s2_outputdir=$s2dir/output
s2_scriptsdir=$srcdir/s2_inference
mkdir -p $s2_inputdir $s2_outputdir

echo "my date yyyymmdd: $mydate\n" >> $mylog && \

##step1
echo "[`date`]: step1 generate strB fasta, lib, pep.seq and ori fasta, pep.seq in ori library..." >> $mylog && \
perl $s1_scriptsdir/strB_ori_fasta_pep_tsv.pl -f $fasta_ori -l $lib_ori -d $mydate -a $analysis_type -o $s1_outputdir >> $mylog 2>&1 && \
s1_strfasta=$s1_outputdir/$analysis_type\_irt_contam_ddafile_${mydate}_strB.fasta
s1_fasta=$s1_outputdir/$analysis_type\_irt_contam_ddafile_${mydate}.fasta
s1_strpep=$s1_outputdir/$analysis_type\_irt_contam_ddafile_${mydate}_pep_strB.seq
s1_pep=$s1_outputdir/$analysis_type\_irt_contam_ddafile_${mydate}_pep.seq
s1_strtsv=$s1_outputdir/$analysis_type\_irt_contam_ddafile_${mydate}_strB.tsv
echo "proteins num in lib" >> $mylog && \
grep ">" $s1_fasta | wc -l >> $mylog && \
echo "[`date`]: step1 done\n" >> $mylog && \

## step1_1
echo "[`date`]: step1_1 mapping peptides to fasta..." >> $mylog && \
perl $s1_scriptsdir/peplibtsv2pep2fasta.pl -pept $pep_ori -l $lib_ori -o $s1_outputdir && \
cp $s1_outputdir/pep2fasta.txt $s2_inputdir
wc -l $s2_inputdir/pep2fasta.txt >> $mylog && \
echo "[`date`]: step1_1 mapping done" >> $mylog && \

## step2
# step2.1
echo "[`date`]: step2.1 pep2fasta->pro2pep & sort pro & generate pro pepcount & error for check protein num..." >> $mylog && \
perl $s2_scriptsdir/s1_pep2pro_sort_rmsame_count.pl -s2 $s2dir >> $mylog 2>&1 && \
echo "check_pgnum in file pep2fasta_2pro_sort.txt" >> $mylog && \
wc -l $s2_outputdir/pep2fasta_2pro_sort.txt >> $mylog && \
echo "check_pepnum in pep2fasta_2pro_sort.txt" >> $mylog && \
perl $s2_scriptsdir/check-name-pep.pl $s2_outputdir/pep2fasta_2pro_sort.txt >> $mylog && \
echo "check_pgnum in file pep2fasta_2pro_sort_rmsame_count.txt" >> $mylog && \
wc -l $s2_outputdir/pep2fasta_2pro_sort_rmsame_count.txt >> $mylog && \
echo "[`date`]: step2.1 pep2fasta->pro2pep done\n" >> $mylog && \

# step2.2
echo "[`date`]: step2.2 trim and simplify the pep informatio to easier codes, downsize half..." >> $mylog && \
mkdir -p $s2_outputdir/trim/in $s2_outputdir/trim/out $s2_outputdir/trim/tmp && \
perl $s2_scriptsdir/s2_subset.trim.pl -i $s2_outputdir/pep2fasta_2pro_sort_rmsame_count.txt -o $s2_outputdir >> $mylog 2>&1 && \
echo "[`date`]: step2.2 trim and simplify the pep done\n" >> $mylog && \

# step2.3
echo "[`date`]: step2.3 rm redandunt pepcombs, deal with big num data with multi CPU..." >> $mylog && \
biggestnum=`cat $s2_outputdir/trim/combnumbiggest.txt` && \
perl $s2_scriptsdir/gen_s3_subset-v5-part2main.sh.pl -s2d $s2dir -wd $workdir -dth $dda_threads -srcd $s2_scriptsdir -n $biggestnum > $s2_scriptsdir/s3_subset-v5-part2main_1.sh && \
sh $s2_scriptsdir/s3_subset-v5-part2main_1.sh && \
echo "[`date`]: step2.3 rm redandunt pepcombs done\n" >> $mylog && \

# step2.4
echo "[`date`]: step2.4 rm redandunt pepcombs, deal 1-9.out..." >> $mylog && \
perl $s2_scriptsdir/s4_subset-v5-part3mainmain.pl -s2d $s2dir -srcd $s2_scriptsdir -n $biggestnum -log $mylog >> $mylog 2>&1 && \
mv $s2_outputdir/trim/out/1.out $s2_outputdir
echo "[`date`]: step2.4 rm redandunt pepcombs, deal 1-9.out done" >> $mylog && \

# step2.5
echo "[`date`]: step2.5 find and rm 5B & find lost pep and mark..." >> $mylog && \
cat $s2_outputdir/trim/out/*.out > $s2_outputdir/subset-v10_rm1.out && \
echo "check_pgnum in file subset-v10_rm1.out" >> $mylog && \
wc -l $s2_outputdir/subset-v10_rm1.out >> $mylog && \
echo "check_pepnum in file $s2_outputdir/subset-v10_rm1.out" >> $mylog && \
perl $s2_scriptsdir/check_index_pep.pl $s2_outputdir/subset-v10_rm1.out >> $mylog && \
perl $s2_scriptsdir/s5_subset-v10_rm5B_lostpep_mark.pl -s2d $s2dir -wd $workdir >> $mylog 2>&1 && \
echo "[`date`]: step2.5 find and rm 5B & find lost pep and mark done" >> $mylog && \

# step2.6
echo "[`date`]: step2.6 pick lost pep back; probility (sum) max > count (sum) max; generate library and fasta files..." >> $mylog && \
perl $s2_scriptsdir/s6_planC.pl -s2d $s2dir -wd $workdir -f $fasta_ori -l $lib_ori -d $mydate -a $analysis_type >> $mylog 2>&1 && \
echo "[`date`]: step2.6 pick lost pep back; probility (sum) max > count (sum) max; generate library and fasta files done" >> $mylog && \

# step2.7
echo "[`date`]: step2.7 statistic ..." >> $mylog && \
perl $s2_scriptsdir/s7_statis-protein_split_metag.pl -s2d $s2dir >> $mylog 2>&1 && \
echo "[`date`]: step2.7 statistic done" >> $mylog

