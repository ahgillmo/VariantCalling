#!/usr/bin/bash
#SBATCH --partition=razi-bf,apophis-bf,pawson-bf,synergy-bf,single,lattice,parallel
#SBATCH --job-name=combinevariants_Strelka
#SBATCH --mem=1G
#SBATCH --time=5:00:00
#SBATCH --output=%x.out
#SBATCH --error=%x.err

echo -e "This is the first argument:"$1

#NOT YET WORKING 


#COMBINE the indels and snv in strelka
bash /home/ahgillmo/master_scripts_slurm/Strelka_scripts/combine_indels_and_snv_strelka.sh $1

#Strelka snv && indels
while read -r line ; do NN=$(ls $line"_"*/results/variants/*Strelka_snv_indel_combined_passed.vcf.gz) && sample=$(echo $NN) && bcftools concat -a $sample | bcftools view -f PASS -Oz -o $line"_Strelka_perpatient.vcf.gz" ; done < <(less ~/EXOME_gbm/EXOME_sample_patient.tsv | cut -f 2 | grep -v PatientID | sort -u | grep G01)

#




