#!/usr/bin/bash
#SBATCH --partition=cpu2013,cpu2019,cpu2021
#SBATCH --job-name=Strelka_exome
#SBATCH --mem=22G
#SBATCH --time=7-00:00:00
##SBATCH --time=5:00:00
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err
#SBATCH --cpus-per-task=20

##This codes conduct somatic variants calling using strelka from tumor normal sequencing. It also takes manta candidate indels to use a basis for calling indels. #Requires activation of the strelka_enviroment to work (python 2.7)

source activate strelka_env

echo -e "The tumor bam is "'\t'$1
echo -e "The normal bam is "'\t'$2
echo -e "The candidate indels from Manta are "'\t'$3
echo -e "The SampleIdentification is"'\t'$4

#bash /home/ahgillmo/strelka_installation/strelka-2.9.10.centos6_x86_64/bin/runStrelkaSomaticWorkflowDemo.bash

#outdir=$(echo $1 | sed 's/\//\t/g' | sed 's/_SM_sorted_dedup.bam/_strelka/g')

python /home/ahgillmo/strelka_installation/strelka-2.9.10.centos6_x86_64/bin/configureStrelkaSomaticWorkflow.py --tumorBam $1 --normalBam $2 --exome --callRegions /home/ahgillmo/references/exome_capture_kits/xgen-exome-research-panel-v2-targets-hg38.bed.gz --referenceFasta /bulk/morrissy_bulk/REFERENCES/human/hg38/genomeDecoy/fasta/genome.fa --runDir $4 --indelCandidates $3 &&


echo "Finished Strelka script generation  :)" && 

#python $PWD/StrelkaSomaticWorkflow/runWorkflow.py -m local -j 30
python $4/runWorkflow.py -m local -j 18

echo "Finished Strelka variant calling for exomes)"  
