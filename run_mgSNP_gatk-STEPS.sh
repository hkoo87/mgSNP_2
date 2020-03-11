#!/bin/bash
#SBATCH --partition=medium
#SBATCH --job-name=Gatk1
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --share
#SBATCH --mem=100000
#SBATCH --time=30:00:00
#SBATCH --output=gatk1.%j.out
#SBATCH --error=gatk1.%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=khmkhm87@uab.edu

### Load Parallel module
module load parallel/20150822-GCC-4.9.2
module load SAMtools/0.1.19-foss-2016a

### Import global variables ###
source mgSNP.config.txt
###

SAMPLES_LIST=`cat ${SAMPLES_LIST}|tr '\n' ' '`

mkdir $GATK_STEPS
parallel -j $SLURM_NTASKS bash mgSNP_gatk.sh  ::: $SAMPLES_LIST

ls GATK_STEPS/*realigned.bam >bam.list
bash mgSNP_gatk-SNP.sh
sbatch run_mgSNP_gatk-SNP.sh

