#!/bin/bash
#SBATCH --partition=medium
#SBATCH --job-name=QC
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --share
#SBATCH --mem=100000
#SBATCH --time=30:00:00
#SBATCH --output=ant_qc.%j.out
#SBATCH --error=ant_qc.%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=khmkhm87@uab.edu

### Import global variables ###
source mgSNP.config.txt
###

mkdir $RAWDATA_QC

#copy trimmomatic adapter
cp $TRIMMOMATIC_ADAPTER .

SAMPLES_LIST=`cat ${SAMPLES_LIST}|tr '\n' ' '`

for SAMPLE in $SAMPLES_LIST
do
        java -jar $TRIMMOMATIC PE -phred33 ${RAWDATA}/${SAMPLE}_host_removed_F.fastq.gz ${RAWDATA}/${SAMPLE}_host_removed_R.fastq.gz ${RAWDATA_QC}/${SAMPLE}_F_P.fastq.gz ${RAWDATA_QC}/${SAMPLE}_F_S.fastq.gz ${RAWDATA_QC}/${SAMPLE}_R_P.fastq.gz ${RAWDATA_QC}/${SAMPLE}_R_S.fastq.gz ILLUMINACLIP:TruSeq3-PE.fa:2:30:10 CROP:100 SLIDINGWINDOW:50:20 MINLEN:50

done

