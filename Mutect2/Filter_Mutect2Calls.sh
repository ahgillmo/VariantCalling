#!/usr/bin/bash
#SBATCH --partition=cpu2022-bf24,cpu2021-bf24,cpu2019-bf05,cpu2017-bf05
##SBATCH --partition=single,lattice
#SBATCH --job-name=Processing_Mutect2
#SBATCH --mem=10G
##SBATCH --time=7-00:00:00
#SBATCH --time=5:00:00
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err


echo -e "The Sample id is:"$1


StatsToMerge=$(ls *.stats | awk '{print "--stats"" "$0}' | xargs)


MergeStatsOutname=$(basename $PWD | awk '{print $0".merged.stats"}');


gatk MergeMutectStats $StatsToMerge -O $MergeStatsOutname



for file in *.mutect.vcf.gz; do

Outname=$(echo $file | sed 's/.mutect.vcf.gz/.Filtered.mutect.vcf.gz/g');

gatk FilterMutectCalls -R /home/ahgillmo/references/grch38_2-1-0/refdata-GRCh38-2.1.0/fasta/genome.fa --filtering-stats $MergeStatsOutname -V $file -O $Outname --min-reads-per-strand 4 --unique-alt-read-count 6 #--min-allele-fraction 0.05

echo -e "I have Filtered" $file ;
done


#Completed filtering

ls *.Filtered.mutect.vcf.gz > $1".List_of_Filtered.mutect2.calls.list"

gatk MergeVcfs -I $1".List_of_Filtered.mutect2.calls.list" -O $1".Merged.Filtered.Mutect2.vcf.gz"

#TODO turn variants from multivariant per loci to single variant per loci
bcftools norm -m-both -f /home/ahgillmo/references/grch38_2-1-0/refdata-GRCh38-2.1.0/fasta/genome.fa -Oz -o $1".Merged.Filtered.leftnormalized.Mutect2.vcf.gz" $1".Merged.Filtered.Mutect2.vcf.gz"
