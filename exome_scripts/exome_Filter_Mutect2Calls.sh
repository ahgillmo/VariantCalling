#!/usr/bin/bash
#SBATCH --partition=razi-bf,apophis-bf,theia-bf
#SBATCH --job-name=exome_filter_mutect2
#SBATCH --mem=10G
##SBATCH --time=7-00:00:00
#SBATCH --time=5:00:00
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err

echo -e "This is the input file:" $1

output_name=$(echo $1 | sed 's/_mutect.vcf.gz/_Merged.Filtered.Mutect2.vcf.gz/g') 
id=$(echo $1 | sed 's/_mutect.vcf.gz//g')

#Filter mutect2 
gatk FilterMutectCalls -R /bulk/morrissy_bulk/REFERENCES/human/hg38/genomeDecoy/fasta/genome.fa -V $1 -O $output_name --min-reads-per-strand 1 --unique-alt-read-count 4 #--min-allele-fraction 0.05

#Left-normalized mutect2
bcftools norm -m-both -f /bulk/morrissy_bulk/REFERENCES/human/hg38/genomeDecoy/fasta/genome.fa -Oz -o $id".Merged.Filtered.leftnormalized.Mutect2.vcf.gz" $output_name

#clean_up name
#rm $1
rm $output_name
rm $output_name".tbi"
