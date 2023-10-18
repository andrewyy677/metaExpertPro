#!/bin/bash
OPTIONS=hvl:f:

PARSED_OPTIONS=$(getopt -n "$0" -o $OPTIONS --long help,version,total_dir:,project_name:,sample_label:,database:,anno_threads:,unipept_switch:,eggnog_switch:,kegg_switch: -- "$@")

if [ $? -ne 0 ]; then
echo "Parameter parsing error"
exit 1
fi

eval set -- "$PARSED_OPTIONS"

# default
total_dir="/metaEx"
project_name="my_project"
sample_label="/metaEx/sampleLabel/${project_name}_sample_label.csv"
database="IGC_humanswiss"
anno_threads=20
unipept_switch=on
eggnog_switch=on
kegg_switch=on

while true; do
case "$1" in
-h|--help)
echo "Usage:"
echo "-h, --help           show usage messages"
echo "-v, --version        show version"
echo "-d, --total_dir <value>   Project total directory, default: /metaEx"
echo "-p, --project_name <value>   Project name, default: my_project"
echo "-l, --sample_label <value>   Sample label, default: /metaEx/sampleLabel/${project_name}_sample_label.csv"
echo "-b, --database <value>   Database name, default: IGC_humanswiss"
echo "-t, --anno_threads <value>   Annotation threads, default: 20"
echo "-u --unipept_switch <value>   Run Unipept for taxonomic annotation, default: on"
echo "-e --eggnog_switch <value>   Run eggnog for eggnog annotation, default: on"
echo "-k --kegg_switch <value>   Run kegg matrix generation, default: on"
exit 0
;;
-v|--version)
echo "version: 9.2"
shift
;;
-d|--total_dir)
total_dir=$2
echo "Project total directory, default: /metaEx; $total_dir"
shift 2
;;
-p|--project_name)
project_name=$2
echo "Project name, default: my_project; $project_name"
shift 2
;;
-l|--sample_label)
sample_label=$2
echo "Sample label, default: /metaEx/sampleLabel/${project_name}_sample_label.csv; $sample_label"
shift 2
;;
-b|--database)
database=$2
echo "Database name, default: IGC_humanswiss; $database"
shift 2
;;
-t|--anno_threads)
anno_threads=$2
echo "Annotation threads, default: 20; $anno_threads"
shift 2
;;
-u|--unipept_switch)
unipept_switch=$2
echo "Run Unipept for taxonomic annotation, default: on; $unipept_switch"
shift 2
;;
-e|--eggnog_switch)
eggnog_switch=$2
echo "Run eggnog for eggnog annotation, default: on; $eggnog_switch"
shift 2
;;
-k|--kegg_switch)
kegg_switch=$2
echo "Run kegg matrix generation, default: on; $kegg_switch"
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

#while getopts "d:p:s:b" var
#do
#   case "$var" in
#       d) total_dir=${OPTARG};;
#       p) project_name=${OPTARG};;
#       s) sample_label=${OPTARG};;
#       b) database=${OPTARG};;
#   esac
#done

## dir
#total_dir=$1
#project_name=$2
#sample_label=$total_dir/sampleLabel/$3
#database=$4

######## 02.Annotation
Anno_work_dir=$total_dir/Results/02.Annotation
mkdir $Anno_work_dir
touch $Anno_work_dir/02.Annotation.log.txt
echo "$mydate: Start Annotation\n" >> $Anno_work_dir/02.Annotation.log.txt

#### input from DIA-NN
DIA_work_dir=$total_dir/Results/01.DIAquant
input_pr_mat=${DIA_work_dir}/${project_name}_DIAquant.pr_matrix.tsv
input_pg_mat=${DIA_work_dir}/${project_name}_DIAquant.pg_matrix.tsv

#### input from spectralLib
DDA_spectral_lib_dir=$total_dir/Results/00.DDAspectrallib/proteinInference/s2_inference/output
input_metag=$DDA_spectral_lib_dir/Metagroup.txt
cd $DDA_spectral_lib_dir
input_fasta_name=`ls *.fasta`
input_fasta=$DDA_spectral_lib_dir/$input_fasta_name
input_pep2pro=$DDA_spectral_lib_dir/subset-v10-leave-pep2pro_rmone.txt
mydate=`date +%Y%m%d`

#### script dir
Anno_src_dir=$total_dir/src/02.Annotation

