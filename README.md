# metaExpertPro

## Description
metaExpertPro is a computational software for the analysis of DDA-MS and DIA-MS hybrid-based metaproteomic data. It provides a complete pipeline for peptide and protein measurement, functional and taxonomic annotation, and generation of quantitative matrices for both microbiota and hosts. It is compatible with DDA-MS and DIA-MS data from Thermo Fisher Orbitrap ( .raw / .mzML format) or Bruker (.d format) mass spectrometers.

## Installation
The metaExpertPro software is supported by Docker, which enables running under both Windows and Linux operating systems.
It is recommended to have at least 128 GB RAM and 50 GB storage space for one DDA-MS raw data (.d or .mzML) based metaExpertPro analysis.
First, download the metaExpertPro container from Docker Hub.

```
$ docker pull guomics2017/metaexpertpro:v1.2
```

## Part 1: run metaExpertPro for DDA-MS-based spectral library generation and DIA-MS-based peptide and protein quantification.

### Folders and files
The following folders are required:
1. A folder as the total directory for metaExpertPro (metaEx).
2. A folder for DDA raw data input files (metaEx/DDAraw).
3. A folder for DIA raw data input files (metaEx/DIAraw).
4. A folder for microbial protein sequence database input files (metaEx/fasta/Microbiota)
5. A folder for human, contaminant, and iRT protein sequence database input files (metaEx/fasta/HumanContamIrt).
6. A folder for analysis results (metaEx/Results)

The file format is required as follows:
1. DDA and DIA raw data input file formats are .d or .mzML.
2. Microbial protein database input file is required as .fas format.
3. Human, contaminant, and iRT database input file is required in .fasta format.

### Get help with all command line parameters:

```
docker run -it --rm -u $(id -u):$(id -g) guomics2017/metaexpertpro:v1.2 sh /metaEx/src/00.DDAspectrallib/00.DDA.DIA.sh --help
```

Note: the settings for DDA RAM and DDA threads

The recommended RAM for the three-step iterative database search is set as default, with 48 GB allocated for cycle1 and cycle2, and 128 GB allocated for cycle3. The user's configured number of threads is equal to the number of parallel tasks in metaExpertPro, so when setting the number of threads, the user needs to consider whether their computer has sufficient RAM. For example, if the computer has 128GB of RAM and 20 cores, but considering that each task in cycle 1 requires 48GB of RAM, the threads should be set to 2.

### Default parameter settings for DDA and DIA database search
For DDA-MS database search:
- True precursor mass tolerance (unit ppm): 20
- Fragment mass tolerance units (0 for Da, 1 for ppm): 1
- Fragment mass tolerance: 20
- Minimum length of peptides to be generated during in-silico digestion: 7
- Maximum length of peptides to be generated during in-silico digestion: 50
- Allowed number of missed cleavages per peptide: 2
- Cleavage site: Trypsin
- Threads: 20

For DIA-MS database search:
- True precursor mass tolerance (unit ppm): 10 
- Fragment mass tolerance (unit ppm): 10
- Allowed number of missed cleavages per peptide: 1
- Threads: 20

### Run the analysis from the command line
```
docker run -it --rm \
-u $(id -u):$(id -g) \
-v /workdir/metaEx/DDAraw/:/metaEx/DDAraw/ \
-v /workdir/metaEx/DIAraw/:/metaEx/DIAraw/ \
-v /workdir/metaEx/fasta/:/metaEx/fasta/ \
-v /workdir/metaEx/Results/:/metaEx/Results/ \
guomics2017/metaexpertpro:v1.2 sh /metaEx/src/00.DDAspectrallib/00.DDA.DIA.sh \
--total_dir /metaEx --project_name xxx --dda_threads xxx --dia_threads xxx \
--dda_cycle1_RAM xxx --dda_cycle2_RAM xxx --dda_cycle3_RAM xxx
```
### Results
- DDA-MS-based spectral library: metaEx/Results/00.DDAspectrallib/proteinInference/s2_inference/output/xxx_spectral_library_date.tsv
- DDA-MS-based protein sequences:
  metaEx/Results/00.DDAspectrallib/proteinInference/s2_inference/output/xxx.fasta
- DIA-MS-based peptide and protein quantitative matrices:
metaEx/Results/01.DIAquant

## Part 2: run metaExpertPro for functional and taxonomic annotation and quantitative matrices generation.

### Folders and files
1. For eggnog-mapper-based eggnog annotation:

For conducting eggnog annotation via eggnog-mapper, the essential eggnog-mapper database files, namely eggnog.db and eggnog_proteins.dmnd, are necessary. You can obtain the compressed files by accessing the following link (https://pan.baidu.com/s/11ZTPnbgz5p2c75W-ATJ8JA) on Baidu Cloud Drive (with the extraction code being yosa). Subsequently, these files need to be decompressed and positioned within the directory path metaEx/software/eggnog-mapper/eggnog-mapper-data/.

Note: The sizes of the eggnog.db and eggnog_proteins.dmnd files are approximately 42 GB.

2. For GhostKOALA-based KO annotation:

The GhostKOALA-based KO annotation can only be done through the webserver (https://www.kegg.jp/ghostkoala/)
The users need to upload the .fasta file in the folder metaEx/Results/00.DDAspectrallib/proteinInference/s2_inference/output generated from the Part 1 run to the GhostKOALA. 

Then, place the results of GhostKOALA in the folder metaEx/Results

3. A folder for sample name, batch ID, and label (metaEx/sampleLabel):

Sample label input file is required as .csv format and the example content is shown in the example folder.

4. It is recommended to have at least 32 GB RAM for annotation analysis.

### Get help with all command line parameters:

```
docker run -it --rm -u $(id -u):$(id -g) guomics2017/metaexpertpro:v1.2 sh /metaEx/src/02.Annotation/01.annotation.sh --help
```

### Default parameter settings for annotation and quantification
- threads: 20
- sample label file: /metaEx/sampleLabel/my_project_sample_label.csv

### Run the analysis from the command line
```
docker run -it --rm \
-u $(id -u):$(id -g) \
-v /workdir/metaEx/sampleLabel/:/metaEx/sampleLabel/ \
-v /workdir/metaEx/Results/:/metaEx/Results/ \
-v /workdir/metaEx/software/eggnog-mapper/eggnog-mapper-data/:/metaEx/software/eggnog-mapper/eggnog-mapper-data/ \
guomics2017/metaexpertpro:v1.2 sh /metaEx/src/02.Annotation/01.annotation.sh --total_dir /metaEx --project_name xxx --sample_label /metaEx/sampleLabel/xxx --database xxx --anno_threads xxx --unipept_switch on --eggnog_switch on --kegg_switch on
```
### Results
All the matrices are located in the metaEx/Results/02.Annotation/07.matrix. The folder includes the following folders:
- all/: all the samples
- sample/: subjective samples
- qc/: inter-batch biological replicates
- pool/: inter-batch technical replicates
- biorep/: intra-batch biological replicates
- techrep/: intra-batch technical replicates

Each of the above folders contains peptide, protein, COG, COG category, KO, KO category, and taxa quantitative matrices for the corresponding samples.


## Publications

