#!/bin/bash
#SBATCH --job-name=Mutect2_Singlesample
#SBATCH --partition=sherlock,cpu2013,cpu2019,cpu2021
#SBATCH --mem=10G
#SBATCH --time=7-00:00:00
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err
#SBATCH --cpus-per-task=8

OutputVCF=$(echo $2"_"$1".mutect.vcf.gz") 

#echo -e "The input region to call on is:"$1
#echo -e "The bam to call on (singleSample is:"$2

gatk Mutect2 -R /home/ahgillmo/references/grch38_2-1-0/refdata-GRCh38-2.1.0/fasta/genome.fa \
-I $2 \
-L $1 \
-O $OutputVCF \
--native-pair-hmm-threads 8
