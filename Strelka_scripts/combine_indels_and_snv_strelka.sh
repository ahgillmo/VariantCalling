#!/usr/bin/bash
#SBATCH --partition=razi-bf,apophis-bf,pawson-bf,synergy-bf,single,lattice,parallel
#SBATCH --job-name=combinevariants_Strelka
#SBATCH --mem=1G
#SBATCH --time=5:00:00
#SBATCH --output=%x.out
#SBATCH --error=%x.err


##Purpose: This script combines indels and snp from the same sample that has been called using strelka somatic pipeline

#The $1 or only input should be the sample identification
#Run this code script in the directory where somatic.indels.vcf.gz somatic.snvs.vcf.gz exist

###NOTE Specific to strelka there are tier 1 and tier2 reads (alternate allele and indel allele)

#bcftools annotate somatic.indels.vcf.gz somatic.snvs.vcf.gz | bcftools view -f PASS -o $1"_Strelka_snv_indel_combined_passed.vcf" -O v

bcftools concat -a somatic.snvs.vcf.gz somatic.indels.vcf.gz -d both | bcftools view -f PASS -Oz -o $1"_Strelka_snv_indel_combined_passed.vcf.gz" &&

bcftools index $1"_Strelka_snv_indel_combined_passed.vcf.gz"
#bgzip $1"_Strelka_snv_indel_combined_passed.vcf"


echo -e "Finished combining strelka somatic snvs and indels for sample"'\t' $1
