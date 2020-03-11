#!/bin/bash
#SBATCH --partition=medium
#SBATCH --job-name=Get_cov
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=10
#SBATCH --share
#SBATCH --mem=10000
#SBATCH --time=30:00:00
#SBATCH --output=get_cov.%N.%j.out
#SBATCH --error=get_cov.%N.%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=khmkhm87@uab.edu

### Load module Parallel
module load parallel/20150822-GCC-4.9.2

### Load module VCFtools
module load VCFtools/0.1.15-intel-2016a-Perl-5.22.1

### Import global variables ###
source mgSNP.config.txt
###

mkdir $COV_STATS

while read line
do
        GENOME_NAME=` echo "$line" | cut -d ':' -f 1`
        mkdir $COV_STATS/$GENOME_NAME

        parallel -j $SLURM_NTASKS "vcftools --vcf {} --depth --out $COV_STATS/$GENOME_NAME/d1_{/.} --minDP 1" ::: ${GATK_SNP}/${GENOME_NAME}/*.vcf

        rm $COV_STATS/$GENOME_NAME/${GENOME_NAME}_d1.stats
        echo -ne "$GENOME_NAME\t" > $COV_STATS/$GENOME_NAME/${GENOME_NAME}_d1.stats && cat $COV_STATS/$GENOME_NAME/d1_*.idepth | grep -v "MEAN_DEPTH" | tr "\n" "\t" >> $COV_STATS/$GENOME_NAME/${GENOME_NAME}_d1.stats

done < $GENOME_LIST

bash run_mgSNP_cov_merge.sh
cat COV_STATS/*/cov_d1.stats > allcov.stats


