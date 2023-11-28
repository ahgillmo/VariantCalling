#!/usr/bin/bash
#SBATCH --partition=razi-bf,apophis-bf,theia-bf,pawson-bf
#SBATCH --job-name=strelka_VAFCalc
#SBATCH --mem=40G
##SBATCH --time=6-5:30
#SBATCH --time=5:00:00
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err

#NORMAL is $10
#TUMOR is $11
#echo -e "The input VCF is:" $1

while read -r line ; do


chrom=$(echo $line | sed 's/ /\t/g' | cut -f 1) &&
position=$(echo $line | sed 's/ /\t/g' | cut -f 2) &&

REF=$(echo $line | sed 's/ /\t/g' | cut -f 4) &&
ALT=$(echo $line | sed 's/ /\t/g' | cut -f 5) &&
#tumor=$(echo $line | sed 's/ /\t/g' | cut -f 11 | sed 's/:/\t/g') &&

formatLine=$(echo $line | sed 's/ /\t/g' | cut -f 11)
#dp=$(echo $line | sed 's/ /\t/g' | cut -f 11 | sed 's/:/\t/g' | cut -f 1)
#fdp=$(echo $line | sed 's/ /\t/g' | cut -f 11 | sed 's/:/\t/g'| cut -f 2)
#sdp=$(echo $line | sed 's/ /\t/g' | cut -f 11 | sed 's/:/\t/g' | cut -f 3)
#SUBdp=$(echo $line | sed 's/ /\t/g' | cut -f 11 | sed 's/:/\t/g'| cut -f 4)
AU=$(echo $line | sed 's/ /\t/g' | cut -f 11 | sed 's/:/\t/g'| cut -f 5)
CU=$(echo $line | sed 's/ /\t/g' | cut -f 11 | sed 's/:/\t/g'| cut -f 6)
GU=$(echo $line | sed 's/ /\t/g' | cut -f 11 | sed 's/:/\t/g'| cut -f 7)
TU=$(echo $line | sed 's/ /\t/g' | cut -f 11 | sed 's/:/\t/g'| cut -f 8)

#cho -e $formatLine

#tier1refCount
if [[ "${REF^}" = "T" ]]; then
	tier1refCount=$(echo ${TU} | sed 's/,/\t/g' | cut -f 1)
elif [[ "${REF^}" = "C" ]]; then
	tier1refCount=$(echo ${CU} | sed 's/,/\t/g'| cut -f 1)
elif [[ "${REF^}" = "A" ]]; then
        tier1refCount=$(echo ${AU} | sed 's/,/\t/g'| cut -f 1)
elif [[ "${REF^}" = "G" ]]; then
        tier1refCount=$(echo ${GU} | sed 's/,/\t/g' | cut -f 1)
fi

#tier1altCount
if [[ "${ALT^}" = "T" ]]; then
        tier1altCount=$(echo ${TU} | sed 's/,/\t/g' | cut -f 1)
elif [[ "${ALT^}" = "C" ]]; then
        tier1altCount=$(echo ${CU} | sed 's/,/\t/g'| cut -f 1)
elif [[ "${ALT^}" = "A" ]]; then
        tier1altCount=$(echo ${AU} | sed 's/,/\t/g'| cut -f 1)
elif [[ "${ALT^}" = "G" ]]; then
        tier1altCount=$(echo ${GU} | sed 's/,/\t/g' | cut -f 1)
fi


#echo -e $chrom'\t'$position'\t'$REF'\t'$ALT'\t'$tier1refCount'\t'$tier1altCount 
echo -e $chrom'\t'$position'\t'$REF'\t'$ALT'\t'$tier1refCount'\t'$tier1altCount | awk '{print $1"_"$2"_"$3"_"$4"\t"($6)/($5 + $6)}' >> $1".mclust.upset"  


#echo -e $formatLine'\t'$tier1refCount'\t'$tier1altCount


done< <(less $1 | egrep -v '#' | awk '$7=="PASS"')



#less $1 | egrep -v '#' | awk '$7=="PASS"' 

