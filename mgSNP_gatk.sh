#!/bin/bash
### Import global variables ###
source mgSNP.config.txt
###

i=$1


echo -e "INFO: Sorting sam file and generating bam file"
java \
-Xmx8g \
-Djava.io.tmpdir=$TEMP \
-jar ${PICARD}/picard.jar SortSam \
INPUT=${BWA_FILTERED}/${i}.filtered2.sam \
OUTPUT=$GATK_STEPS/${i}_sorted.bam \
SORT_ORDER=coordinate
echo -e "\nINFO: Step Completed!"

echo -e "INFO: Marking duplicates using picard"
java \
-Xmx8g \
-Djava.io.tmpdir=$TEMP \
-jar ${PICARD}/picard.jar MarkDuplicates \
VALIDATION_STRINGENCY=SILENT \
CREATE_INDEX=True \
TMP_DIR=$TEMP \
INPUT=$GATK_STEPS/${i}_sorted.bam \
OUTPUT=$GATK_STEPS/${i}_dedup.bam \
METRICS_FILE=$GATK_STEPS/${i}_dedup_metrics.txt \
ASSUME_SORTED=True
echo -e "\nINFO: Step Completed!"


echo -e "INFO: Generating flagstat stats using bam files"
samtools flagstat ${i}_dedup.bam > ${i}.flagstast.txt
echo -e "\nINFO: Step Completed!"

echo -e "INFO: Generating targets for indel realignment"
java \
-Xmx8g \
-Djava.io.tmpdir=$TEMP \
-jar $GATK/GenomeAnalysisTK.jar \
-T RealignerTargetCreator \
-R $REF \
-o $GATK_STEPS/${i}.intervals \
-I $GATK_STEPS/${i}_dedup.bam
echo -e "\nINFO: Step Completed!"

echo -e "INFO: Doing Indel realignment"
java \
-Xmx8g \
-Djava.io.tmpdir=$TEMP \
-jar $GATK/GenomeAnalysisTK.jar \
-T IndelRealigner \
-R $REF \
-targetIntervals $GATK_STEPS/${i}.intervals \
-I $GATK_STEPS/${i}_dedup.bam \
-o $GATK_STEPS/${i}_realigned.bam
 echo -e "\nINFO: Step Completed!"

