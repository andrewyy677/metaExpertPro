#!/bin/bash

OPTIONS=hvl:f:

PARSED_OPTIONS=$(getopt -n "$0" -o $OPTIONS --long help,version,total_dir:,project_name:,fragpipe_switch:,diann_switch:,fragpipe_path:,db_split:,dda_threads:,fasta_name:,dda_peplen_min:,dda_peplen_max:,dda_miss_cleav:,dda_precur_tole:,dda_frag_unit:,dda_frag_tole:,dia_threads:,dia_miss_cleav:,dia_precur_tole:,dia_frag_tole: -- "$@")

if [ $? -ne 0 ]; then
echo "Parameter parsing error"
exit 1
fi

eval set -- "$PARSED_OPTIONS"

# default
total_dir="/metaEx"
project_name="my_project"
fragpipe_switch="on"
diann_switch="on"
fragpipe_path=""
db_split=20
fasta_name=""

dda_threads=20
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
echo "-fps, --fragpipe_switch <value>   FragPipe switch, default: on"
echo "-dins, --diann_switch <value>   DIA-NN switch, default: on"
echo "-fp, --fragpipe_path <value>   Fragpipe path, default: no default"
echo "-dbs, --db_split <value>   Database split number, default: 20"
echo "-ddat, --dda_threads <value>   DDA-MS run threads, default: 20"
echo "-fas, --fasta_name <value>   DDA-MS run fasta name, default: no default"
echo "-f, --dda_peplen_min <value>   DDA-MS run peptide min length, default: 7"
echo "-g, --dda_peplen_max <value>   DDA-MS run peptide max length, default: 50"
echo "-c, --dda_miss_cleav <value>   DDA-MS run allowed missed cleavage, default: 2"
echo "-i, --dda_precur_tole <value>   DDA-MS run precursor mass tolerance (unit ppm), default: 20"
echo "-j, --dda_frag_unit <value>   DDA-MS run fragment mass tolerance units (0 for Da, 1 for ppm), default: 1"
echo "-k, --dda_frag_tole <value>   DDA-MS run fragment mass tolerance, default: 20"

echo "-diat, --dia_threads <value>   DIA-MS run threads, default: 20"
echo "-r, --dia_miss_cleav <value>   DIA-MS run allowed missed cleavage, default: 1"
echo "-s, --dia_precur_tole <value>   DIA-MS run precursor mass tolerance (unit ppm), default: 10"
echo "-t, --dia_frag_tole <value>   DIA-MS run fragment mass tolerance, default: 10"
exit 0
;;
-v|--version)
echo "version: 2.1"
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
-fps|--fragpipe_switch)
fragpipe_switch=$2
echo "Run FragPipe for DDA-MS based spectral library generation: $fragpipe_switch"
shift 2
;;
-fp|--fragpipe_path)
fragpipe_path=$2
echo "Fragpipe path: $fragpipe_path"
shift 2
;;
-dins|--diann_switch)
diann_switch=$2
echo "Run DIA-NN for DIA-MS based quantification: $diann_switch"
shift 2
;;
-dbs|--db_split)
db_split=$2
echo "The number of database split for FragPipe: $db_split"
shift 2
;;
-ddat|--dda_threads)
dda_threads=$2
echo "DDA-MS run threads, default: 20; $dda_threads"
shift 2
;;
-fas|--fasta_name)
fasta_name=$2
echo "DDA-MS run fasta name: $fasta_name"
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
-diat|--dia_threads)
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

## 00.DDAspectrallib dir
mkdir -p $total_dir/Results/00.DDAspectrallib
fasta_dir_total=$total_dir/fasta
DDA_raw_dir=$total_dir/DDAraw
DDA_work_dir=$total_dir/Results/00.DDAspectrallib
DDA_command_dir=$total_dir/src/00.DDAspectrallib
raw_ms_type=DDA

if [ `find $DDA_raw_dir -name *.d | wc -l` -gt 0 ];then
raw_format_type="d"
rawnum=`find $DDA_raw_dir -name *.d | wc -l`
fi

if [ `find $DDA_raw_dir -name *.mzML | wc -l` -gt 0 ];then
raw_format_type="mzML"
rawnum=`find $DDA_raw_dir -name *.mzML | wc -l`
fi

echo $rawtype
echo $rawnum
mydate=`date`

if [[ "$fragpipe_switch" == "on" ]]; then
echo "Start FragPipe-based spectral library generation."

