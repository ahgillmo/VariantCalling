#!/usr/bin/bash
#SBATCH --partition=parallel
#SBATCH --job-name=splitbyCHR_Strelka_somatic_exectute
#SBATCH --mem=10G
#SBATCH --time=1-00:00:00
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err
##SBATCH --cpus-per-task=80


#for x in chr1 chr2 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chr10 chr11 chr12 chr13 chr14 chr15 chr16 chr17 chr18 chr19 chr20 chr21 chr22 chrX chrY ;

samtools view -b $1 $2 > $3"_"$2".bam" 
#samtools view -b normalBam $x > $2"_"$x".bam" &&

#done




