#!/bin/bash
### Import global variables ###
source mgSNP.config.txt
###

mkdir $COMPARE

while read line
do

			genome=` echo "$line" | cut -d ' ' -f 1`
			mkdir  $COMPARE/$genome

	count=1
	array=(`echo "$line" | cut -d ' ' -f 2-`)
	count=${#array[@]}
	for (( i=0; i<$((count - 1 )); i++ ))
	do

  cat <<EOF > $COMPARE/$genome/z${genome}_${i}.job
#!/bin/bash
#SBATCH --partition=medium
#SBATCH --job-name=JOB_z${genome}_${i}
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --share
#SBATCH --mem=10000
#SBATCH --time=24:00:00
#SBATCH --output=$COMPARE/$genome/z${genome}_${i}.%N.%j.out
#SBATCH --error=$COMPARE/$genome/z${genome}_${i}.%N.%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=khmkhm87@uab.edu

### Load module VCFtools
module load VCFtools/0.1.14-goolf-1.4.10-Perl-5.16.3

	LIST_SAMPLES="`echo ${array[@]:$i}`"

	OUT=`echo "$COMPARE/$genome/z${genome}_${i}.out"`
	echo -en "" >\$OUT

	#echo -e "Working on genome $genome"
	set -- \$LIST_SAMPLES
	for a; do
    		shift
    		for b; do
			shift
			echo -en "${genome}:\${a}:\${b}=" >> \$OUT
			echo -e "\$a\n\$b" > $COMPARE/$genome/ids${i}
			vcftools --vcf ${GATK_MULTISNP}/${genome}/${genome}.vcf --keep $COMPARE/$genome/ids${i} --remove-indels --recode -c > $COMPARE/$genome/temp${i}.vcf
			python mgSNP_annotator.py -i $COMPARE/$genome/temp${i}.vcf -o $COMPARE/$genome/temp${i}.ann
                        GETNAME=\`echo ${genome},length=\`
                        GETSTR=\`grep "\$GETNAME" < ${GATK_MULTISNP}/${genome}/${genome}.vcf\`
                        GETLENGTH=\`echo \$GETSTR | cut -d '=' -f 4 | tr -d '>'\`
			XX=\`python mgSNP_windowmaker.py -i $COMPARE/$genome/temp${i}.ann -o $COMPARE/$genome/temp${i}.win -w 1000 -g \$GETLENGTH\`
			echo -en "\${XX}\n" >> \$OUT

		done
	done

	rm $COMPARE/$genome/temp${i}.vcf
	rm $COMPARE/$genome/temp${i}.ann
	rm $COMPARE/$genome/temp${i}.win
	rm $COMPARE/$genome/ids${i}
EOF


done

done < $LIST_FOR_COMPARE
