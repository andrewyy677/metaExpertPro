#!/bin/bash

OPTIONS=hvl:f:

PARSED_OPTIONS=$(getopt -n "$0" -o $OPTIONS --long help,version,total_dir:,project_name:,dda_threads:,dda_cycle1_RAM:,dda_cycle2_RAM:,dda_cycle3_RAM:,dda_peplen_min:,dda_peplen_max:,dda_miss_cleav:,dda_precur_tole:,dda_frag_unit:,dda_frag_tole:,dia_threads:,dia_miss_cleav:,dia_precur_tole:,dia_frag_tole: -- "$@")

if [ $? -ne 0 ]; then
echo "Parameter parsing error"
exit 1
fi

eval set -- "$PARSED_OPTIONS"

# default
total_dir="/metaEx"
project_name="my_project"
dda_threads=20
dda_cycle1_RAM=48G
dda_cycle2_RAM=48G
dda_cycle3_RAM=128G

dda_peplen_min=7
dda_peplen_max=50
dda_miss_cleav=2
dda_precur_tole=20
dda_frag_unit=1
dda_frag_tole=20

dia_threads=20
dia_miss_cleav=1
dia_precur_tole=10
dia_frag_tole=10

while true; do
case "$1" in
-h|--help)
echo "Usage:"
echo "-h, --help           show usage messages"
echo "-v, --version        show version"
echo "-d, --total_dir <value>   Project total directory, default: /metaEx"
echo "-p, --project_name <value>   Project name, default: my_project"
echo "-e, --dda_threads <value>   DDA-MS run threads, default: 20"
echo "-l, --dda_cycle1_RAM <value>   DDA-MS run cycle1 max RAM, default: 48G"
echo "-m, --dda_cycle2_RAM <value>   DDA-MS run cycle2 max RAM, default: 48G"
echo "-n, --dda_cycle3_RAM <value>   DDA-MS run cycle3 max RAM, default: 128G"
echo "-f, --dda_peplen_min <value>   DDA-MS run peptide min length, default: 7"
echo "-g, --dda_peplen_max <value>   DDA-MS run peptide max length, default: 50"
echo "-c, --dda_miss_cleav <value>   DDA-MS run allowed missed cleavage, default: 2"
echo "-i, --dda_precur_tole <value>   DDA-MS run precursor mass tolerance (unit ppm), default: 20"
echo "-j, --dda_frag_unit <value>   DDA-MS run fragment mass tolerance units (0 for Da, 1 for ppm), default: 1"
echo "-k, --dda_frag_tole <value>   DDA-MS run fragment mass tolerance, default: 20"

echo "-q, --dia_threads <value>   DIA-MS run threads, default: 20"
echo "-r, --dia_miss_cleav <value>   DIA-MS run allowed missed cleavage, default: 1"
echo "-s, --dia_precur_tole <value>   DIA-MS run precursor mass tolerance (unit ppm), default: 10"
echo "-t, --dia_frag_tole <value>   DIA-MS run fragment mass tolerance, default: 10"
exit 0
;;
-v|--version)
echo "version: 1.3"
shift
;;
-d|--total_dir)
total_dir=$2
echo "Project total directory: $total_dir"
shift 2
;;
-p|--project_name)
project_name=$2
echo "Project name: $project_name"
shift 2
;;
-e|--dda_threads)
dda_threads=$2
echo "DDA-MS run threads: $dda_threads"
shift 2
;;
-l|--dda_cycle1_RAM)
dda_cycle1_RAM=$2
echo "DDA-MS run cycle1 max RAM, default: 48G; $dda_cycle1_RAM"
shift 2
;;
-m|--dda_cycle2_RAM)
dda_cycle2_RAM=$2
echo "DDA-MS run cycle2 max RAM, default: 48G; $dda_cycle2_RAM"
shift 2
;;
-n|--dda_cycle3_RAM)
dda_cycle3_RAM=$2
echo "DDA-MS run cycle3 max RAM, default: 128G; $dda_cycle3_RAM"
shift 2
;;
-f|--dda_peplen_min)
dda_peplen_min=$2
echo "DDA-MS run peptide min length, default: 7; $dda_peplen_min"
shift 2
;;
-g|--dda_peplen_max)
dda_peplen_max=$2
echo "DDA-MS run peptide max length, default: 50; $dda_peplen_max"
shift 2
;;
-c|--dda_miss_cleav)
dda_miss_cleav=$2
echo "DDA-MS run allowed missed cleavage, default: 2; $dda_miss_cleav"
shift 2
;;
-i|--dda_precur_tole)
dda_precur_tole=$2
echo "DDA-MS run precursor mass tolerance (unit ppm), default: 20; $dda_precur_tole"
shift 2
;;
-j|--dda_frag_unit)
dda_frag_unit=$2
echo "DDA-MS run fragment mass tolerance units (0 for Da, 1 for ppm), default: 1; $dda_frag_unit"
shift 2
;;
-k|--dda_frag_tole)
dda_frag_tole=$2
echo "DDA-MS run fragment mass tolerance, default: 20; $dda_frag_tole"
shift 2
;;
-q|--dia_threads)
dia_threads=$2
echo "DIA-MS run threads, default: 20; $dia_threads"
shift 2
;;
-r|--dia_miss_cleav)
dia_miss_cleav=$2
echo "DIA-MS run allowed missed cleavage, default: 1; $dia_miss_cleav"
shift 2
;;
-s|--dia_precur_tole)
dia_precur_tole=$2
echo "DIA-MS run precursor mass tolerance (unit ppm), default: 10; $dia_precur_tole"
shift 2
;;
-t|--dia_frag_tole)
dia_frag_tole=$2
echo "DIA-MS run fragment mass tolerance, default: 10; $dia_frag_tole"
shift 2
;;
--)
shift
break
;;
*)
echo "unknown parameters"
exit 1
;;
esac
done

