#!/usr/bin/bash
#SBATCH --partition=cpu2013,cpu2019,cpu2021
#SBATCH --job-name=Strelka_somatic_exectute
#SBATCH --mem=22G
#SBATCH --time=7-00:00:00
##SBATCH --time=5:00:00
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err
#SBATCH --cpus-per-task=12

##This codes conduct somatic variants calling using strelka from tumor normal sequencing. It also takes manta candidate indels to use a basis for calling indels. #Requires activation of the strelka_enviroment to work (python 2.7)

#conda activate strelka_env
source activate strelka_env

echo -e "The tumor bam is "'\t'$1
echo -e "The normal bam is "'\t'$2
echo -e "The candidate indels from Manta are "'\t'$3
echo -e "The working directory "'\t'$PWD

#bash /home/ahgillmo/strelka_installation/strelka-2.9.10.centos6_x86_64/bin/runStrelkaSomaticWorkflowDemo.bash

#outdir=$(basename $PWD)
outdir=$(echo $1 | sed 's/.SMmerge.lanemerged.sorted.markduplicates.bam/_Strelka/g')

python /home/ahgillmo/strelka_installation/strelka-2.9.10.centos6_x86_64/bin/configureStrelkaSomaticWorkflow.py --tumorBam $1 --normalBam $2 --referenceFasta /home/ahgillmo/references/grch38_2-1-0/refdata-GRCh38-2.1.0/fasta/genome.fa --indelCandidates $3 --runDir $outdir &&


echo "Finished Strelka script generation  :)" && 

#python $PWD/StrelkaSomaticWorkflow/runWorkflow.py -m local -j 30
python $PWD/$outdir/runWorkflow.py -m local -j 12

echo "Finished Strelka variant calling with manta :)"  
