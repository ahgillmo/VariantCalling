#!/usr/bin/bash


##The purpose of this script is to generate the bamRead Counts for the SNP/SNV

SOMATIC_SNP_RC=$(echo $3".snp.SOMATIC.hc.readcount") #Using Tumor-Bam
echo "bam-readcount -q 1 -b 20 -l $3".snp.Somatic.hc.vcf.var" -f /tiered/smorrissy/tools/references/grch38_2-1-0/refdata-GRCh38-2.1.0/fasta/genome.fa $1 > $SOMATIC_SNP_RC" | bsub -n 1 -W 10:00 -R "span[hosts=1]"  -e BamReadCount.err -o BamReadCount.out -R "rusage[mem=1000]" -We 10:00

GERMLINE_SNP_RC=$(echo $3".snp.GERMLINE.hc.readcount") #Using Normal-Bam
echo "bam-readcount -q 1 -b 20 -l $3".snp.Germline.hc.vcf.var" -f /tiered/smorrissy/tools/references/grch38_2-1-0/refdata-GRCh38-2.1.0/fasta/genome.fa $2 > $GERMLINE_SNP_RC" | bsub -n 1 -W 10:00 -R "span[hosts=1]"  -e BamReadCount.err -o BamReadCount.out -R "rusage[mem=1000]" -We 10:00

LOH_SNP_RC=$(echo $3".snp.LOH.hc.readcount") #Using Normal-Bam
echo "bam-readcount -q 1 -b 20 -l $3".snp.LOH.hc.vcf.var" -f /tiered/smorrissy/tools/references/grch38_2-1-0/refdata-GRCh38-2.1.0/fasta/genome.fa $2 > $LOH_SNP_RC" | bsub -n 1 -W 10:00 -R "span[hosts=1]"  -e BamReadCount.err -o BamReadCount.out -R "rusage[mem=1000]" -We 10:00



