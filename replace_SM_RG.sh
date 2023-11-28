#!/usr/bin/bash
#SBATCH --partition=parallel,single,lattice
##SBATCH --partition=razi-bf,apophis-bf,theia-bf,pawson-bf
#SBATCH --job-name=SM_RG_changing_Bams
#SBATCH --mem=10G
##SBATCH --time=5:00:00
#SBATCH --time=1-00:00:00
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err


echo -e "This is the bam that is having the read group replaced" $1 #SM3762_BLOOD.lanemerged.sorted.markduplicates.bam
echo -e "This is what the sample name will be changed to:" $2 # EG SM3762BLOOD


#gatk AddOrReplaceReadGroups -I $1 -O $2".SMmerge.lanemerged.sorted.markduplicates.bam" -LB lib1 -PL illuminaNova -PU Sarcoma -SM $2 &&
gatk AddOrReplaceReadGroups -I $1 -O $2"_SM_sorted_dedup.bam" -LB lib1 -PL illuminaNova -PU Exomes -ID $2 -SM $2 &&
samtools index $2"_SM_sorted_dedup.bam"

echo "Completed changing of SampleName"



