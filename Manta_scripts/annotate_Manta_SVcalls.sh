#!/usr/bin/bash
##SBATCH --partition=apophis-bf,pawson-bf
#SBATCH --partition=single,lattice,parallel
#SBATCH --job-name=Manta_tumorSV
#SBATCH --mem=10G
#SBATCH --time=7-00:00:00
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err

# for file in SM3640_PATIENT_TUMOR.vcf.gz ; do id=$(echo $file | sed 's/.vcf.gz//') && echo -e "SampleID"'\t'"Gene"'\t'Function'\t'Chrom'\t'Pos'\t'MantaID'\t'MantaMatePos'\t'"Filter"'\t'"Format" > $id"_Annotated_Manta_fusions.tsv" && bedtools intersect -wb -b <(zless $file | egrep -v '#' |egrep -v hs38| awk '{print $1"\t"$2"\t"$2"\t"$0}' | egrep -v random | less -S) -a <(less ~/references/genes_and_GTFS/Homo_sapiens.GRCh38.Ensemble100.FullGeneAnnotations.txt | awk '{print $1"\t"$2"\t"$3"\t"$7"\t"$8}') | cut -f4- | cut -f 1,2,6,7,8,10,12,13 | awk -v ID=$id '{print ID"\t"$0}' >> $id"_Annotated_Manta_fusions.tsv" ; done


id=$(echo $1 | sed 's/.vcf.gz//') && 

echo -e "SampleID"'\t'"Gene"'\t'Function'\t'Chrom'\t'Pos'\t'MantaID'\t'MantaMatePos'\t'"Filter"'\t'"Format" > $id"_Annotated_Manta_fusions.tsv" && 

bedtools intersect -wb -b <(zless $1 | egrep -v '#' |egrep -v hs38| awk '{print $1"\t"$2"\t"$2"\t"$0}' | egrep -v random | less -S) -a <(less ~/references/genes_and_GTFS/Homo_sapiens.GRCh38.Ensemble100.FullGeneAnnotations.txt | awk '{print $1"\t"$2"\t"$3"\t"$7"\t"$8}') | cut -f4- | cut -f 1,2,6,7,8,10,12,13 | awk -v ID=$id '{print ID"\t"$0}' >> $id"_Annotated_Manta_fusions.tsv"


#Annotate the file with somaticScore
bash /home/ahgillmo/master_scripts_slurm/Manta_scripts/somaticScore_annotator.sh $id"_Annotated_Manta_fusions.tsv" $2



#ZXXXX This is aa work in progress 
#id=SM3762T17 && echo -e "SampleID"'\t'"Gene"'\t'Function'\t'Chrom'\t'Pos'\t'MantaID'\t'MantaMatePos'\t'"Filter"'\t'"Format" > $id"_Annotated_Manta_fusions.tsv" && bedtools intersect -wb -b <(zless somaticSV.vcf.gz | egrep -v '#' |egrep -v hs38| awk '{print $1"\t"$2"\t"$2"\t"$0}' | egrep -v random | less -S) -a <(less ~/references/genes_and_GTFS/Homo_sapiens.GRCh38.Ensemble100.FullGeneAnnotations.txt | awk '{print $1"\t"$2"\t"$3"\t"$7"\t"$8}') | cut -f4- | cut -f 1,2,6,7,8,10,12,13 | awk -v ID=$id '{print ID"\t"$0}' >> $id"_Annotated_Manta_fusions.tsv"