echo "unknown parameters:$@"

## dir
#total_dir=$1
#project_name=$2

## 00.DDAspectrallib dir
mkdir -p $total_dir/Results/00.DDAspectrallib/01.cycle1 $total_dir/Results/00.DDAspectrallib/02.cycle2 $total_dir/Results/00.DDAspectrallib/03.cycle3 $total_dir/Results/00.DDAspectrallib/proteinInference
fasta_dir_total=$total_dir/fasta
fasta_dir_micro=$fasta_dir_total/Microbiota
fasta_dir_human=$fasta_dir_total/HumanContamIrt
faspre=fasta_split
DDA_raw_dir=$total_dir/DDAraw
DDA_work_dir=$total_dir/Results/00.DDAspectrallib
DDA_command_dir=$total_dir/src/00.DDAspectrallib

if [ `find $DDA_raw_dir -name *.d | wc -l` -gt 0 ];then
rawtype="d"
rawnum=`find $DDA_raw_dir -name *.d | wc -l`
if [ $(($rawnum * 10)) -gt $dda_threads ];then
sleep_flag_1="yes"
sleep_time_1=$((560 / $dda_threads * 60))
fi
if [ $rawnum -gt $dda_threads ];then
sleep_flag_2="yes"
sleep_time_2=$((220 / $dda_threads * 60))
fi
fi

if [ `find $DDA_raw_dir -name *.mzML | wc -l` -gt 0 ];then
rawtype="mzML"
rawnum=`find $DDA_raw_dir -name *.mzML | wc -l`
if [ $(($rawnum * 10)) -gt $dda_threads ];then
sleep_flag_1="yes"
sleep_time_1=$((240 / $dda_threads * 60))
fi
if [ $rawnum -gt $dda_threads ];then
sleep_flag_2="yes"
sleep_time_2=$((120 / $dda_threads * 60))
fi
fi
echo $rawtype
echo $rawnum
echo $sleep_flag_1
echo $sleep_time_1
echo $sleep_flag_2
echo $sleep_time_2

mydate=`date`


## FragPipe dir
fragpipePath=$total_dir/software/fragpipe


## Micorbiota fasta split
cd $fasta_dir_micro
dirnow=`pwd`
echo $dirnow
fasta_ori=`ls *.fas`
perl $DDA_command_dir/cycle1/00.format_fasta.pl $fasta_ori
fasta_format=`ls *.fasta`
cd $fasta_dir_micro/fasta_split
ls | xargs -n 1 -I FILE sh -c 'mv FILE FILE.fasta'

