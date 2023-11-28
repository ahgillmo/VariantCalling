#!/usr/bin/bash

#NOTE TUMOR IS $1 and NORMAL is $2
#NOTE TUMORID is $3 and NORMALID is $4
###Tumor normal callign for multiple myeloma using varscan2: Sequencing is WGS single cell 

normalBam=$2
tumorBam=$1

#normalID=$(echo $2 | sed 's/possorted_bam.bam//g')
#tumorID=$(echo $1 | sed 's/possorted_bam.bam//g')

tumorID=$3
normalID=$4

###
pileupName=$(echo $tumorID"_"$normalID".mpileup"); 



tumorPileup=$(echo $3".mpileup");
normalPileup=$(echo $4".mpileup");
###
somaticPrefix=$(echo $tumorID"_"$normalID) ;

errName=$(echo $tumorID"_"$normalID".err");
outName=$(echo $tumorID"_"$normalID".out");

indelName=$(echo $tumorID".indel.vcf") ;
snpName=$(echo $tumorID".snp.vcf") ;


###Names for varscan fpfilter
Snp_Somatic_HCName=$(echo $tumorID".snp.Somatic.hc.vcf")
Snp_Germline_HCName=$(echo $tumorID".snp.Germline.hc.vcf")
Snp_LOH_HCName=$(echo $tumorID".snp.LOH.hc.vcf") 

indel_Somatic_HCName=$(echo $tumorID".indel.Somatic.hc.vcf")
indel_Germline_HCName=$(echo $tumorID".indel.Germline.hc.vcf")                                                          indel_LOH_HCName=$(echo $tumorID".indel.LOH.hc.vcf")
####

allVCFName=$(echo $tumorID".all.vcf");
####

#Step 1 <$1 must be normal and $1 must be tumor>
#/home/aaronhg/miniconda3/bin/samtools mpileup -B -f /tiered/smorrissy/tools/references/grch38_2-1-0/refdata-GRCh38-2.1.0/fasta/genome.fa -q 30 -Q 20 $2 $1 > $pileupName &&

#/home/aaronhg/miniconda3/bin/bcftools mpileup -B -f /tiered/smorrissy/tools/references/grch38_2-1-0/refdata-GRCh38-2.1.0/fasta/genome.fa -q 30 -Q 20 $2 $1 > $pileupName 


#Tumor
#/home/aaronhg/miniconda3/bin/bcftools mpileup -B -f /tiered/smorrissy/tools/references/grch38_2-1-0/refdata-GRCh38-2.1.0/fasta/genome.fa -q 30 -Q 20 $1 > $tumorPileup &&

#Normal (On their own)
#/home/aaronhg/miniconda3/bin/bcftools mpileup -B -f /tiered/smorrissy/tools/references/grch38_2-1-0/refdata-GRCh38-2.1.0/fasta/genome.fa -q 30 -Q 20 $2 > $normalPileup &&


#Step 2
#/home/aaronhg/miniconda3/bin/varscan somatic $somaticPrefix $pileupName --mpileup 1 --min-coverage-normal 8 --min-coverage-tumor 6 --min-var-freq 0.05 --output-snp $snpName --output-indel $indelName --strand-filter 1 --output-vcf 1 

#Step 1 and 2 combined {} ::: should 
samtools mpileup -q 30 -Q 20 -B -f /tiered/smorrissy/tools/references/hg19/ucsc.hg19.fasta $2 $1 | /home/aaronhg/miniconda3/bin/varscan somatic /dev/stdin -mpileup --min-var-freq 0.05 --output-snp $snpName --output-indel $indelName --strand-filter 1 --output-vcf 1


#Step 2 combined via individual pileups
#/home/aaronhg/miniconda3/bin/varscan somatic $normalPileup $tumorPileup $somaticPrefix --min-coverage-normal 8 --min-coverage-tumor 6 --min-var-freq 0.05 --output-snp $snpName --output-indel $indelName --strand-filter 1 --output-vcf 1


#Removed the snp and indel vcf outs
#/home/aaronhg/miniconda3/bin/varscan somatic $somaticPredix $pileupName --mpileup 1 --min-coverage-normal 8 --min-coverage-tumor 6 --min-var-freq 0.08 --strand-filter 0 --output-vcf 1

#TODO merge and sort to get all.vcf
#Step 3 <I might skip this step and proceed individually with SNP and INDEL
#bcftools vcf-merge snp.vcf indel.vcf | sort > $allVCFName


#Step 4
varscan processSomatic $snpName --min-tumor-freq 0.05

varscan processSomatic $indelName --min-tumor-freq 0.05


#Step 5
###Generate bed file for coordinates
#awk 'BEGIN {OFS="\t"} {if (!/^#/) { isDel=(length($4) > length($5)) ? 1 : 0; print $1,($2+isDel),($2+isDel); }}' all.Somatic.hc.vcf > all.Somatic.hc.var

#for file in *.hc.vcf ;
#bedName=$(echo $file".var") ;
#do awk 'BEGIN {OFS="\t"} {if (!/^#/) { isDel=(length($4) > length($5)) ? 1 : 0; print $1,($2+isDel),($2+isDel); }}' $file > $bedName ;
#done

for file in *.hc.vcf ; do 
bedName=$(echo $file".var") && 
awk 'BEGIN {OFS="\t"} {if (!/^#/) { isDel=(length($4) > length($5)) ? 1 : 0; print $1,($2+isDel),($2+isDel); }}' $file > $bedName ; done

