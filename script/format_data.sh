while true; do
	case "$1" in
		-i) inputFile=$2; shift 2;;
		-o) outputDir=$2; shift 2;;
		-n) name=$2; shift 2;;
		--scriptDir) scriptDir=$2; shift 2;;
		--databaseDir) databaseDir=$2; shift 2;;
		--contigName) contigName=$2; shift 2;;
		*) break;
	esac
done

if [ -n $name ]; then name=default; fi
if [ -n $inputFile ]; then ; fi

windowSize=1000
stepSize=200
identity=50
queryCover=70
subjectCover=70
threads=16

prodigal -i ${inputFile} -a ${outputDir}/${name}.prodigal.pep -f gff -o ${outputDir}/${name}.prodigal.gff3
diamond blastp -d ${databaseDir}/COG/prot2003-2014 -q ${outputDir}/${name}.prodigal.pep -o ${outputDir}/${name}.diamond.tblout -e 1e-5 -p ${threads} --max-target-seqs 1 --id ${identity} --query-cover ${queryCover} --subject-cover ${subjectCover} --sensitive
rnammer -S bac -multi -h ${outputDir}/${name}.RNAmmer.hmmreport -gff ${outputDir}/${name}.RNAmmer.gff -f ${outputDir}/${name}.RNAmmer.fasta ${inputFile}
tRNAscan-SE -qQ -Y -o ${outputDir}/${name}.tRNAscan.tblout -m ${outputDir}/${name}.tRNAscan.summary -B ${inputFile}
tmp=`esl-seqstat ${inputFile}`
tmp1=${tmp#*residues:}
tmp2=${tmp1%Smallest:*}
((num=${tmp2}*2/1000000))
cmscan -Z $num --cut_ga --cpu ${threads} --rfam --nohmmonly --tblout ${outputDir}/${name}.rfam.tblout --fmt 2 --clanin ${databaseDir}/Rfam/Rfam.clanin ${databaseDir}/Rfam/Rfam.cm ${inputFile}

perl ${scriptDir}/1.count_genome_GC.pl -i ${inputFile} -o ${outputDir}${name} -w ${windowSize} -s ${stepSize}
perl ${scriptDir}/2.annotation_formatting.pl -o ${outputDir}${name} -prodigalFile ${outputDir}/${name}.prodigal.pep -rnammerFile ${outputDir}/${name}.RNAmmer.gff -trnascanFile ${outputDir}/${name}.tRNAscan.tblout -rfamFile ${outputDir}/${name}.rfam.tblout -rfamRf ${databaseDir}/Rfam/rfamid2class.tsv -cogPep ${databaseDir}/COG/prot2003-2014.fa -cogPepID2CogID ${databaseDir}/COG/cog2003-2014.csv -cogCogID2ClassID ${databaseDir}/COG/COGid2COGclass.tsv -cogFile ${outputDir}/${name}.diamond.tblout
perl ${scriptDir}/3.createCGViewXml.pl -i ${outputDir}${name} -o ${outputDir}/${name}.CGView.xml -CGViewFile ${scriptDir}/CGView.config -COGColorFile ${scriptDir}/COG.color.config -contigName ${contigName}
