#!/usr/bin/bash



bcftools view -h $1 > $2".header.hr"
sed -i '$i##FILTER=<ID=RefMMQS,Description="None">' $2".header.hr" 
sed -i '$i##FILTER=<ID=MinMMQSdiff,Description="None">' $2".header.hr" &&
sed -i '$i##FILTER=<ID=RefAvgRL,Description="None">' $2".header.hr" &&
sed -i '$i##FILTER=<ID=VarAvgRL,Description="None">' $2".header.hr" &&
sed -i '$i##FILTER=<ID=RefReadPos,Description="None">' $2".header.hr" &&
sed -i '$i##FILTER=<ID=RefDist3,Description="None">' $2".header.hr"


less $1 | egrep -v "#" | awk -F"\t" '{ gsub(",",";",$7); print $0}' | sed 's/ /\t/g' > $2".varscan.fpfilter.converted.txt"


cat $2".header.hr" $2".varscan.fpfilter.converted.txt" > $2".varscan.fpfilter.final.txt"
mv $2".varscan.fpfilter.final.txt" $2".varscan.fpfilter.final.vcf"

bgzip $2".varscan.fpfilter.final.vcf" 
tabix $2".varscan.fpfilter.final.vcf.gz"

##########
rm *.header.hr
rm $2".varscan.fpfilter.converted.txt"