#### make dir
cd $Anno_work_dir
mkdir -p 00.rawdata 01.pg 02.pr 04.pep2taxon 05.eggnog.run 06.kegg.run 07.matrix
## 00.rawdata
cp $input_metag 00.rawdata

## 04.pep2taxon
cd 04.pep2taxon
mkdir 00.lib 01.matrix
cd 00.lib
mkdir 01.all.peptide 02.human.unique 03.microbiome.unique
cp $input_metag .
cp $input_pep2pro .
cd ../01.matrix
mkdir 01.add_unipept_info 02.taxon_matrix 03.taxon_short
cd 02.taxon_matrix
mkdir filter1 filter2 filter3 filter5 filter10 filter15 filter20
cd filter1
mkdir all sample techrep biorep qc pool
cd ../filter2
mkdir all sample techrep biorep qc pool
cd ../filter3
mkdir all sample techrep biorep qc pool
cd ../filter5
mkdir all sample techrep biorep qc pool
cd ../filter10
mkdir all sample techrep biorep qc pool
cd ../filter15
mkdir all sample techrep biorep qc pool
cd ../filter20
mkdir all sample techrep biorep qc pool

## 05.eggnog.run
cd $Anno_work_dir/05.eggnog.run
mkdir 00.lib
cp $input_metag 00.lib
cp $input_fasta 00.lib
mkdir 02.matrix

cd 02.matrix
mkdir COGmatrix_all humanprotein microprotein protein
cd protein
mkdir all sample techrep biorep qc pool COG_ori
cd ../humanprotein
mkdir all sample techrep biorep qc pool COG_ori
cd ../microprotein
mkdir all sample techrep biorep qc pool COG_ori

cd $Anno_work_dir/05.eggnog.run
mkdir 03.cogcat.matrix
cd $Anno_work_dir/05.eggnog.run/03.cogcat.matrix
mkdir COGcatmatrix_all humanprotein microprotein protein
cd protein
mkdir all sample techrep biorep qc pool COGcat_ori
cd ../humanprotein
mkdir all sample techrep biorep qc pool COGcat_ori
cd ../microprotein
mkdir all sample techrep biorep qc pool COGcat_ori

## 05.kegg.run
cd $Anno_work_dir/06.kegg.run
mkdir 00.lib
cp $input_metag 00.lib

mkdir 02.matrix
cd 02.matrix
mkdir KEGGmatrix_all humanprotein microprotein protein
cd protein
mkdir all sample techrep biorep qc pool KEGG_ori
cd ../humanprotein
mkdir all sample techrep biorep qc pool KEGG_ori
cd ../microprotein
mkdir all sample techrep biorep qc pool KEGG_ori

mkdir $Anno_work_dir/06.kegg.run/03.keggcat.matrix
cd $Anno_work_dir/06.kegg.run/03.keggcat.matrix
mkdir KEGGcatmatrix_all humanprotein microprotein protein
cd protein
mkdir all sample techrep biorep qc pool KEGGcat_ori
cd ../humanprotein
mkdir all sample techrep biorep qc pool KEGGcat_ori
cd ../microprotein
mkdir all sample techrep biorep qc pool KEGGcat_ori

############## pre run
###### 00.rawdata
## step 1.0 classify the metagroup
echo "[`date`]: workdir: 00.rawdata; step1 1.0 classify the metagroup ..." >> $Anno_work_dir/02.Annotation.log.txt
perl $Anno_src_dir/00.rawdata/02.0.metagroup.pro.classify.pl -wd $Anno_work_dir -proj $project_name -db $database -prof $input_pg_mat >> $Anno_work_dir/02.Annotation.log.txt 2>&1 && \
echo "[`date`]: step 1.0 done" >> $Anno_work_dir/02.Annotation.log.txt
## step 2.0 matrix peptide classify
echo "[`date`]: workdir: 00.rawdata; 2.0 peptide classify ..." >> $Anno_work_dir/02.Annotation.log.txt
perl $Anno_src_dir/00.rawdata/03.0.pr.classify.pl -wd $Anno_work_dir -proj $project_name -db $database -pepf $input_pr_mat >> $Anno_work_dir/02.Annotation.log.txt 2>&1 && \
echo "[`date`]: step 2.0 done" >> $Anno_work_dir/02.Annotation.log.txt