touch $DDA_work_dir/00.DDAspectrallib.log.txt
#### generate parameter files
perl $DDA_command_dir/00.fragger.params.pl -dir $total_dir -dth $dda_threads -dpeplmin $dda_peplen_min -dpeplmax $dda_peplen_max -dmissc $dda_miss_cleav -dpret $dda_precur_tole -dfrau $dda_frag_unit -dfrgt $dda_frag_tole >> $DDA_work_dir/00.DDAspectrallib.log.txt 2>&1

#### 01.cycle1
## dir_generate and run FP
cd $DDA_work_dir/01.cycle1

for DDA_raw in `ls $DDA_raw_dir`
do
filename=${DDA_raw%.*}
for fasta in `ls $fasta_dir_micro/fasta_split`
do
i=$(($i+1))
fastapre=${fasta%.*}
filename_new=${filename}.${fastapre}.$i
mkdir $filename_new
cp $fasta_dir_micro/fasta_split/$fasta $DDA_work_dir/01.cycle1/$filename_new
cp -r $DDA_raw_dir/$DDA_raw $DDA_work_dir/01.cycle1/$filename_new
cp $DDA_command_dir/cycle1/GNHSF_fragpipe_MSFrag-Philo_fas87_new.sh $DDA_work_dir/01.cycle1/$filename_new
cp $DDA_command_dir/cycle1/fragger.params $DDA_work_dir/01.cycle1/$filename_new
cd $DDA_work_dir/01.cycle1/$filename_new
nohup sh $DDA_work_dir/01.cycle1/$filename_new/GNHSF_fragpipe_MSFrag-Philo_fas87_new.sh $fragpipePath $rawtype $dda_cycle1_RAM & >> $DDA_work_dir/00.DDAspectrallib.log.txt 2>&1 \

if [ "$sleep_flag_1" = "yes"  ];then
sleep $sleep_time_1
fi
cd $DDA_work_dir/01.cycle1
done
done
wait && sleep 60 && wait && \
echo "$mydate: 01.cycle1 fragpipe run DNOE\n" >> $DDA_work_dir/00.DDAspectrallib.log.txt && \


