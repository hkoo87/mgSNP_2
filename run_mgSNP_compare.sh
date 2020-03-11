#!/bin/bash
#SBATCH --partition=medium	
#SBATCH --job-name=Compare
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=10
#SBATCH --share
#SBATCH --mem=100000
#SBATCH --time=50:00:00
#SBATCH --output=gatk1.%j.out
#SBATCH --error=gatk1.%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=khmkhm87@uab.edu

### Import global variables ###
source mgSNP.config.txt
###

### Load module Parallel
module load parallel/20150822-GCC-4.9.2
module load VCFtools/0.1.15-intel-2016a-Perl-5.22.1

parallel -j $SLURM_NTASKS "bash {} " ::: $COMPARE/*/*.job

# To submit jobs on slurm cluster do

