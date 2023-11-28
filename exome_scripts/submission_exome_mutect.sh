#!/usr/bin/bash
#SBATCH --partition=single
#SBATCH --job-name=Exome_submission_Mutect2
#SBATCH --mem=2G
#SBATCH --time=1-00:00:00
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err


while read -r line ; do

#OutputVCF=$(echo SM3762"_"SM3762Blood"_"$line".mutect.vcf.gz");
echo sbatch ~/master_scripts_slurm/GATK_mutect2_scripts/exome_scripts/mutect2_exome_secondary.sh $id $GL_Name; 



done < /home/ahgillmo/references/exome_capture_kits/xgen-exome-research-panel-v2-targets-hg38.bed.list