#Step 6
#Bam readCount for somatic, germline, LOH: Parameters are set for scCNV WG-sequencing
#SOMATIC_RC=$(echo $3".all.SOMATIC.hc.readcount")
#bam-readcount -q 1 -b 20 -l all.Somatic.hc.var -f /tiered/smorrissy/tools/references/grch38_2-1-0/refdata-GRCh38-2.1.0/fasta/genome.fa $1 > all.Somatic.hc.readcount

#GERMLINE_RC=$(echo $3".all.GERMLINE.hc.readcount")
#bam-readcount -q 1 -b 20 -l all.Germline.hc.var -f /tiered/smorrissy/tools/references/grch38_2-1-0/refdata-GRCh38-2.1.0/fasta/genome.fa $2 > all.Germline.hc.readcount

#LOH_RC=$(echo $3".all.LOH.hc.readcount")
#bam-readcount -q 1 -b 20 -l all.LOH.hc.var -f /tiered/smorrissy/tools/references/grch38_2-1-0/refdata-GRCh38-2.1.0/fasta/genome.fa $2 > all.LOH.hc.readcount

#$3 is the ID for the tumlor

SOMATIC_SNP_RC=$(echo $3".snp.SOMATIC.hc.readcount") #Using Tumor-Bam
bam-readcount -q 1 -b 20 -l $3".snp.Somatic.hc.vcf.var" -f /tiered/smorrissy/tools/references/grch38_2-1-0/refdata-GRCh38-2.1.0/fasta/genome.fa $1 > $SOMATIC_SNP_RC

GERMLINE_SNP_RC=$(echo $3".snp.GERMLINE.hc.readcount") #Using Normal-Bam 
bam-readcount -q 1 -b 20 -l $3".snp.Germline.hc.vcf.var" -f /tiered/smorrissy/tools/references/grch38_2-1-0/refdata-GRCh38-2.1.0/fasta/genome.fa $2 > $GERMLINE_SNP_RC

LOH_SNP_RC=$(echo $3".snp.LOH.hc.readcount") #Using Normal-Bam
bam-readcount -q 1 -b 20 -l $3".snp.LOH.hc.vcf.var" -f /tiered/smorrissy/tools/references/grch38_2-1-0/refdata-GRCh38-2.1.0/fasta/genome.fa $2 > $LOH_SNP_RC 

SOMATIC_INDEL_RC=$(echo $3".indel.SOMATIC.hc.readcount") #Using Tumor-Bam
bam-readcount -q 1 -b 20 -l $3".snp.Somatic.hc.vcf.var" -f /tiered/smorrissy/tools/references/grch38_2-1-0/refdata-GRCh38-2.1.0/fasta/genome.fa $1 > $SOMATIC_INDEL_RC

GERMLINE_INDEL_RC=$(echo $3".indel.GERMLINE.hc.readcount") #Using Normal-Bam
bam-readcount -q 1 -b 20 -l $3".snp.Germline.hc.vcf.var" -f /tiered/smorrissy/tools/references/grch38_2-1-0/refdata-GRCh38-2.1.0/fasta/genome.fa $2 > $GERMLINE_INDEL_RC

LOH_INDEL_RC=$(echo $3".indel.LOH.hc.readcount") #Using Normal-Bam
bam-readcount -q 1 -b 20 -l $3".indel.LOH.hc.vcf.var" -f /tiered/smorrissy/tools/references/grch38_2-1-0/refdata-GRCh38-2.1.0/fasta/genome.fa $2 > $LOH_INDEL_RC


#$1 must be the tumor and $2 must be the normal
#for varInput in *.hc.vcf ; do
#bedNameIn=$(echo $varInput".var") ;
#readcount=$(echo $varInput".readcount") ;
#bam-readcount -q 1 -b 20 -l $bedNameIn -f /tiered/smorrissy/tools/references/grch38_2-1-0/refdata-GRCh38-2.1.0/fasta/genome.fa $2 > $readcount ;
#done


#for varInput in *.hc.vcf ; do bedNameIn=$(echo $varInput".var") ; readcount=$(echo $varInput".readcount") ; bam-readcount -q 40 -b 20 -l $bedNameIn -f /tiered/smorrissy/tools/references/grch38_2-1-0/refdata-GRCh38-2.1.0/fasta/genome.fa $2 > $readcount ; done

#Step 7 call fpfilter! on Somatic snp
#for finalVarInput in *snp.Somatic.hc.vcf ; do finalOutput=$(echo $finalVarInput".fpfiltered.vcf") ; varscan fpfilter $finalVarInput $SOMATIC_SNP_RC --output-file $finalOutput --dream3-settings ; done

## step 7 fpfilter on all the high confidence vcfs
#SNP_Somatic_Exclusion
varscan fpfilter $Snp_Somatic_HCName $SOMATIC_SNP_RC --output-file $SOMATIC_SNP_RC".fpfilter.vcf" --dream3-settings

varscan fpfilter $Snp_Germline_HCName $GERMLINE_SNP_RC --output-file $GERMLINE_SNP_RC".fpfilter.vcf" --dream3-settings

varscan fpfilter $Snp_LOH_HCName $LOH_SNP_RC --output-file $LOH_SNP_RC".fpfilter.vcf" --dream3-settings

varscan fpfilter $indel_Somatic_HCName $SOMATIC_INDEL_RC --output-file $SOMATIC_INDEL_RC".fpfilter.vcf" --dream3-settings

varscan fpfilter $indel_Germline_HCName $GERMLINE_INDEL_RC --output-file $GERMLINE_INDEL_RC".fpfilter.vcf" --dream3-settings

varscan fpfilter $indel_LOH_HCName $LOH_INDEL_RC --output-file $LOH_INDEL_RC".fpfilter.vcf" --dream3-settings


#CLEAN UP SECTION
#rm $pileupName
#rm *.hc.vcf.readcount
#rm *.hc.vcf.var
