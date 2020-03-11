#!/bin/bash
#SBATCH --partition=medium
#SBATCH --job-name=Filter-Host
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --share
#SBATCH --mem=200000
#SBATCH --time=48:00:00
#SBATCH --output=filter.%j.out
#SBATCH --error=filter.%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=khmkhm87@uab.edu

### Import global variables ###
source mgSNP.config.txt

###Loading BEDTools
module load BEDTools/2.26.0-foss-2016a

###Assign Host genome reference location
#This script was written based on HUMAN_REF. However, this can be modified with MOUSE_REF.
#MOUSE_REF="PATH_TO_THE_MOUSE_REFERENCE"
HUMAN_REF="PATH_TO_THE_HUMAN_REFERENCE"

SAMPLES_LIST=`cat ${SAMPLES_LIST}|tr '\n' ' '`

for SAMPLE in $SAMPLES_LIST
do

	echo `date`
	bowtie2 -x $HUMAN_REF -1 ${RAWDATA}/${SAMPLE}_F.fastq.gz -2 ${RAWDATA}/${SAMPLE}_R.fastq.gz -S ${RAWDATA}/${SAMPLE}_mapped_and_unmapped.sam -p 16
	samtools view -bS ${RAWDATA}/${SAMPLE}_mapped_and_unmapped.sam > ${RAWDATA}/${SAMPLE}_mapped_and_unmapped.bam
	samtools view -b -f 12 -F 256 ${RAWDATA}/${SAMPLE}_mapped_and_unmapped.bam > ${RAWDATA}/${SAMPLE}_bothEndsUnmapped.bam
	samtools sort -n ${RAWDATA}/${SAMPLE}_bothEndsUnmapped.bam ${RAWDATA}/${SAMPLE}_bothEndsUnmapped_sorted
	bedtools bamtofastq -i ${RAWDATA}/${SAMPLE}_bothEndsUnmapped_sorted.bam -fq ${RAWDATA}/${SAMPLE}_host_removed_F.fastq -fq2 ${RAWDATA}/${SAMPLE}_host_removed_R.fastq
	gzip ${RAWDATA}/*.fastq
done


