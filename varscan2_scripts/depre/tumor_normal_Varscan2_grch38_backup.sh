#!/usr/bin

#NOTE TUMOR IS $2 and NORMAL is $1

###Tumor normal callign for multiple myeloma using varscan2: Sequencing is WGS single cell 

normalBam=$1
tumorBam=$2

normalID=$(echo $1 | sed 's/.possorted_bam.bam//g')
tumorID=$(echo $2 | sed 's/.possorted_bam.bam//g')

###
pileupName=$(echo $tumorID"_"$normalID".mpileup"); 

tumorPileup=$(echo $1".mpileup");
normalPileup=$(echo $2".mpileup");
###
somaticPrefix=$(echo $tumorID"_"$normalID) ;

errName=$(echo $tumorID"_"$normalID".err");
outName=$(echo $tumorID"_"$normalID".out");

indelName=$(echo $tumorID".indel.vcf") ;
snpName=$(echo $tumorID".snp.vcf") ;

allVCFName=$(echo $tumorID".all.vcf");
####

#BCFtools version of mpileup
#bcftools mpileup -f /tiered/smorrissy/tools/references/grch38_2-1-0/refdata-GRCh38-2.1.0/fasta/genome.fa -B -Q 20-q 40 $1 $2

#Step 1 <$1 must be normal and $1 must be tumor>
/home/aaronhg/miniconda3/bin/samtools mpileup -B -f /tiered/smorrissy/tools/references/grch38_2-1-0/refdata-GRCh38-2.1.0/fasta/genome.fa -q 40 -Q 20 $1 $2 > $pileupName &&

#Tumor (post Rx) <optional>
#/home/aaronhg/miniconda3/bin/samtools mpileup -B -f /tiered/smorrissy/tools/references/grch38_2-1-0/refdata-GRCh38-2.1.0/fasta/genome.fa -q 40 -Q 20 $2 > $tumorPileup &&

#Normal (pre RX) <optional>
#/home/aaronhg/miniconda3/bin/samtools mpileup -B -f /tiered/smorrissy/tools/references/grch38_2-1-0/refdata-GRCh38-2.1.0/fasta/genome.fa -q 40 -Q 20 $1 > $normalPileup &&

#Step 2
/home/aaronhg/miniconda3/bin/varscan somatic $somaticPredix $pileupName --mpileup 1 --min-coverage-normal 8 --min-coverage-tumor 6 --min-var-freq 0.08 --output-snp $snpName --output-indel $indelName --strand-filter 0 --output-vcf 1 

#Removed the snp and indel vcf outs
#/home/aaronhg/miniconda3/bin/varscan somatic $somaticPredix $pileupName --mpileup 1 --min-coverage-normal 8 --min-coverage-tumor 6 --min-var-freq 0.08 --strand-filter 0 --output-vcf 1


#Step 3 <I might skip this step and proceed individually with SNP and INDEL
#bcftools vcf-merge snp.vcf indel.vcf | sort > $allVCFName


#Step 4 conver snp.vcf and indel.vcf to LOH,Germline and Somatic
varscan processSomatic $snpName --min-tumor-freq 0.08 

varscan processSomatic $indelName --min-tumor-freq 0.08


#Step 5
###Generate bed file for coordinates
#awk 'BEGIN {OFS="\t"} {if (!/^#/) { isDel=(length($4) > length($5)) ? 1 : 0; print $1,($2+isDel),($2+isDel); }}' all.Somatic.hc.vcf > all.Somatic.hc.var

for file in *.hc.vcf ; 
bedName=$(echo $file".var") ;
do awk 'BEGIN {OFS="\t"} {if (!/^#/) { isDel=(length($4) > length($5)) ? 1 : 0; print $1,($2+isDel),($2+isDel); }}' $file > $bedName ; 
done

#Step 6 Generage Bam-read counts
#Bam readCount for somatic, germline, LOH: Parameters are set for scCNV WG-sequencing
#bam-readcount -q 40 -b 20 -l all.Somatic.hc.var -f ref.fa tumor.bam > all.Somatic.hc.readcount
#bam-readcount -q 40 -b 20 -l all.Germline.hc.var -f ref.fa normal.bam > all.Germline.hc.readcount
#bam-readcount -q 40 -b 20 -l all.LOH.hc.var -f ref.fa normal.bam > all.LOH.hc.readcount

#$2 must be the tumor
for varInput in *.hc.vcf ; do
bedNameIn=$(echo $varInput".var") ;
readcount=$(echo $varInput".readcount") ;
bam-readcount -q 40 -b 20 -l $bedNameIn -f /tiered/smorrissy/tools/references/grch38_2-1-0/refdata-GRCh38-2.1.0/fasta/genome.fa $2 > $readcount ;
done


#for varInput in *.hc.vcf ; do bedNameIn=$(echo $varInput".var") ; readcount=$(echo $varInput".readcount") ; bam-readcount -q 40 -b 20 -l $bedNameIn -f /tiered/smorrissy/tools/references/grch38_2-1-0/refdata-GRCh38-2.1.0/fasta/genome.fa $2 > $readcount ; done

#Step 7 call fpfilter!
for finalVarInput in *.hc.vcf ; do
finalOutput=$(echo $finalVarInput"fpfiltered.vcf") ;
rcfile=$(echo $finalVarInput".readcount") ;
varscan fpfilter $finalVarInput $rcfile --output-file $finalOutput --dream3-settings ; 
done 


#for finalVarInput in *.hc.vcf ; do finalOutput=$(echo $finalVarInput"fpfiltered.vcf") ; rcfile=$(echo $finalVarInput".readcount") ; varscan fpfilter $finalVarInput $rcfile --ouput-file $finalOutput --dream3-settings ; done



#CLEAN UP SECTION
#rm $pileupName
#rm *.hc.vcf.readcount
#rm *.hc.vcf.var

