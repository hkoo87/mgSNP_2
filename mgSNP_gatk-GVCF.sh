#!/bin/bash

### Import global variables ###
source mgSNP.config.txt
###

mkdir ${GATK_MULTISNP}

while read line
do

        GENOME_NAME=` echo "$line" | cut -d ':' -f 1`

	mkdir ${GATK_MULTISNP}/$GENOME_NAME


	cat <<EOF > ${GATK_MULTISNP}/$GENOME_NAME/${GENOME_NAME}.job
#!/bin/bash
#SBATCH --partition=medium
#SBATCH --job-name=JOB_${GENOME_NAME}
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --share
#SBATCH --mem=50000
#SBATCH --time=48:00:00
#SBATCH --output=${GATK_MULTISNP}/$GENOME_NAME/${GENOME_NAME}.%N.%j.out
#SBATCH --error=${GATK_MULTISNP}/$GENOME_NAME/${GENOME_NAME}.%N.%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=khmkhm87@uab.edu

ls ${GATK_SNP}/$GENOME_NAME/*.g.vcf > ${GATK_MULTISNP}/$GENOME_NAME/allvcf.list
java -Xmx50g -jar $GATK/GenomeAnalysisTK.jar -T GenotypeGVCFs -R $REF --sample_ploidy 1 --variant ${GATK_MULTISNP}/$GENOME_NAME/allvcf.list --includeNonVariantSites -o ${GATK_MULTISNP}/$GENOME_NAME/${GENOME_NAME}.vcf

EOF


done < $GENOME_LIST
