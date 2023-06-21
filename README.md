# metaExpertPro

## Description
metaExpertPro is a comutational software for effective analysis of DDA-MS and DIA-MS hybrid based metaproteomic data analysis. It provides a complete pipeline for peptide and protein measurement, functional and taxonomic annotation, and generation of quantitative matrices for both microbiota and hosts. It is compatible with DDA-MS and DIA-MS data from both Thermo Fisher Orbitrap ( .raw / .mzML format) or Bruker (.d format) mass spectrometers.

## Installation
The metaExpertPro software is supported by Docker, which is enable running under both Window and Linux operating system.
It is recommened having at least 128 GB RAM and 50 GB storage space for one DDA-MS raw data (.d or .mzML) based metaExpertPro analysis.
First, download metaExpertPro container from Docker Hub.

`
$ docker pull yingxiaoying1993/metaexpertpro:v1
`
## Folders and files
The following folders are required:
1. A folder as the total directory for metaExpertPro (metaEx).
2. A folder for DDA raw data input files (metaEx/DDAraw).
3. A folder for DIA raw data input files (metaEx/DIAraw).
4. A folder for microbial protein sequence database input files (metaEx/fasta/Microbiota)
5. A folder for human, contaminant, and iRT protein sequence database input files (metaEx/fasta/HumanContamIrt).
6. A folder for analysis results (metaEx/Results)
7. A folder for sample name, batch ID, and label (metaEx/sampleLabel)

The file format are required as follows:
1. DDA and DIA raw data input file format are either .d or .mzML.
2. Microbial protein database input file is required as .fas format.
3. Human, contaminant, and iRT database input file is required as .fasta format.
4. Sample label input file is required as .csv format and the example content is shown in above example folder.

## Run metaExpertPro for DDA-MS based spectral library generation and DIA-MS based peptide and protein quantification.
Get help of all command line parameters:

`
docker run -it --rm -u $(id -u):$(id -g) yingxiaoying1993/metaexpertpro:v1 sh /metaEx/src/00.DDAspectrallib/00.DDA.DIA.sh --help
`

Note: the settings for DDA RAM and DDA threads

The recommended RAM for the three-step iterative database search is set as default, with 48 GB allocated for cycle1 and cycle2, and 128 GB allocated for cycle3. The user's configured number of threads is equal to the number of parallel tasks in metaExpert, so when setting the number of threads, the user needs to consider whether their computer has sufficient RAM. For example, if the computer has 128GB of RAM and 20 cores, but considering that each task in cycle1 requires 48GB of RAM, the threads should be set to 2.

## Default parameter settings for DDA and DIA database search
For DDA-MS database search:

True precursor mass tolerance (unit ppm): 20

Fragment mass tolerance units (0 for Da, 1 for ppm): 1

Fragment mass tolerance: 20

Minimum length of peptides to be generated during in-silico digestion: 7

Maximum length of peptides to be generated during in-silico digestion: 50

Allowed number of missed cleavages per peptide: 2

Cleavage site: Trypsin

Threads: 20

For DIA-MS database search:

True precursor mass tolerance (unit ppm): 10 

Fragment mass tolerance (unit ppm): 10

Allowed number of missed cleavages per peptide: 1

Threads: 20

### Run the analysis from the command line

`
sudo docker run -it --rm \
-u $(id -u):$(id -g) \
-v /workdir/metaEx/DDAraw/:/metaEx/DDAraw/ \
-v /workdir/metaEx/DIAraw/:/metaEx/DIAraw/ \
-v /workdir/metaEx/fasta/:/metaEx/fasta/ \
-v /workdir/metaEx/sampleLabel/:/metaEx/sampleLabel/ \
-v /workdir/metaEx/Results/:/metaEx/Results/ \
yingxiaoying1993/metaexpertpro:v1 sh /metaEx/src/00.DDAspectrallib/00.DDA.DIA.sh --total_dir /metaEx --project_name xxx --dda_threads xxx --dia_threads xxx \
`








