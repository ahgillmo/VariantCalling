#!/usr/bin/bash
#SBATCH --partition=single
#SBATCH --job-name=Exome_submission_Mutect2
#SBATCH --mem=2G
#SBATCH --time=1-00:00:00
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err


#$1 or $line is the chromomse region to focus on
#$2 is the sample (likely a tumor sample without matched normal)

#Here we do single-sample calling

while read -r line ; do

#OutputVCF=$(echo SM3762"_"SM3762Blood"_"$line".mutect.vcf.gz");
NID=$(echo sbatch /home/ahgillmo/master_scripts_slurm/GATK_mutect2_scripts/exome_scripts/exome_chromosome_submission.sh $line $1 $2) ;

echo $NID ;


done < /home/ahgillmo/references/exome_capture_kits/xgen-exome-research-panel-v2-targets-hg38.bed.list

#REFERENCE FASTAS
#/bulk/morrissy_bulk/REFERENCES/human/hg38/genomeDecoy/fasta/genome.fa
#BED FILE
#/work/morrissy_lab/heewon/EXOME/resources/xgen-exome-research-panel-v2-targets-hg38.bed
#WGS list file 
