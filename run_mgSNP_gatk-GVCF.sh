#!/bin/bash
#SBATCH --partition=medium
#SBATCH --job-name=Gvcffd2
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --share
#SBATCH --mem=100000
#SBATCH --time=10:00:00
#SBATCH --output=gvcffd2.%j.out
#SBATCH --error=gvcffd2.%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=khmkhm87@uab.edu

### Load Parallel module
module load parallel/20150822-GCC-4.9.2

### Import global variables ###
source mgSNP.config.txt
###

cat ${GATK_MULTISNP}/*/*.job |grep -v "SBATCH" | grep -v "bash" > temp_gatk-GCF.commandlist
parallel -j 5 --joblog ${GATK_SNP}/parallel_log < temp_gatk-GCF.commandlist