############ 04.pep2taxon lib peptide -> unipept -> taxon
## step 4.0 lib peptide classify
## workdir_now: $Anno_work_dir/04.pep2taxon/00.lib
echo "[`date`]: workdir: 04.pep2taxon; 4.0 lib peptide classify ..." >> $Anno_work_dir/02.Annotation.log.txt
perl $Anno_src_dir/04.pep2taxon/00.lib/01.lib.pep.classify.pl -db $database -wd $Anno_work_dir 2> $Anno_work_dir/04.pep2taxon/00.lib/01.lib.pep.classify.error
echo "[`date`]: workdir: 04.pep2taxon; 4.0 lib peptide classify DONE" >> $Anno_work_dir/02.Annotation.log.txt

## step 4.0.1 run unipept using microbiome unique peptides
## workdir_now: $Anno_work_dir/04.pep2taxon/00.lib/03.microbiome.unique

#echo "Run Unipept for taxonomic annotation? (yes/no): "
#read user_input_tax
#user_input_tax_lower=$(echo "$user_input_tax" | tr '[:upper:]' '[:lower:]')
if [[ "$unipept_switch" == "on" ]]; then
echo "[`date`]: workdir: 04.pep2taxon/00.lib/03.microbiome.unique; 4.0.1 run unipept using microbiome unique peptides ..." >> $Anno_work_dir/02.Annotation.log.txt
cd $Anno_src_dir/04.pep2taxon/00.lib/03.microbiome.unique
sh 02.unipept.run.format.sh $Anno_work_dir/04.pep2taxon/00.lib/03.microbiome.unique && \
echo "[`date`]: workdir: 04.pep2taxon/00.lib/03.microbiome.unique; 4.0.1 run unipept using microbiome unique peptides DONE" >> $Anno_work_dir/02.Annotation.log.txt

## step 4.0.2 filter peptides and generate new pept2lca.tsv file
echo "[`date`]: workdir: 04.pep2taxon/00.lib/03.microbiome.unique; 4.0.2 filter peptides and generate new pept2lca.tsv file ..." >> $Anno_work_dir/02.Annotation.log.txt
perl $Anno_src_dir/04.pep2taxon/00.lib/03.microbiome.unique/00.peptide.seq.filter.pl -db $database -wd $Anno_work_dir 2> $Anno_work_dir/04.pep2taxon/00.lib/03.microbiome.unique/00.peptide.seq.filter.error && \
echo "[`date`]: workdir: 04.pep2taxon/00.lib/03.microbiome.unique; 4.0.2 filter peptides and generate new pept2lca.tsv file DONE" >> $Anno_work_dir/02.Annotation.log.txt

## step 4.0.3 generate peptide2taxon csv file
echo "[`date`]: workdir: 04.pep2taxon/00.lib; 4.0.3 generate peptide2taxon csv file ..." >> $Anno_work_dir/02.Annotation.log.txt
perl $Anno_src_dir/04.pep2taxon/00.lib/01.pep2taxon.lib.pl -wd $Anno_work_dir -db $database >> $Anno_work_dir/02.Annotation.log.txt 2>&1 && \
echo "[`date`]: workdir: 04.pep2taxon/00.lib; 4.0.3 generate peptide2taxon csv file DONE" >> $Anno_work_dir/02.Annotation.log.txt

echo "[`date`]: workdir: 04.pep2taxon/00.lib; 4.0.3 generate taxonname pepcount file ..." >> $Anno_work_dir/02.Annotation.log.txt
perl $Anno_src_dir/04.pep2taxon/00.lib/02.taxonname_pepcount.pl -wd $Anno_work_dir -db $database >> $Anno_work_dir/02.Annotation.log.txt 2>&1 && \
echo "[`date`]: workdir: 04.pep2taxon/00.lib; 4.0.3 generate taxonname pepcount file DONE" >> $Anno_work_dir/02.Annotation.log.txt

elif [[ "$unipept_switch" == "off" ]]; then
    echo "Skip Unipept-based taxonomic annotation!"
else
    echo "Skip Unipept-based taxonomic annotation!"
fi

