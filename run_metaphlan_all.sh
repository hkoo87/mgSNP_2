#!/bin/bash
#
#SBATCH --mail-type=ALL                     ##Type of email notification-BEGIN,END,FAIL,ALL
#SBATCH --mail-user=khmkhm87@uab.edu        ##Email to which notifications will be sent
#
#SBATCH --job-name=Metaphlan                   ##Job Name
#
#SBATCH -n 5                                ##Number of cores
#SBATCH --mem-per-cpu=8000                  ##Memory specified for each core used (in MB) (no cores, use --mem=)
#SBATCH -t 0-50:00:00                       ##Runtime in D-HH:MM:SS
#SBATCH --share
#SBATCH --partition=medium
#
#SBATCH --error=%j.%N.err.txt             ##File to which STDERR will be written
#SBATCH --output=%j.%N.out.txt            ## File to which STDOUT will be written
#
#module load Singularity/2.4-GCC-5.4.0-2.26
#module load Singularity/2.4.1-GCC-5.4.0-2.26

source mgSNP.config.txt 

mkdir $METAPHLAN

SAMPLES_LIST=`cat ${SAMPLES_LIST}|tr '\n' ' '`

for SAMPLE in $SAMPLES_LIST
do
	metaphlan2.py ${RAWDATA_QC}/${SAMPLE}_F_P.fastq.gz --input_type fastq --nproc 10 --bowtie2out ${METAPHLAN}/${SAMPLE}.bowtie.bz2 -t rel_ab_w_read_stats -o ${METAPHLAN}/${SAMPLE}_profile_reads.txt --sample_id ${SAMPLE}

done

