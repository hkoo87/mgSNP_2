#!/bin/bash

#Run BWA
#Threads to run

### Import global variables ###
source mgSNP.config.txt
###

SAMPLE=$1
mkdir $BWA_FILES

# preparing readgroup info
READGROUP="@RG\tID:G${SAMPLE}\tSM:${SAMPLE}\tPL:Illumina\tLB:lib1\tPU:unit1"

#use if trimmomatic is used
bwa mem -M -t $THREAD_IN -R $READGROUP $REF ${RAWDATA_QC}/${SAMPLE}_F_P.fastq.gz ${RAWDATA_QC}/${SAMPLE}_R_P.fastq.gz > $BWA_FILES/${SAMPLE}.sam

echo -e "\nINFO: BWA alignment complete for sample ${SAMPLE}"
