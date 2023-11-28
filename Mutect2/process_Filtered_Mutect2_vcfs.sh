#!/usr/bin/bash
#SBATCH --partition=single,lattice,parallel
#SBATCH --job-name=Processing_annotated_Mutect2VCF
#SBATCH --mem=8G
#SBATCH --time=24:00:00
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err


##This is the template for the processing of annovar annotated variants (SNV/INDEL) in VCF (v4.1) format

SampleName_for_HEADER=$(less $2 | head -n 1000 | egrep "#CHROM" | cut -f 10-)

echo -e chrom'\t'pos'\t'ref'\t'alt'\t'format'\t'geneName'\t'geneFunc'\t'AAChange'\t'Exonicfunc'\t'$SampleName_for_HEADER > $1".processingVariants.tsv"

while read -r line ; do

#echo $line | sed 's/ /\t/g' ;

chrom=$(echo $line  | sed 's/ /\t/g' | cut -f 1) &&
pos=$(echo $line  | sed 's/ /\t/g' | cut -f 2) &&
ref=$(echo $line  | sed 's/ /\t/g' | cut -f 4) &&
alt=$(echo $line  | sed 's/ /\t/g' | cut -f 5) ;


format=$(echo $line  | sed 's/ /\t/g' | cut -f 9) ;


#EDi=$(echo $line | sed 's/ /\t/g' | cut -f 10 | sed 's/:/\t/g' | cut -f 1 | sed 's/,/\t/g' ) ;
geneName=$(echo $line | sed 's/ /\t/g' | cut -f 8 | sed 's/;/\n/g' | egrep -w "Gene.ensGene" | head -n 1 | cut -f 1| sed 's/Gene.ensGene=//' ) ;
geneFunc=$(echo $line | sed 's/ /\t/g' | cut -f 8 | sed 's/;/\n/g' | egrep -w "Func.ensGene" |head -n 1 | cut -f 1 | sed 's/Func.ensGene=//') ;
AAChange=$(echo $line | sed 's/ /\t/g' | cut -f 8 | sed 's/;/\n/g' | egrep -w "AAChange.ensGene" | head -n 1 | cut -f 1 | sed 's/AAChange.ensGene=//') ;
Exonicfunc=$(echo $line | sed 's/ /\t/g' | cut -f 8 | sed 's/;/\n/g' | egrep -w "ExonicFunc.ensGene" | head -n 1 | cut -f 1 | sed 's/ExonicFunc.ensGene=//')
EXAC_ALL=$(echo $line |sed 's/ /\t/g' | cut -f 8 | sed 's/;/\n/g' | egrep -w "ExAC_ALL" | head -n 1 | cut -f 1 | sed 's/ExAC_ALL=//')
Exonicfunc=$(echo $line | sed 's/ /\t/g' | cut -f 8 | sed 's/;/\n/g' | egrep -w "ExonicFunc.ensGene" | head -n 1 | cut -f 1 | sed 's/ExonicFunc.ensGene=//')
Cosmic70=$(echo $line | sed 's/ /\t/g' | cut -f 8 | sed 's/;/\n/g' | egrep -w "cosmic70" | head -n 1 | cut -f 1 | sed 's/cosmic70=//')

##
#Get all of the columns that have the variant counts 
SampleID=$(echo $line | sed 's/ /\t/g' | cut -f 10-)

#For each variant in all of the samples(including the germline), extract the variant and reference allele count. Order is reference then variant
VariantReadCountInfo=$(for x in $(echo $SampleID | sed 's/ /\t/g' |  tr -s ' ') ; do echo $x ; done | sed 's/:/\t/g'  | cut -f 2 | tr '\n' '\t')
#echo $VariantReadCountInfo

echo -e $chrom'\t'$pos'\t'$ref'\t'$alt'\t'$format'\t'$geneName'\t'$geneFunc'\t'$AAChange'\t'$Exonicfunc'\t'$Cosmic70'\t'$VariantReadCountInfo | sed 's/ /\t/g' >> $1".processingVariants.tsv" 

done < <(less $1 | egrep -v '#' | awk '$7=="PASS"') 
#done < <(less $1 | egrep -v '##' | awk '$7=="PASS"' | cut -f 1-9,14,15,16,17 | head -n 100)

 
#TODO: Review and compre the files --> Order looks good
#TODO: Annotate the header in the file --> Double check the correct sample name ID
#TODO: Create a secondary file of "damaging mutations"


#Post process
#head -n 1 *chrY.processingVariants.tsv > PTMB9777.Merged.Filtered.leftnormalized.Mutect2.vcf.gz.annovar.txt.hg38_multianno.vcf.processed.txt && cat *.processingVariants.tsv | egrep -v 'geneFunc' | sort -Vk 1,1 >> PTMB9777.Merged.Filtered.leftnormalized.Mutect2.vcf.gz.annovar.txt.hg38_multianno.vcf.processed.txt




