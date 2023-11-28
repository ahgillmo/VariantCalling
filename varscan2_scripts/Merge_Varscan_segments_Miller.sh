#!/usr/bin/bash

#This script takes segments from varscan that have been passed through CBS (in R) and applies the mergePerl scripts

#TumorID=$1 
#The only argument is the id for the file break down

for fileSD in *_Pval_sdundo.txt ; do

head=$(head -1 $fileSD);

#echo $head
less $fileSD | grep -v chrom | grep -v NA | awk '$5>=20' | sed "1i $head" > $fileSD".temp" 


perl /tiered/smorrissy/aaronhg/adultGBM/Somatic_Calling/mergeSegments.pl $fileSD".temp" --ref-arm-sizes /tiered/smorrissy/aaronhg/adultGBM/Somatic_Calling/Varscan_CytoBand_hg38_PnQ_arms_noSexchr.tsv --amp-threshold 1.0 --del-threshold 1.0 --output-basename $fileSD".Segs"

#less $fileSD".Segs.events.tsv" | grep -v chrom | cut -f 1-6,8-13 | sed 1i'chrom Seg.Start Seg.End AvgNumSegs MergedNumSegs SegMean Event EventSize Region chrArm arm% chrom%' | sed 's/ /\t/g' > $fileSD".CompletedSegs"

less $fileSD".Segs.events.tsv" | grep -v chrom | cut -f 1-6,8-13 | sed 's/ /\t/g' > $fileSD".CompletedSegs"

done

#cat *.CompletedSegs | sed 's/ /\t/g' | awk '{print $6/$5"\t"$0}' | sed 1i'AVGSegMean chrom Seg.Start Seg.End AvgNumSegs MergedNumSegs SummedSegMean Event EventSize Region chrArm arm% chrom%' | sed 's/ /\t/g' > "Merged.CompletedSegments.txt"

#MergedCompletedSegments=${VARIABLE:-MergedCompletedSegments}
MergedCompletedSegments=$(echo $1".MergedCompletedSegments")

cat *.CompletedSegs | sed 's/ /\t/g' | awk '{print $6/$5"\t"$0}' | sed 's/ /\t/g' > $MergedCompletedSegments

bash /home/aaronhg/master_scripts/Varscan2/ConvertMillers_Ratio_to_Absolute.sh $MergedCompletedSegments

###BELOW is the code to convert the MILLERMERGED stuff into sabsolute CN but this will not work###
#while read -r line; do 
#logRation=$(echo $line | grep -v chrom | awk '{print $1}' | awk '{ print sprintf("%.4f", $0); }' ) && #
#absCNV=$((echo 'e('$logRation'*l(2))*2') | bc -l | awk '{ print sprintf("%.4f", $0); }' ) && 

#echo $line | awk -v var="$absCNV" '{print $1"\t"$2"\t"$3"\t"var}' | sed 's/chr//g'; done < "Merged.CompletedSegments.txt"

###The miller Postion (mergeSegments.pl) is highly HIGHLY incorrect do not trust it on it's own
rm *.temp
rm *.summary.txt
rm *.Segs.events.tsv
rm *_Pval_sdundo.txt.CompletedSegs
rm $MergedCompletedSegments
