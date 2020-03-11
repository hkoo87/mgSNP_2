
### Import global variables ###
source mgSNP.config.txt
###


mkdir ${GATK_SNP}

while read line
do
        GENOME_NAME=` echo "$line" | cut -d ':' -f 1`
        mkdir ${GATK_SNP}/$GENOME_NAME

        while read sample
        do
                SAMPLE_NAME=`echo "$sample" | cut -d '/' -f 2 | cut -d '_' -f 1`
                echo -e "java -Xmx10g -jar $GATK/GenomeAnalysisTK.jar -T HaplotypeCaller -R $REF -L $line --sample_ploidy 1 -I $sample --emitRefConfidence BP_RESOLUTION -o ${GATK_SNP}/$GENOME_NAME/${SAMPLE_NAME}.g.vcf"  >> ${GATK_SNP}/$GENOME_NAME/${GENOME_NAME}_cmd.sh
        done < $BAM_LIST

cat <<EOF > ${GATK_SNP}/$GENOME_NAME/${GENOME_NAME}.job
#!/bin/bash
#SBATCH --partition=medium
#SBATCH --job-name=CM_${GENOME_NAME}
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --mem=250000
#SBATCH --time=48:00:00
#SBATCH --output=${GATK_SNP}/$GENOME_NAME/${GENOME_NAME}.%N.%j.out
#SBATCH --error=${GATK_SNP}/$GENOME_NAME/${GENOME_NAME}.%N.%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=khmkhm87@uab.edu

### Load Parallel module
module load parallel/20150822-GCC-4.9.2

cat ${GATK_SNP}/$GENOME_NAME/${GENOME_NAME}_cmd.sh | parallel -j $SLURM_NTASKS --joblog log
#gzip *.vcf

EOF


done < $GENOME_LIST
