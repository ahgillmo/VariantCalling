#!/usr/bin/bash
#SBATCH --partition=single,lattice,parallel
#SBATCH --job-name=Mutect2_master_intervalCalling
#SBATCH --mem=6G
#SBATCH --time=10:00:00
#SBATCH --output=%x.out
#SBATCH --error=%x.err



echo -e "This is the tumor bam" $1
echo -e "This is the normal bam" $2
echo -e "This is the tumor ID" $3
echo -e "This in the interval list /home/ahgillmo/master_scripts_slurm/GATK_mutect2_scripts/Broad_hg38_wgs_callingregions.interval.list" 

#NOTE since I combined multiple lanes and kept their laneID as the RG I need to specify all RG in the bam. AKA Lane001, Lane002, Lane003, Lane004
echo -e "This is the normal ID" $4

#echo -e "This is the normal ID" $5
#echo -e "This is the normal ID" $6
#echo -e "This is the normal ID" $7

while read -r line ; do

sbatch /home/ahgillmo/master_scripts_slurm/GATK_mutect2_scripts/runGatk_Mutec2_SomaticCalling_byIntervalList.sh $1 $2 $3 $line $4 ;

done < /home/ahgillmo/master_scripts_slurm/GATK_mutect2_scripts/Broad_hg38_wgs_callingregions.interval.list
