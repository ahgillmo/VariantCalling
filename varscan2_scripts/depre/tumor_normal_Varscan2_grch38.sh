#!/usr/bin/bash
##SBATCH --partition=razi-bf,apophis-bf,theia-bf
#SBATCH --partition=parallel
#SBATCH --job-name=Varscan_snv_loh_germline
#SBATCH --mem=22G
#SBATCH --time=3-00:00:00
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err

echo -e "The Tumor bam is:" $1
echo -e "The Normal Bam is:"$2
echo -e "The tumor id:" $3
echo -e "The normal id is:"$4

normalBam=$2
tumorBam=$1

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
indel_Germline_HCName=$(echo $tumorID".indel.Germline.hc.vcf")
indel_LOH_HCName=$(echo $tumorID".indel.LOH.hc.vcf")
####

allVCFName=$(echo $tumorID".all.vcf");
####

#Step 1 and 2 will mpileup and call basic somatic variants in two categories indel and SNPs 
#The map quality is set with -q (18) and the map quality is set with -Q (20)
samtools mpileup -q 18 -Q 20 -B -f /home/ahgillmo/references/grch38_2-1-0/refdata-GRCh38-2.1.0/fasta/genome.fa $2 $1 | /home/ahgillmo/miniconda3/bin/varscan somatic /dev/stdin -mpileup --min-var-freq 0.05 --output-snp $snpName --output-indel $indelName --strand-filter 1 --output-vcf 1

#bcftools mpileup -q 18 -Q 20 -B -f /home/ahgillmo/references/grch38_2-1-0/refdata-GRCh38-2.1.0/fasta/genome.fa $2 $1 | /home/ahgillmo/miniconda3/bin/varscan somatic /dev/stdin -mpileup --min-var-freq 0.05 --output-snp $snpName --output-indel $indelName --strand-filter 1 --output-vcf 1

###XXX Not an immediate change but should be pursued eventually!
#OPTIONAL merge and sort to get all.vcf: Default is to skip this step and proceed individually with SNP and INDEL
#bgzip -i $snpName
#bgzip -i $indelName
#bcftools merge snp.vcf.gz indel.vcf.gz | sort > $3".all.vcf"

#Step 4
varscan processSomatic $snpName --min-tumor-freq 0.05
varscan processSomatic $indelName --min-tumor-freq 0.05

#varscan processSomatic $3".all.vcf" --min-tumor-freq 0.05

bgzip $snpName
tabix $snpName
bgzip $indelName
tabix $indelName

bcftools concat -Ov -a -R /home/ahgillmo/references/broad_hg38_wgs_callingregions.interval.bed -o $3".varscan.hc.vcf" $snpName $indelName

#Step 5
###Generate bed file for coordinates for SNP and indels 
#These coordinate are use for generating bam read counts

for file in *.hc.vcf ; do 
bedName=$(echo $file".var") && 
#awk 'BEGIN {OFS="\t"} {if (!/^#/) { isDel=(length($4) > length($5)) ? 1 : 0; print $1,($2+isDel),($2+isDel); }}' $file > $bedName ; done
awk 'BEGIN {OFS="\t"} {if (!/^#/) { InsDelLen=(length($4) > length($5)) ? length($4) : length($5); print $1,($2-1),($2-1+InsDelLen); }}' $file > $bedName ; done

#FOR SNV + INDELS should work for either ###XXX testing ATM
#awk 'BEGIN {OFS="\t"} {if (!/^#/) { InsDelLen=(length($4) > length($5)) ? length($4) : length($5); print $1,($2-1),($2-1+InsDelLen); }}' all.vcf > all.bed


#Step 6
#Bam readCount for somatic, germline, LOH: Parameters are set for scCNV WG-sequencing
#SOMATIC_RC=$(echo $3".all.SOMATIC.hc.readcount")
#bam-readcount -q 1 -b 20 -l all.Somatic.hc.var -f /tiered/smorrissy/tools/references/grch38_2-1-0/refdata-GRCh38-2.1.0/fasta/genome.fa $1 > all.Somatic.hc.readcount

#GERMLINE_RC=$(echo $3".all.GERMLINE.hc.readcount")
#bam-readcount -q 1 -b 20 -l all.Germline.hc.var -f /tiered/smorrissy/tools/references/grch38_2-1-0/refdata-GRCh38-2.1.0/fasta/genome.fa $2 > all.Germline.hc.readcount

#LOH_RC=$(echo $3".all.LOH.hc.readcount")
#bam-readcount -q 1 -b 20 -l all.LOH.hc.var -f /tiered/smorrissy/tools/references/grch38_2-1-0/refdata-GRCh38-2.1.0/fasta/genome.fa $2 > all.LOH.hc.readcount

#$3 is the ID for the tumlor

