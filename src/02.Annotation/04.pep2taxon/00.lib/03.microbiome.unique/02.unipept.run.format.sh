## taxa of peplib using unipept
#!/bin/bash
work_dir=$1
cd $work_dir
pepseq=`ls *.seq`
pepseqpre=${pepseq%.*}
filterseq=${pepseqpre}_filter.seq
time cat $pepseq | prot2pept | peptfilter | sort -u > $filterseq

unipept pept2lca --equate --all --input $filterseq -o ${pepseqpre}_filter_unipept_pept2lca.csv && \
echo "pept2lca DONE\n"
#nohup unipept pept2ec --equate --all --input $filterseq -o ${pepseqpre}_filter_unipept_pept2ec.csv &
#nohup unipept pept2funct --equate --all --input $filterseq -o ${pepseqpre}_filter_unipept_pept2funct.csv &
#nohup unipept pept2go --equate --all --input $filterseq -o ${pepseqpre}_filter_unipept_pept2go.csv &
#nohup unipept pept2interpro --equate --all --input $filterseq -o ${pepseqpre}_filter_unipept_pept2interpro.csv &
#nohup unipept pept2prot --equate --all --input $filterseq -o ${pepseqpre}_filter_unipept_pept2prot.csv &
#nohup unipept pept2taxa --equate --all --input $filterseq -o ${pepseqpre}_filter_unipept_pept2taxa.csv &
#nohup unipept peptinfo --equate --all --input $filterseq -o ${pepseqpre}_filter_unipept_peptinfo.csv &
#nohup unipept taxa2lca --equate --all --input $filterseq -o ${pepseqpre}_filter_unipept_taxa2lca.csv &
#nohup unipept taxa2tree --equate --all --input $filterseq -o ${pepseqpre}_filter_unipept_taxa2tree.csv &
#nohup unipept taxonomy --equate --all --input $filterseq -o ${pepseqpre}_filter_unipept_taxonomy.csv &
