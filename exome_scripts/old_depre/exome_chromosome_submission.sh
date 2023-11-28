#!/bin/bash
#SBATCH --job-name=Exome_Mutect2
#SBATCH --partition=sherlock,cpu2013,cpu2019,cpu2021
#SBATCH --mem=10G
#SBATCH --time=7-00:00:00
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err
#SBATCH --cpus-per-task=8

OutputVCF=$(echo $3"_"$1".mutect.vcf.gz") 

#echo -e "The input region to call on is:"$1
#echo -e "The bam to call on (singleSample is:"$2


echo gatk Mutect2 -R /bulk/morrissy_bulk/REFERENCES/human/hg38/genomeDecoy/fasta/genome.fa $2 -L $1 -O $OutputVCF --native-pair-hmm-threads 8 -alleles /work/morrissy_lab/ahgillmo/Exome_genomic_data/intersections_files/$3"_intersection_of_varscan_strelka.vcf.gz"
#echo $cmd


