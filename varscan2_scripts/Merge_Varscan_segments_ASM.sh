#!/usr/bin/bash

#This script will take the *sdunodo.txt values and merge them into a single CNV file using ASM prepared and modified script. This is a broad strokes assessment and will only find major CopyNumber variations.

#Consider Modifying the ASM_CopyNumber_MergeScript to allow for more CopyNumber segments to be inferred.


#$1 is the Basename or the Identification of the files
outname=$(echo $1".CNV.ASM.Combined.Merged.tsv")
echo 'ABS.CNV Chrom Seg.Start Seg.End NumSegs LogRatio' | sed 's/ /\t/g' > $outname

cat *sdundo.txt > $1".sdundo.Combined"

#for file in *_sdundo.txt ; do Out=$(echo $file".ASM.Merged") bash /tiered/smorrissy/aaronhg/adultGBM/Somatic_Calling/merge_sdundo_segments.sh $file;  done


bash /home/aaronhg/master_scripts/Varscan2/ASM_CopyNumber_MergeScript.sh $1".sdundo.Combined" > $1".temporary"

while read -r line ; do
LogRatio=$(echo $line | awk '{print $5}' | awk '{ print sprintf("%.4f", $0); }') && ##
absCNV=$((echo 'e('$LogRatio'*l(2))*2') | bc -l | awk '{ print sprintf("%.4f", $0); }' ) &&

echo -e $absCNV'\t'$line ;

done < $1".temporary" >> $outname

rm $1".temporary"
rm $1".sdundo.Combined"
