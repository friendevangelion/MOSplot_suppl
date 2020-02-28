# Introduction

This pipeline is used to create the input file for circular genome image.

# Prerequisite

Before you use this pipeline, several tools/databases should be
installed/downloaded on your working environment:

diamond (fast and sensitive protein alignment)

Prodigal (gene prediction for prokaryote genome)

RNAmmer (rRNA gene prediction)

tRNAscan-SE (tRNA gene prediction)

cmscan (Infernal: inference of RNA alignments)

COG database (Cluster of Orthologous Groups of proteins database)

Rfam database (RNA families database)

**NOTE:** All the tools can be easily installed by using conda. Or you can
install them by following the instruction in manual page of all the tools:

diamond (https://github.com/bbuchfink/diamond)

Prodigal (https://github.com/hyattpd/Prodigal)

RNAmmer (http://www.cbs.dtu.dk/services/RNAmmer)

tRNAscan-SE (http://trna.ucsc.edu/software)

Infernal (https://github.com/EddyRivasLab/infernal)

To download and format COG database, you can perform the following steps at the
shell prompt:

\# set database directory \$db_dir, eg: db_dir=\`pwd\`/db

\# copy all perl/shell script to script directory \$script_dir, eg:
script_dir=\`pwd\`/script

if [ ! -d \${db_dir} ]; then mkdir \${db_dir}; fi

if [ ! -d \${db_dir}/COG ]; then mkdir \${db_dir}/COG; fi

cd \${db_dir}/COG

if [ ! -f \${db_dir}/COG/COGid2COGclass.tsv ]; then

if [ ! -f \${db_dir}/COG/listCOGs.html ]; then wget
https://ftp.ncbi.nih.gov/pub/COG/COG2014/static/lists/listCOGs.html; fi

perl \${script_dir}/COGid2COGclass.pl \> COGid2COGclass.tsv

fi

if [ ! -f \${db_dir}/COG/prot2003-2014.fa ]; then

if [ ! -f \${db_dir}/COG/prot2003-2014.fa.gz ]; then wget
https://ftp.ncbi.nih.gov/pub/COG/COG2014/data/prot2003-2014.fa.gz; fi

gunzip prot2003-2014.fa.gz

fi

if [ ! -f \${db_dir}/COG/cog2003-2014.csv ]; then wget
https://ftp.ncbi.nih.gov/pub/COG/COG2014/data/cog2003-2014.csv; fi

if [ ! -f \${db_dir}/COG/prot2003-2014.dmnd ]; then diamond makedb --in
prot2003-2014.fa -d prot2003-2014; fi

To download and format Rfam database, you can perform the following steps at the
shell prompt:

\# set database directory \$db_dir, eg: db_dir=\`pwd\`/db

\# copy all perl/shell script to script directory \$script_dir, eg:
script_dir=\`pwd\`/script

if [ ! -d \${db_dir} ]; then mkdir \${db_dir}; fi

if [ ! -d \${db_dir}/Rfam ]; then mkdir \${db_dir}/Rfam; fi

cd \${db_dir}/Rfam

if [ ! -f \${db_dir}/Rfam/Rfam.cm ]; then

if [ ! -f \${db_dir}/Rfam/Rfam.cm.gz ]; then wget
ftp://ftp.ebi.ac.uk/pub/databases/Rfam/14.0/Rfam.cm.gz; fi

gunzip Rfam.cm.gz

fi

if [ ! -f \${db_dir}/Rfam/Rfam.clanin ]; then wget
ftp://ftp.ebi.ac.uk/pub/databases/Rfam/14.0/Rfam.clanin; fi

cat \${script_dir}/rfam_entry.tsv \| awk 'BEGIN
{FS=OFS="\\t"}{split(\$3,x,";");class=x[2];print \$1,\$2,\$3,class}' \>
rfamid2class.tsv

cmpress Rfam.cm

**NOTE:** File 'rfam_entry.tsv' is obtained from website rfam.xfam.org. Select
all the entry in http://rfam.xfam.org/search#tabview=tab5 and submit your
query. Download all the **UNFORMATTED LIST** (on the bottom of the result page)
as file 'rfam_entry.tsv'.

# Usage

Usage: format_data.sh [options]

Options: (\* means required parameters)

&emsp;\-i&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Input file.

&emsp;\-o&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Output directory.

&emsp;\-n&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;File header name.

&emsp;\--scriptDir&nbsp;&nbsp;&nbsp;Script directory.

&emsp;\--databaseDir&nbsp;Database directory.

&emsp;\--contigName&nbsp;Contig you want to display with CGView.

Example: format_data.sh -i
\`pwd\`/oridata/GCA_000153485.2_ASM15348v2_genomic.fna -o \`pwd\`/output/ -n
CP003879 --scriptDir \`pwd\`/script/ --databaseDir \`pwd\`/db/ --contigName
CP003879.1

# Output

\*.RNAmmer.fasta rRNA prediction result (nucleotide sequence) by RNAmmer

\*.RNAmmer.gff rRNA prediction result (gff format) by RNAmmer

\*.RNAmmer.hmmreport rRNA prediction result (detail report) by RNAmmer

\*.prodigal.gff3 coding-gene prediction result (gff format) by Prodigal

\*.prodigal.pep coding-gene prediction result (amino acid sequence) by Prodigal

\*.tRNAscan.summary tRNA prediction result (report) by tRNAscan-SE

\*.tRNAscan.tblout tRNA prediction result (tab-separated-values format) by
tRNAscan-SE

\*.rfam.tblout Rfam database annotation result (tab-separated-values format) by
Infernal

\*.diamond.tblout COG database annotation result (tab-separated-values format)
by diamond

\*.genomeGC.tab GC-content and GC-skew of all the slide windows of all sequences
in your input file

\*.genomeLength.tab genome length of all sequences in your input file

\*.codingGene.tab coding gene summary of all sequences in your input file

\*.noncodingGene.tab non-coding gene summary of all sequences in your input file

\*.CGView.xml xml file as the input of CGView
