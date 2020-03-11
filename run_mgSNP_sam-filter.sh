#!/bin/bash
#SBATCH --partition=medium
#SBATCH --job-name=Sam-filter
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --share
#SBATCH --mem=100000
#SBATCH --time=10:00:00
#SBATCH --output=sam-filter.%j.out
#SBATCH --error=sam-filter.%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=khmkhm87@uab.edu

### Load Parallel module
module load parallel/20150822-GCC-4.9.2

### Import global variables ###
source mgSNP.config.txt
###

SAMPLES_LIST=`cat ${SAMPLES_LIST}|tr '\n' ' '`

mkdir $BWA_FILTERED

parallel -j $SLURM_NTASKS "python mgSNP_sam-filter.py -i ${BWA_FILES}/{}.sam -o ${BWA_FILTERED}/{}.filtered.sam" ::: $SAMPLES_LIST
parallel -j $SLURM_NTASKS "grep -v "XA:" ${BWA_FILTERED}/{}.filtered.sam > ${BWA_FILTERED}/{}.filtered2.sam" ::: $SAMPLES_LIST