############ 05.eggnog-mapper run
## workdir now: $Anno_work_dir/05.eggnog.run/00.lib
# step 5.1 eggnog-mapper run
#echo "Run eggnog-mapper for eggnog annotation? (yes/no): "
#read user_input_cog
#user_input_cog_lower=$(echo "$user_input_cog" | tr '[:upper:]' '[:lower:]')
if [[ "$eggnog_switch" == "on" ]]; then
echo "[`date`]: workdir: 05.eggnog.run/00.lib; 5.1 eggnog-mapper run..." >> $Anno_work_dir/02.Annotation.log.txt
cp $Anno_work_dir/05.eggnog.run/00.lib/*.fasta $total_dir/software/eggnog-mapper/input
cd $total_dir/software/eggnog-mapper/
emapper.py -i $total_dir/software/eggnog-mapper/input/*.fasta --output $total_dir/software/eggnog-mapper/output/${database}_irt_contam_ddafile_NEW_rmone_diamond --data_dir $total_dir/software/eggnog-mapper/eggnog-mapper-data --cpu $anno_threads --override -m diamond && \
cp $total_dir/software/eggnog-mapper/output/*.annotations $Anno_work_dir/05.eggnog.run/00.lib && \
echo "[`date`]: workdir: 05.eggnog.run/00.lib; 05.eggnog-mapper run DONE" >> $Anno_work_dir/02.Annotation.log.txt

# step 5.2 metagroup progroup COG annotation
echo "[`date`]: workdir: 05.eggnog.run/00.lib; 5.2 metagroup progroup COG annotation..." >> $Anno_work_dir/02.Annotation.log.txt
perl $Anno_src_dir/05.eggnog.run/00.lib/01.eggnog_metagroup_progroup.pl -db $database -wd $Anno_work_dir >> $Anno_work_dir/02.Annotation.log.txt 2>&1 && \
echo "[`date`]: workdir: 05.eggnog.run/00.lib; 5.2 metagroup progroup COG annotation DONE" >> $Anno_work_dir/02.Annotation.log.txt

elif [[ "$eggnog_switch" == "off" ]]; then
    echo "Skip eggnog-mapper-based eggnog annotation!"
else
    echo "Skip eggnog-mapper-based eggnog annotation!"
fi
############### 06.run lib kegg ghostkoala
#echo "Run ghostkoala for kegg annotation? (yes/no): "
#read user_input_kegg
#user_input_kegg_lower=$(echo "$user_input_kegg" | tr '[:upper:]' '[:lower:]')
if [[ "$kegg_switch" == "on" ]]; then

echo "[`date`]: workdir: 06.kegg.run/00.lib; 6.2 metagroup progroup KEGG annotation..." >> $Anno_work_dir/02.Annotation.log.txt
#workdir now $Anno_work_dir/06.kegg.run/00.lib
#ssh $Anno_work_dir/06.kegg.run/00.lib/user_ko.txt $Anno_work_dir/06.kegg.run/00.lib/user.out.top
cp $total_dir/Results/user* $Anno_work_dir/06.kegg.run/00.lib
perl $Anno_src_dir/06.kegg.run/00.lib/01.kegg.metagroup_progroup.pl -db $database -wd $Anno_work_dir >> $Anno_work_dir/02.Annotation.log.txt 2>&1 && \
echo "[`date`]: workdir: 06.kegg.run/00.lib; 6.2 metagroup progroup KEGG annotation DONE" >> $Anno_work_dir/02.Annotation.log.txt
elif [[ "$kegg_switch" == "off" ]]; then
    echo "Skip ghostkoala-based kegg annotation!"
else
    echo "Skip ghostkoala-based kegg annotation!"
fi
############################ matrix generation ############################
## step 2 generate protein matrix
## step 2.1 generate protein matrix
echo "[`date`]: workdir: 00.rawdata; step 2.1 generate protein matrix ..." >> $Anno_work_dir/02.Annotation.log.txt
perl $Anno_src_dir/00.rawdata/02.1.pg.matrix.intens.pl -wd $Anno_work_dir -proj $project_name -db $database -prof $input_pg_mat -fs $sample_label >> $Anno_work_dir/02.Annotation.log.txt 2>&1 && \
echo "[`date`]: step 2.1 done" >> $Anno_work_dir/02.Annotation.log.txt
########

## step 3 generate peptide matrix
## step 3.1 generate peptide matrix & generate matrix peptide seq
echo "[`date`]: workdir: 00.rawdata; 3.1 generate peptide matrix & generate peptide seq for unipept ..." >> $Anno_work_dir/02.Annotation.log.txt
perl $Anno_src_dir/00.rawdata/03.1.pr.matrix.intens.pl -wd $Anno_work_dir -proj $project_name -db $database -fs $sample_label -pepf $input_pr_mat >> $Anno_work_dir/02.Annotation.log.txt 2>&1 && \
echo "[`date`]: step 3.1 done" >> $Anno_work_dir/02.Annotation.log.txt
########

## step 4.3 generate taxon quantification matrix from peptide matrix
echo "[`date`]: workdir: 04.pep2taxon 4.3 generate taxon quantification matrix from peptide matrix ..." >> $Anno_work_dir/02.Annotation.log.txt
#workdirnow=$Anno_work_dir/04.pep2taxon/01.matrix
libpep2tax=$Anno_work_dir/04.pep2taxon/00.lib/${database}_lib_micro_peptide2taxon.csv
perl $Anno_src_dir/04.pep2taxon/01.matrix/01.all_taxon_matrix_all_human_micro.pl -wd $Anno_work_dir -proj $project_name -db $database -lp2t $libpep2tax >> $Anno_work_dir/02.Annotation.log.txt 2>&1 && \
echo "[`date`]: step 4.3 done" >> $Anno_work_dir/02.Annotation.log.txt

## step 4.4 sep all taxon matrix into all sample techrep biorep qc pool taxon matrix
echo "[`date`]: workdir: 04.pep2taxon 4.4 sep all taxon matrix into all sample techrep biorep qc pool taxon matrix ..." >> $Anno_work_dir/02.Annotation.log.txt
#workdirnow=$Anno_work_dir/04.pep2taxon/01.matrix/02.taxon_matrix
perl $Anno_src_dir/04.pep2taxon/01.matrix/02.taxon_matrix/02.sep_taxon_matrix.pl -fs $sample_label -wd $Anno_work_dir -proj $project_name -db $database >> $Anno_work_dir/02.Annotation.log.txt 2>&1 && \
echo "[`date`]: step 4.4 done" >> $Anno_work_dir/02.Annotation.log.txt
########

## step 5.3 COG matrix generation
echo "[`date`]: workdir: 05.eggnog.run 5.3 COG matrix generation ..." >> $Anno_work_dir/02.Annotation.log.txt
perl $Anno_src_dir/05.eggnog.run/02.matrix/01.all_eggnog_matrix_all_human_micro.pl -wd $Anno_work_dir -proj $project_name -db $database >> $Anno_work_dir/02.Annotation.log.txt 2>&1 && \
perl $Anno_src_dir/05.eggnog.run/02.matrix/02.sep_cog_matrix.pl -wd $Anno_work_dir -proj $project_name -db $database -fs $sample_label >> $Anno_work_dir/02.Annotation.log.txt 2>&1 && \
echo "[`date`]: step 5.3 done" >> $Anno_work_dir/02.Annotation.log.txt

## step 5.4 COG matrix to one dir
cp $Anno_work_dir/05.eggnog.run/02.matrix/protein/*/* $Anno_work_dir/05.eggnog.run/02.matrix/protein/COG_ori
cp $Anno_work_dir/05.eggnog.run/02.matrix/humanprotein/*/* $Anno_work_dir/05.eggnog.run/02.matrix/humanprotein/COG_ori
cp $Anno_work_dir/05.eggnog.run/02.matrix/microprotein/*/*  $Anno_work_dir/05.eggnog.run/02.matrix/microprotein/COG_ori
cp $Anno_work_dir/05.eggnog.run/02.matrix/*/*all_cogmatrix.tsv $Anno_work_dir/05.eggnog.run/02.matrix/COGmatrix_all

## step 5.6 COGcat matrix generation
echo "[`date`]: workdir: 05.eggnog.run COGcat matrix generation ..." >> $Anno_work_dir/02.Annotation.log.txt
perl $Anno_src_dir/05.eggnog.run/03.cogcat.matrix/01.all_cogcat_matrix_all_human_micro.pl -sd $Anno_src_dir -wd $Anno_work_dir -proj $project_name -db $database >> $Anno_work_dir/02.Annotation.log.txt 2>&1 && \
perl $Anno_src_dir/05.eggnog.run/03.cogcat.matrix/02.sep_cogcat_matrix.pl -wd $Anno_work_dir -proj $project_name -db $database -fs $sample_label >> $Anno_work_dir/02.Annotation.log.txt 2>&1 && \
echo "[`date`]: step 5.6 done ..." >> $Anno_work_dir/02.Annotation.log.txt

# step 5.7 COGcat matrix to one dir
cp $Anno_work_dir/05.eggnog.run/03.cogcat.matrix/protein/*/* $Anno_work_dir/05.eggnog.run/03.cogcat.matrix/protein/COGcat_ori
cp $Anno_work_dir/05.eggnog.run/03.cogcat.matrix/humanprotein/*/* $Anno_work_dir/05.eggnog.run/03.cogcat.matrix/humanprotein/COGcat_ori
cp $Anno_work_dir/05.eggnog.run/03.cogcat.matrix/microprotein/*/* $Anno_work_dir/05.eggnog.run/03.cogcat.matrix/microprotein/COGcat_ori
cp $Anno_work_dir/05.eggnog.run/03.cogcat.matrix/*/*cogcatmatrix.tsv $Anno_work_dir/05.eggnog.run/03.cogcat.matrix/COGcatmatrix_all
########
## step 6.4 KEGG matrix generation
#echo "[`date`]: workdir: 06.kegg.run 6.4 KEGG matrix generation ..." >> $Anno_work_dir/02.Annotation.log.txt
perl $Anno_src_dir/06.kegg.run/02.matrix/01.all_kegg_matrix_all_human_micro.pl -wd $Anno_work_dir -proj $project_name -db $database >> $Anno_work_dir/02.Annotation.log.txt 2>&1 && \
perl $Anno_src_dir/06.kegg.run/02.matrix/02.sep_kegg_matrix.pl -wd $Anno_work_dir -proj $project_name -db $database -fs $sample_label >> $Anno_work_dir/02.Annotation.log.txt 2>&1 && \
echo "[`date`]: step 6.4 done ..." >> $Anno_work_dir/02.Annotation.log.txt
# step 6.5 KEGG matrix to one dir
cp $Anno_work_dir/06.kegg.run/02.matrix/protein/*/* $Anno_work_dir/06.kegg.run/02.matrix/protein/KEGG_ori
cp $Anno_work_dir/06.kegg.run/02.matrix/humanprotein/*/* $Anno_work_dir/06.kegg.run/02.matrix/humanprotein/KEGG_ori
cp $Anno_work_dir/06.kegg.run/02.matrix/microprotein/*/* $Anno_work_dir/06.kegg.run/02.matrix/microprotein/KEGG_ori
cp $Anno_work_dir/06.kegg.run/02.matrix/*/*all_keggmatrix.tsv $Anno_work_dir/06.kegg.run/02.matrix/KEGGmatrix_all

# step 6.6 KEGGcat matrix generation
echo "[`date`]: workdir: 06.kegg.run 6.6 KEGGcat matrix generation ..." >> $Anno_work_dir/02.Annotation.log.txt
perl $Anno_src_dir/06.kegg.run/03.keggcat.matrix/01.all_keggcat_matrix_all_human_micro.pl -sd $Anno_src_dir -wd $Anno_work_dir -proj $project_name -db $database >> $Anno_work_dir/02.Annotation.log.txt 2>&1 && \
perl $Anno_src_dir/06.kegg.run/03.keggcat.matrix/02.sep_keggcat_matrix.pl -wd $Anno_work_dir -proj $project_name -db $database -fs $sample_label >> $Anno_work_dir/02.Annotation.log.txt 2>&1 && \
echo "[`date`]: workdir: step 6.6 done ..." >> $Anno_work_dir/02.Annotation.log.txt
# step 6.7 KEGGcat matrix to one dir
cp $Anno_work_dir/06.kegg.run/03.keggcat.matrix/protein/*/* $Anno_work_dir/06.kegg.run/03.keggcat.matrix/protein/KEGGcat_ori
cp $Anno_work_dir/06.kegg.run/03.keggcat.matrix/humanprotein/*/* $Anno_work_dir/06.kegg.run/03.keggcat.matrix/humanprotein/KEGGcat_ori
cp $Anno_work_dir/06.kegg.run/03.keggcat.matrix/microprotein/*/* $Anno_work_dir/06.kegg.run/03.keggcat.matrix/microprotein/KEGGcat_ori
cp $Anno_work_dir/06.kegg.run/03.keggcat.matrix/*/*keggcatmatrix.tsv $Anno_work_dir/06.kegg.run/03.keggcat.matrix/KEGGcatmatrix_all

######### integrate matrix ##########
cd $Anno_work_dir/07.matrix
mkdir all sample techrep biorep qc pool
## all
cp $Anno_work_dir/01.pg/*_all.tsv all
cp $Anno_work_dir/02.pr/*_all.tsv all
cp $Anno_work_dir/04.pep2taxon/01.matrix/02.taxon_matrix/*/all/* all
cp $Anno_work_dir/05.eggnog.run/02.matrix/COGmatrix_all/* all
cp $Anno_work_dir/05.eggnog.run/03.cogcat.matrix/COGcatmatrix_all/* all
cp $Anno_work_dir/06.kegg.run/02.matrix/KEGGmatrix_all/* all
cp $Anno_work_dir/06.kegg.run/03.keggcat.matrix/KEGGcatmatrix_all/* all

## sample
cp $Anno_work_dir/01.pg/*_sample.tsv sample
cp $Anno_work_dir/02.pr/*_sample.tsv sample
cp $Anno_work_dir/04.pep2taxon/01.matrix/02.taxon_matrix/*/sample/* sample
cp $Anno_work_dir/05.eggnog.run/02.matrix/*/sample/* sample
cp $Anno_work_dir/05.eggnog.run/03.cogcat.matrix/*/sample/* sample
cp $Anno_work_dir/06.kegg.run/02.matrix/*/sample/* sample
cp $Anno_work_dir/06.kegg.run/03.keggcat.matrix/*/sample/* sample

## techrep
cp $Anno_work_dir/01.pg/*_techrep.tsv techrep
cp $Anno_work_dir/02.pr/*_techrep.tsv techrep
cp $Anno_work_dir/04.pep2taxon/01.matrix/02.taxon_matrix/*/techrep/* techrep
cp $Anno_work_dir/05.eggnog.run/02.matrix/*/techrep/* techrep
cp $Anno_work_dir/05.eggnog.run/03.cogcat.matrix/*/techrep/* techrep
cp $Anno_work_dir/06.kegg.run/02.matrix/*/techrep/* techrep
cp $Anno_work_dir/06.kegg.run/03.keggcat.matrix/*/techrep/* techrep

## biorep
cp $Anno_work_dir/01.pg/*_biorep.tsv biorep
cp $Anno_work_dir/02.pr/*_biorep.tsv biorep
cp $Anno_work_dir/04.pep2taxon/01.matrix/02.taxon_matrix/*/biorep/* biorep
cp $Anno_work_dir/05.eggnog.run/02.matrix/*/biorep/* biorep
cp $Anno_work_dir/05.eggnog.run/03.cogcat.matrix/*/biorep/* biorep
cp $Anno_work_dir/06.kegg.run/02.matrix/*/biorep/* biorep
cp $Anno_work_dir/06.kegg.run/03.keggcat.matrix/*/biorep/* biorep

## pool
cp $Anno_work_dir/01.pg/*_pool.tsv pool
cp $Anno_work_dir/02.pr/*_pool.tsv pool
cp $Anno_work_dir/04.pep2taxon/01.matrix/02.taxon_matrix/*/pool/* pool
cp $Anno_work_dir/05.eggnog.run/02.matrix/*/pool/* pool
cp $Anno_work_dir/05.eggnog.run/03.cogcat.matrix/*/pool/* pool
cp $Anno_work_dir/06.kegg.run/02.matrix/*/pool/* pool
cp $Anno_work_dir/06.kegg.run/03.keggcat.matrix/*/pool/* pool

## qc
cp $Anno_work_dir/01.pg/*_qc.tsv qc
cp $Anno_work_dir/02.pr/*_qc.tsv qc
cp $Anno_work_dir/04.pep2taxon/01.matrix/02.taxon_matrix/*/qc/* qc
cp $Anno_work_dir/05.eggnog.run/02.matrix/*/qc/* qc
cp $Anno_work_dir/05.eggnog.run/03.cogcat.matrix/*/qc/* qc
cp $Anno_work_dir/06.kegg.run/02.matrix/*/qc/* qc
cp $Anno_work_dir/06.kegg.run/03.keggcat.matrix/*/qc/* qc
