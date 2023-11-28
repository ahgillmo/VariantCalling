#!/usr/bin/bash
#SBATCH --partition=razi-bf,apophis-bf,theia-bf
#SBATCH --job-name=deepvariant_runtime
#SBATCH --mem=40G
##SBATCH --time=6-00:00:30
#SBATCH --time=5:00:00
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err
##SBATCH --cpus-per-task=10

samtools index $1


