#!/usr/bin/bash


#for x in chr1 chr2 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chr10 chr11 chr12 chr13 chr14 chr15 chr16 chr17 chr18 chr19 chr20 chr21 chr22 chrX chrY ;
for x in chr21 chrX ;
do echo $x ; 

samtools view -b tumorBam $x > "tumorbam"$x".bam" &&
samtools view -b normalBam $x > "normalBam"$x".bam" &&


done


tumorBam=/work/morrissy_lab/ahgillmo/Synergy_Homedir/adultGBM/ExecutedLR/SM4218_Bams/GSC3_phased_possorted_bam.bam 
normalBam=/work/morrissy_lab/ahgillmo/Synergy_Homedir/adultGBM/ExecutedLR/SM4218_Bams/SM4218CD45_phased_possorted_bam.bam 
tumorSmallIndels=/work/morrissy_lab/ahgillmo/Synergy_Homedir/adultGBM/ExecutedLR/Manta_SM4218/GSC3/MantaWorkflow/results/variants/candidateSmallIndels.vcf.gz
