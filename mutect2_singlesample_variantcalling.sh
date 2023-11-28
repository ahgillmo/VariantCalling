#!/usr/bin/bash
#SBATCH --partition=single,lattice,parallel
#SBATCH --job-name=Submission_Mutect2_Sarcoma_multisample
#SBATCH --mem=6G
#SBATCH --time=7-00:00:00
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err


#$1 or $line is the chromomse region to focus on
#$2 is the sample (likely a tumor sample without matched normal)

#Here we do single-sample calling

while read -r line ; do

#OutputVCF=$(echo SM3762"_"SM3762Blood"_"$line".mutect.vcf.gz");
sbatch /home/ahgillmo/master_scripts_slurm/GATK_mutect2_scripts/chromosome_submission_singlesample.sh $line $1;

done < /home/ahgillmo/references/SuperSplit_Broad_hg38_wgs_callingregions.interval.list