## cycle1 fasta generate
cd $DDA_work_dir/01.cycle1
for dir1 in `ls -d */`
do
cd $DDA_work_dir/01.cycle1/$dir1
dir1=${dir1%/*}
if [ -f "psm.tsv" ];then
mv $DDA_work_dir/01.cycle1/$dir1/psm.tsv $DDA_work_dir/01.cycle1/$dir1/${dir1}.psm.tsv
mv $DDA_work_dir/01.cycle1/$dir1/ion.tsv $DDA_work_dir/01.cycle1/$dir1/${dir1}.ion.tsv
mv $DDA_work_dir/01.cycle1/$dir1/peptide.tsv $DDA_work_dir/01.cycle1/$dir1/${dir1}.peptide.tsv
mv $DDA_work_dir/01.cycle1/$dir1/protein.tsv $DDA_work_dir/01.cycle1/$dir1/${dir1}.protein.tsv
mv $DDA_work_dir/01.cycle1/$dir1/protein.fas $DDA_work_dir/01.cycle1/$dir1/${dir1}.protein.fas
fi
done
mkdir $DDA_work_dir/01.cycle1/psm
cp $DDA_work_dir/01.cycle1/*/*.psm.tsv $DDA_work_dir/01.cycle1/psm

## generate fasta for cycle2
perl $DDA_command_dir/cycle1/03.classify_by_file.pl -wd $DDA_work_dir/01.cycle1 -fp $faspre -fas $fasta_dir_micro/$fasta_format >> $DDA_work_dir/00.DDAspectrallib.log.txt 2>&1 && \
echo "$mydate: 01.cycle1 generate fasta for cycle2 DNOE\n" >> $DDA_work_dir/00.DDAspectrallib.log.txt

##### 02.cycle2
## dir_generate
cd $DDA_work_dir/02.cycle2
for DDA_raw in `ls $DDA_raw_dir`
do
j=$(($j+1))
filename=${DDA_raw%.*}
filename_new=${filename}.$j
mkdir $filename_new
cp $DDA_work_dir/01.cycle1/${filename}.cycle1.fasta $DDA_work_dir/02.cycle2/$filename_new
cp -r $DDA_raw_dir/$DDA_raw $DDA_work_dir/02.cycle2/$filename_new
cp $DDA_command_dir/cycle2/GNHSF_fragpipe_MSFrag-Philo_fas87.sh $DDA_work_dir/02.cycle2/$filename_new
cp $DDA_command_dir/cycle2/fragger.params $DDA_work_dir/02.cycle2/$filename_new
cd $DDA_work_dir/02.cycle2/$filename_new
nohup sh $DDA_work_dir/02.cycle2/$filename_new/GNHSF_fragpipe_MSFrag-Philo_fas87.sh $fragpipePath $rawtype $dda_cycle2_RAM & >> $DDA_work_dir/00.DDAspectrallib.log.txt 2>&1 && \
if [ "$sleep_flag_2" = "yes"  ];then
sleep $sleep_time_2
fi

cd $DDA_work_dir/02.cycle2
done

wait && sleep 60 && wait && \
echo "$mydate: 02.cycle2 fragpipe run DNOE\n" >> $DDA_work_dir/00.DDAspectrallib.log.txt && \


## generate fasta for cycle3
perl $DDA_command_dir/cycle2/01.protein_total.pl -wd $DDA_work_dir/02.cycle2 -fas $fasta_dir_micro/$fasta_format >> $DDA_work_dir/00.DDAspectrallib.log.txt 2>&1 && \
echo "$mydate: 02.cycle2 generate fasta for cycle3 DNOE\n" >> $DDA_work_dir/00.DDAspectrallib.log.txt

##### 03.cycle3
## files
cd $DDA_work_dir/03.cycle3
cat $DDA_work_dir/02.cycle2/protein_cycle2.fasta $fasta_dir_human/*.fasta > $DDA_work_dir/03.cycle3/protein_cycle2_humanswiss_contam_irt.fasta
cp -r $DDA_raw_dir/* $DDA_work_dir/03.cycle3
cp $DDA_command_dir/cycle3/* $DDA_work_dir/03.cycle3
## run
cd $DDA_work_dir/03.cycle3
mkdir $DDA_work_dir/03.cycle3/medfile
touch $DDA_work_dir/03.cycle3/filter.log
sh GNHSF_fragpipe_MSFrag-Philo_fas87.sh $fragpipePath $rawtype $dda_threads $dda_cycle3_RAM >> $DDA_work_dir/00.DDAspectrallib.log.txt 2>&1

### proteinprophet
cd $DDA_work_dir/proteinInference
sh $DDA_command_dir/proteinInference/01.proteinInference.sh $total_dir $project_name $dda_threads $DDA_work_dir/00.DDAspectrallib.log.txt >> $DDA_work_dir/00.DDAspectrallib.log.txt 2>&1 && \
rm -rf $DDA_command_dir/proteinInference/s2_inference/s3_subset-v5-part2main_1.sh

######## 01.DIAquant
DIA_raw_dir=$total_dir/DIAraw
DIA_work_dir=$total_dir/Results/01.DIAquant
mkdir $DIA_work_dir
DIA_command_dir=$total_dir/src/01.DIAquant
DDA_spectral_lib_dir=$total_dir/Results/00.DDAspectrallib/proteinInference/s2_inference/output
cd $DDA_spectral_lib_dir
DDA_spectral_lib=`ls *spectral_library*.tsv`
if [ -f "${DDA_spectral_lib}.speclib" ]
then
DDA_spectral_lib_new=${DDA_spectral_lib}.speclib
else
DDA_spectral_lib_new=$DDA_spectral_lib
fi
DIA_out_name=${project_name}_DIAquant.tsv

touch $DIA_work_dir/01.DIAquant.log.txt
echo "$mydate: Start DIA-NN quantification\n" >> $DIA_work_dir/01.DIAquant.log.txt
$total_dir/software/usr/diann/1.8/diann-1.8 --dir $DIA_raw_dir --lib $DDA_spectral_lib_dir/$DDA_spectral_lib_new --threads $dia_threads --verbose 1 --out $DIA_work_dir/$DIA_out_name --qvalue 0.01 --matrices --var-mods 1 --var-mod UniMod:35,15.994915,M --mass-acc $dia_precur_tole --mass-acc-ms1 $dia_frag_tole --use-quant --no-prot-inf --smart-profiling --peak-center --no-ifs-removal >> $DIA_work_dir/01.DIAquant.log.txt 2>&1
echo "$mydate: DIA-NN quantification DONE\n" >> $DIA_work_dir/01.DIAquant.log.txt
