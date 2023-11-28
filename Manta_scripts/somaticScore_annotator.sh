#!/usr/bin/bash

#echo -e "This is the Manta file to be annotated with a specific column for somaticscore:"$1


#head -n 1 $1 | awk '{print $0"\t""Somatic_Score"}' > $1"_somaticscore.tsv"  

PID=$(echo $2)


echo -e "PID"'\t'"SampleID"'\t'"Gene"'\t'Function'\t'Chrom'\t'Pos'\t'MantaID'\t'MantaMatePos'\t'"Filter"'\t'"Format"'\t'"SomaticScore" > $1"_somaticscore.tsv" && 

while read -r line ; do 

SS=$(echo $line | sed 's/ /\t/g' | cut -f 9 | sed 's/;/\t/g' | sed 's/ /_/g' | sed 's/\t/\n/g' | egrep "SOMATICSCORE" | grep -v "JUNCTION") ;

BIND_ID=$(echo $line | sed 's/ /\t/g' | cut -f 6 | sed 's/:/\t/2' | cut -f 1 ) 

echo -e $2'\t'$line'\t'$SS'\t'$BIND_ID ;

done < <(less -S $1 | egrep -v "MantaMatePos") | sed 's/ /\t/g' >> $1"_somaticscore.tsv"

rm $1
