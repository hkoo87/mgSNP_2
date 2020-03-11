#!/bin/bash
#SBATCH --partition=medium
#SBATCH --job-name=bwa
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --share
#SBATCH --mem=100000
#SBATCH --time=10:00:00
#SBATCH --output=bwa.%j.out
#SBATCH --error=bwa.%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=khmkhm87@uab.edu

### Load Parallel module
module load parallel/20150822-GCC-4.9.2
module load BWA/0.7.13-intel-2016a

### Import global variables ###
source mgSNP.config.txt
###
SAMPLES_LIST=`cat ${SAMPLES_LIST}|tr '\n' ' '`

parallel -j ${THREAD_OUT} bash mgSNP_bwa.sh ::: $SAMPLES_LIST


