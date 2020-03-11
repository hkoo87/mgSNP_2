#!/bin/bash
### Import global variables ###
source mgSNP.config.txt
###

mkdir $COV_STATS

while read line
do
        GENOME_NAME=` echo "$line" | cut -d ':' -f 1`
        FILE_NAME=cov_d1.stats
        rm $COV_STATS/$GENOME_NAME/$FILE_NAME
        for i in `ls $COV_STATS/$GENOME_NAME/d1_*`
        do
                echo -ne "$GENOME_NAME\t" >> $COV_STATS/$GENOME_NAME/$FILE_NAME && cat $i | grep -v "MEAN_DEPTH" >> $COV_STATS/$GENOME_NAME/$FILE_NAME
        done

done < $GENOME_LIST
