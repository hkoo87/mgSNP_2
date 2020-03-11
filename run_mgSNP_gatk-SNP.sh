#!/bin/bash
#SBATCH --partition=medium
#SBATCH --job-name=Snp
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=10
#SBATCH --share
#SBATCH --mem=200000
#SBATCH --time=50:00:00
#SBATCH --output=gatk1.%j.out
#SBATCH --error=gatk1.%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=khmkhm87@uab.edu

### Load Parallel module
module load parallel/20150822-GCC-4.9.2

### Import global variables ###
source mgSNP.config.txt
###
cat ${GATK_SNP}/*/*_cmd.sh |shuf > temp_gatk-SNP.command
parallel -j $SLURM_NTASKS --joblog ${GATK_SNP}/parallel_log < temp_gatk-SNP.command

bash mgSNP_gatk-GVCF.sh
