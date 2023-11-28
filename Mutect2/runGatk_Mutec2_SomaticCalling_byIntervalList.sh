#!/usr/bin/bash
#SBATCH --partition=single,lattice,parallel
#SBATCH --job-name=Mutect2_interval
#SBATCH --mem=3G
#SBATCH --time=7-00:00:00
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err


#echo -e "This is the tumor bam" $1
#echo -e "This isthe normal bam" $2
#echo -e "This is the tumor ID" $3
#echo -e "This is the normal ID" $4
echo -e "This is the interval being submitted["$4"]From /home/ahgillmo/master_scripts_slurm/GATK_mutect2_scripts/Broad_hg38_wgs_callingregions.interval.list"

outputVCF=$(echo $3"_"$4".mutect.vcf.gz")

#gatk Mutect2 --native-pair-hmm-threads 4 -R /home/ahgillmo/references/grch38_2-1-0/refdata-GRCh38-2.1.0/fasta/genome.fa -I $1 -I $2 -L $4 -normal $5 -normal $6 -normal $7 -normal $8 -O $outputVC

gatk Mutect2 --native-pair-hmm-threads 4 -R /home/ahgillmo/references/grch38_2-1-0/refdata-GRCh38-2.1.0/fasta/genome.fa -I $1 -I $2 -L $4 -normal $5 -O $outputVCF
