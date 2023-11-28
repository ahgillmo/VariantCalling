#!/usr/bin/bash
#SBATCH --partition=single,lattice,parallel
#SBATCH --job-name=Splitting_and_Submitting_Mutect2VCF
#SBATCH --mem=8G
#SBATCH --time=24:00:00
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err

#TODO split vcf in the chromosome fils


for ch in chr1 chr2 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chr10 chr11 chr12 chr13 chr14 chr15 chr16 chr17 chr18 chr19 chr20 chr21 chr22 chrX chrY ; do 

less $1 | egrep -v '#' | grep PASS | awk -v chr=$ch '$1==chr' > $1"_"$ch
sbatch /home/ahgillmo/master_scripts_slurm/GATK_mutect2_scripts/process_Filtered_Mutect2_vcfs.sh $1"_"$ch $1 &&

#rm $1"_"$ch

echo -e $1"_"$ch '\t' is submitted for processing ;
done



###Alternative method is to use split###

#split -l 100000 --additional-suffix .splitted.txt $1

#for file in *.splitted.txt ; do
#less $file | egrep -v '#' | grep PASS > $file".preprocess.txt" &&
#sbatch /home/ahgillmo/master_scripts_slurm/GATK_mutect2_scripts/process_Filtered_Mutect2_vcfs.sh $file".preprocess.txt" $1 ; 

#done