SOMATIC_SNP_RC=$(echo $3".snp.somatic.hc.readcount") #Using Tumor-Bam
bam-readcount -w 1 -q 1 -b 20 -l $3".snp.Somatic.hc.vcf.var" -f /home/ahgillmo/references/grch38_2-1-0/refdata-GRCh38-2.1.0/fasta/genome.fa $1 > $SOMATIC_SNP_RC

#GERMLINE_SNP_RC=$(echo $3".snp.germline.hc.readcount") #Using Normal-Bam 
#bam-readcount -q 1 -b 20 -l $3".snp.Germline.hc.vcf.var" -f /home/ahgillmo/references/grch38_2-1-0/refdata-GRCh38-2.1.0/fasta/genome.fa $2 > $GERMLINE_SNP_RC

#LOH_SNP_RC=$(echo $3".snp.LOH.hc.readcount") #Using Normal-Bam
#bam-readcount -q 1 -b 20 -l $3".snp.LOH.hc.vcf.var" -f /home/ahgillmo/references/grch38_2-1-0/refdata-GRCh38-2.1.0/fasta/genome.fa $2 > $LOH_SNP_RC 

SOMATIC_INDEL_RC=$(echo $3".indel.somatic.hc.readcount") #Using Tumor-Bam
bam-readcount -w 1 -q 1 -b 20 -l $3".snp.Somatic.hc.vcf.var" -f /home/ahgillmo/references/grch38_2-1-0/refdata-GRCh38-2.1.0/fasta/genome.fa $1 > $SOMATIC_INDEL_RC

#GERMLINE_INDEL_RC=$(echo $3".indel.germline.hc.readcount") #Using Normal-Bam
#bam-readcount -q 1 -b 20 -l $3".snp.Germline.hc.vcf.var" -f /home/ahgillmo/references/grch38_2-1-0/refdata-GRCh38-2.1.0/fasta/genome.fa $2 > $GERMLINE_INDEL_RC

#LOH_INDEL_RC=$(echo $3".indel.LOH.hc.readcount") #Using Normal-Bam
#bam-readcount -q 1 -b 20 -l $3".indel.LOH.hc.vcf.var" -f /home/ahgillmo/references/grch38_2-1-0/refdata-GRCh38-2.1.0/fasta/genome.fa $2 > $LOH_INDEL_RC


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
#SNP_Somatic_Exclusioncc
varscan fpfilter $Snp_Somatic_HCName $SOMATIC_SNP_RC --output-file $SOMATIC_SNP_RC".fpfilter.vcf" --dream3-settings 1 --keep-failures

#varscan fpfilter $Snp_Germline_HCName $GERMLINE_SNP_RC --output-file $GERMLINE_SNP_RC".fpfilter.vcf" --dream3-settings 1 --keep-failures

#varscan fpfilter $Snp_LOH_HCName $LOH_SNP_RC --output-file $LOH_SNP_RC".fpfilter.vcf" --dream3-settings 1 --keep-failures

varscan fpfilter $indel_Somatic_HCName $SOMATIC_INDEL_RC --output-file $SOMATIC_INDEL_RC".fpfilter.vcf" --dream3-settings 1 --keep-failures



###
#bgzip $SOMATIC_INDEL_RC".fpfilter.vcf"
#tabix $SOMATIC_INDEL_RC".fpfilter.vcf"
#bgzip $SOMATIC_SNP_RC".fpfilter.vcf"
#tabix $SOMATIC_INDEL_RC".fpfilter.vcf"

#TODO
#1) combine vcfs before fpfilter
#2) bam-readcount combined hc.vcf
#3) fpfilter now
#4) Clean up


#varscan fpfilter $indel_Germline_HCName $GERMLINE_INDEL_RC --output-file $GERMLINE_INDEL_RC".fpfilter.vcf" --dream3-settings 1 --keep-failures

#varscan fpfilter $indel_LOH_HCName $LOH_INDEL_RC --output-file $LOH_INDEL_RC".fpfilter.vcf" --dream3-settings 1 --keep-failures

##TODO Add allVCF version here!
#varscan fpfilter $3".all.hc.vcf" $3".all.hc.vcf.var --output-file $3".all.fpfilter.vcf" --dream3-settings 1 --keep-failures

#1) Merge $SOMATIC_SNP_RC".fpfilter.vcf + $SOMATIC_INDEL_RC".fpfilter.vcf"
#2) Leftalign and single variant per line
#3) Clean up

echo -e "Completed running Varscan on tumor: "$3" and normal "$4
#TODO CLEAN UP SECTION --> Keeping only the ".fpfiler.vcf"


##TODO
#1) left align and ensure one variant per-line and merge  $SOMATIC_SNP_RC".fpfilter.vcf" && $SOMATIC_INDEL_RC".fpfilter.vcf"
 

#rm *.var 
#rm *.readcount
#rm $snpName
#rm $indelName

#rm *.hc.vcf ###XXX maybe keep these? IDK the fpfilter.vcf are probably better
