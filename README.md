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
## Directories and files
The following folders are required:
1. A folder as the total directory for metaExpertPro (metaEx).
2. A folder for DDA raw data input files (metaEx/DDAraw).
3. A folder for DIA raw data input files (metaEx/DIAraw).
4. A folder for microbial protein sequence database input files (metaEx/fasta/Microbiota)
5. A folder for human, contaminant, and iRT protein sequence database input files (metaEx/fasta/HumanContamIrt).
6. A folder for analysis results (metaEx/Results)
7. A folder for sample name, batch ID, and label (metaEx/sampleLabel)
The files format are required as follows:
1. DDA and DIA raw data input files are compatible with .d and .mzML.
2. Microbial protein database input file is required as .fas format.
3. Human, contaminant, and iRT database input file is required as .fasta format.
4. Analysis results folder should be empty before each analysis run.
5. 
