#!/usr/bin/bash
#SBATCH --partition=single,lattice,parallel
#SBATCH --job-name=convertSV_Manta
#SBATCH --mem=1G
#SBATCH --time=5-5:30
#SBATCH --output=%x.out
#SBATCH --error=%x.err

echo -e "This is the input somativ SV vcf:"$1

source activate strelka_env

python /home/ahgillmo/miniconda3/pkgs/manta-1.6.0-py27_0/share/manta-1.6.0-0/libexec/convertInversion.py /home/ahgillmo/miniconda3/envs/strelka_env/bin/samtools /home/ahgillmo/references/grch38_2-1-0/refdata-GRCh38-2.1.0/fasta/genome.fa $1 > $1".convertedInversion.vcf"

conda deactivate 


