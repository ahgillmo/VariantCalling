#!/usr/bin/bash
##SBATCH --partition=apophis-bf,pawson-bf
#SBATCH --partition=single,lattice,parallel
#SBATCH --job-name=exome_Manta
#SBATCH --mem=10G
##SBATCH --mem=90G
#SBATCH --time=7-00:00:00
##SBATCH --time=5:00:00
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err

echo -e $1'\t'"Is the tumor Bam"
echo -e $2'\t'"Is the normal Bam"
echo -e $3'\t'"Is the directory ID name"

source activate strelka_env
#python /home/ahgillmo/miniconda3/pkgs/manta-1.6.0-py27_0/share/manta-1.6.0-0/bin/configManta.py --referenceFasta /home/ahgillmo/references/grch38_2-1-0/refdata-GRCh38-2.1.0/fasta/genome.fa --tumorBam /work/morrissy_lab/ahgillmo/Synergy_Homedir/bcgsc/Genome_chromium/LongrangerRun/SMP8_P1_1/outs/phased_possorted_bam.bam --normalBam /work/morrissy_lab/ahgillmo/Synergy_Homedir/bcgsc/Genome_chromium/LongrangerRun/SMP8_BL/outs/phased_possorted_bam.bam --runDir SMP8P1_1_Manta

python /home/ahgillmo/miniconda3/pkgs/manta-1.6.0-py27_0/share/manta-1.6.0-0/bin/configManta.py --referenceFasta /bulk/morrissy_bulk/REFERENCES/human/hg38/genomeDecoy/fasta/genome.fa --tumorBam $1 --normalBam $2 --runDir $3"_MantaWorkflow"

python $PWD/$3"_MantaWorkflow"/runWorkflow.py

conda deactivate