## temp dir
mkdir $DDA_work_dir/tmp
# change temp folder
export JAVA_OPTS=-Djava.io.tmpdir=$DDA_work_dir/tmp
echo $JAVA_OPTS
XDG_CONFIG_HOME=$DDA_work_dir
export XDG_CONFIG_HOME


## FragPipe dir
echo $fragpipe_path

fragpipePath="$fragpipe_path/bin/fragpipe"
msfraggerPath="$fragpipe_path/software/MSFragger-3.8/MSFragger-3.8.jar"
philosopherPath="$fragpipe_path/software/philosopher-5.0.0/philosopher"
ionquantPath="$fragpipe_path/software/IonQuant-1.9.8/IonQuant-1.9.8.jar"
pythonPath=/opt/conda/bin/python
workflowPathOri=$DDA_command_dir/MPW_FP_splitDB_peptideprophet_20231025.workflow


## dir_generate and run FP
touch $DDA_work_dir/00.DDAspectrallib.log.txt
cd $DDA_work_dir
cp $fasta_dir_total/$fasta_name $DDA_work_dir
cp -r $DDA_raw_dir/* $DDA_work_dir

# add decoys to fasta
$philosopherPath workspace --clean --nocheck
$philosopherPath workspace --init --nocheck
$philosopherPath database --custom *.fasta
$philosopherPath workspace --clean --nocheck

## generate manifest files ## nogroup.nobiorep
perl $DDA_command_dir/00.gen_manifest.pl -td $total_dir -rawmst $raw_ms_type -rawfort $raw_format_type >> $DDA_work_dir/00.DDAspectrallib.log.txt 2>&1 && \

#### generate workflow file
perl $DDA_command_dir/01.format.workflow.pl -td $total_dir -thr $dda_threads -dbs $db_split -dpeplmin $dda_peplen_min -dpeplmax $dda_peplen_max -dmissc $dda_miss_cleav -dpret $dda_precur_tole -dfrau $dda_frag_unit -dfrgt $dda_frag_tole >> $DDA_work_dir/00.DDAspectrallib.log.txt 2>&1 && \

$fragpipePath --headless --workflow $DDA_work_dir/MPW_FP_splitDB_peptideprophet_20231025.workflow --manifest $DDA_work_dir/manifest.nogroup.nobiorep.manifest --workdir $DDA_work_dir --config-msfragger $msfraggerPath --config-ionquant $ionquantPath --config-philosopher $philosopherPath --config-python $pythonPath >> $DDA_work_dir/00.DDAspectrallib.log.txt 2>&1 && \

rm -rf $DDA_work_dir/*.${rawtype}

## generate pep2pro file
perl $DDA_command_dir/02.library.pl -td $total_dir >> $DDA_work_dir/00.DDAspectrallib.log.txt 2>&1

else
echo "Skip FragPipe-based spectral library generation!"
fi


######## 01.DIAquant

if [[ "$diann_switch" == "on" ]]; then
echo "Start DIA-NN-based peptide and protein quantification."

DIA_raw_dir=$total_dir/DIAraw
DIA_work_dir=$total_dir/Results/01.DIAquant
mkdir $DIA_work_dir
DIA_command_dir=$total_dir/src/01.DIAquant

DDA_spectral_lib_dir=$total_dir/Results/00.DDAspectrallib
cd $DDA_spectral_lib_dir
DDA_spectral_lib=`ls library.tsv`
if [ -f "${DDA_spectral_lib}.speclib" ]
then
DDA_spectral_lib_new=${DDA_spectral_lib}.speclib
else
DDA_spectral_lib_new=$DDA_spectral_lib
fi
DIA_out_name=${project_name}_DIAquant.tsv

touch $DIA_work_dir/01.DIAquant.log.txt
echo "$mydate: Start DIA-NN quantification\n" >> $DIA_work_dir/01.DIAquant.log.txt
$total_dir/software/usr/diann/1.8/diann-1.8 --dir $DIA_raw_dir --lib $DDA_spectral_lib_dir/$DDA_spectral_lib_new --threads $dia_threads --verbose 1 --out $DIA_work_dir/$DIA_out_name --qvalue 0.01 --matrices --var-mods 1 --var-mod UniMod:35,15.994915,M --mass-acc $dia_precur_tole --mass-acc-ms1 $dia_frag_tole --individual-mass-acc --individual-windows --no-prot-inf --smart-profiling --peak-center --no-ifs-removal >> $DIA_work_dir/01.DIAquant.log.txt 2>&1
echo "$mydate: DIA-NN quantification DONE\n" >> $DIA_work_dir/01.DIAquant.log.txt

else
echo "Skip DIA-NN-based peptide and protein quantification!"
fi