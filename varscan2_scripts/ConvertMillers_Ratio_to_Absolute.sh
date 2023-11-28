#!/usr/bin/bash


#Converts log 2 rations to absolute CNV
#called in Merge_Varscan_segments_Miller.sh as "bash /home/aaronhg/master_scripts/Varscan2/ConvertMillers_Ratio_to_Absolute.sh $MergedCompletedSegments"
 
outname=$(echo $1".logratio_converted_to_absolute.tsv")
echo 'ABS.CNV LogRatio chrom Seg.Start Seg.End EventSize Region chrArm arm% chrom%' | sed 's/ /\t/g' > $outname

while read -r line ; do 
LogRatio=$(echo $line | awk '{print $1}' | awk '{ print sprintf("%.4f", $0); }') && ##
absCNV=$((echo 'e('$LogRatio'*l(2))*2') | bc -l | awk '{ print sprintf("%.4f", $0); }' ) &&


echo -e $absCNV'\t'$line | sed 's/ /\t/g' | cut -f 1,2,3,4,5,10-14 ;
done < $1 >> $outname








