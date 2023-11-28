#!/bin/bash
#SBATCH --job-name=Exome_Mutect2
#SBATCH --partition=sherlock,cpu2013,cpu2019,cpu2021
#SBATCH --mem=70G
#SBATCH --time=7-00:00:00
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err
#SBATCH --cpus-per-task=16

#This will call and execute multisample mutect2 && add in the ID.
#TODO Add in the normal segment section: G34_N_ff_SM_sorted_dedup.bam.bai

while read -r linez ; do 
bams=$(ls /work/morrissy_lab/ahgillmo/Exome_genomic_data/bams/bams_with_sampleNames/*.bam | grep $linez | tr ' ' '\n' | awk '{print "-I""\t"$1}' | tr '\n' ' ') ;

#This is the bams input
#echo $bams ;
#echo $linez ;

allele=$(echo /work/morrissy_lab/ahgillmo/Exome_genomic_data/intersections_files/$linez"_intersection_of_varscan_strelka.vcf.gz")

Ref=$(echo /bulk/morrissy_bulk/REFERENCES/human/hg38/genomeDecoy/fasta/genome.fa)

Output=$(echo $1"_mutect.vcf.gz")

command=$(echo "gatk Mutect2 "-R" $Ref $bams "-O" $Output "-alleles" $allele" "--native-pair-hmm-threads" 16 "-normal" $2) ;
#command=$(echo "gatk Mutect2 "-R" $Ref $bams "-O" $Output "-L" $1 "-alleles" $allele" "--native-pair-hmm-threads" 16) ; 

#echo $command
eval "$command"

done < <(less ~/EXOME_gbm/EXOME_sample_patient.tsv | cut -f 2 | grep -v PatientID | sort -u | grep $1) 

#$bams" $linez $linez".mutect.vcf.gz" /work/morrissy_lab/ahgillmo/Exome_genomic_data/intersections_files/$linez"_intersection_of_varscan_strelka.vcf.gz" ; done < <(less ~/EXOME_gbm/EXOME_sample_patient.tsv | cut -f 2 | grep -v PatientID | sort -u | grep G01)


