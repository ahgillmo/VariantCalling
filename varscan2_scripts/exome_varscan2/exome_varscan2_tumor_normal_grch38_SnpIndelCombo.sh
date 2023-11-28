#!/usr/bin/bash
##SBATCH --partition=razi-bf,apophis-bf,theia-bf
#SBATCH --partition=parallel,sherlock,cpu2019,cpu2021
#SBATCH --job-name=exome_varscan_snv_loh_germline
#SBATCH --mem=22G
#SBATCH --time=7-00:00:00
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err

echo -e "The Tumor bam is:" $1
echo -e "The Normal Bam is:"$2
echo -e "The Tumor id:" $3
echo -e "The Normal id is:"$4

###Pileup Names scheme
pileupName=$(echo $3"_"$4".mpileup"); 
tumorPileup=$(echo $3".mpileup");
normalPileup=$(echo $4".mpileup");

###Inte
somaticPrefix=$(echo $3"_"$4) ;
indelName=$(echo $3".indel.vcf") ;
snpName=$(echo $3".snp.vcf") ;


###Names for varscan fpfilters
#Snp_Somatic_HCName=$(echo $3".snp.Somatic.hc.vcf")
#Snp_Germline_HCName=$(echo $3".snp.Germline.hc.vcf")
#Snp_LOH_HCName=$(echo $3".snp.LOH.hc.vcf") 

#indel_Somatic_HCName=$(echo $3".indel.Somatic.hc.vcf")
#indel_Germline_HCName=$(echo $3".indel.Germline.hc.vcf")
#indel_LOH_HCName=$(echo $3".indel.LOH.hc.vcf")
####

#Step 1 and 2 will mpileup and call basic somatic variants in two categories indel and SNPs 
#The map quality is set with -q (18) and the base quality is set with -Q (20) this is set to be similar to mutect2
samtools mpileup -q 18 -Q 20 -B -f /bulk/morrissy_bulk/REFERENCES/human/hg38/genomeDecoy/fasta/genome.fa $2 $1 | /home/ahgillmo/miniconda3/bin/varscan somatic /dev/stdin -mpileup --min-var-freq 0.05 --min-coverage 5 --min-coverage-normal 5 --min-coverage-tumor 5 --normal-purity 0.90 --output-snp $snpName --output-indel $indelName --strand-filter 1 --output-vcf 1

#Step 3 - Internal filters
varscan processSomatic $snpName --min-tumor-freq 0.05
varscan processSomatic $indelName --min-tumor-freq 0.05

#Step 4 - Zipping and indexing for bcftools
bgzip $3".snp.Somatic.hc.vcf"
tabix $3".snp.Somatic.hc.vcf.gz"

bgzip $3".indel.Somatic.hc.vcf"
tabix $3".indel.Somatic.hc.vcf.gz"

#Step 5 - Combine snp and indel vcfs from the same sample (similar to rbinding), r
#bcftools concat -Ov -a -R /home/ahgillmo/references/broad_hg38_wgs_callingregions.interval.bed -o $3".varscan.hc.vcf" $snpName".gz" $indelName".gz" &&
bcftools concat -Ov -a -R /work/morrissy_lab/heewon/EXOME/resources/xgen-exome-research-panel-v2-targets-hg38.bed -o $3".varscan.hc.vcf" $3".snp.Somatic.hc.vcf.gz" $3".indel.Somatic.hc.vcf.gz" &&

#Step 6 - Left align and split multiallelic variants -- output uncompressed vcf
bcftools norm -m-both -f /bulk/morrissy_bulk/REFERENCES/human/hg38/genomeDecoy/fasta/genome.fa -o $3".varscan.leftaligned.hc.vcf" -Ov $3".varscan.hc.vcf"

#Step 7 - Generate bed file for readcounts
awk 'BEGIN {OFS="\t"} {if (!/^#/) { InsDelLen=(length($4) > length($5)) ? length($4) : length($5); print $1,($2-1),($2-1+InsDelLen); }}' $3".varscan.leftaligned.hc.vcf" > $3".varscan.leftaligned.hc.vcf.var" &&

#Step 8 - Read count on snp and indel locations 
bam-readcount -w 1 -q 1 -b 20 -l $3".varscan.leftaligned.hc.vcf.var" -f /bulk/morrissy_bulk/REFERENCES/human/hg38/genomeDecoy/fasta/genome.fa $1 > $3".varscan.leftaligned.hc.vcf.var.readcount" 

#Step 9 - Use dream 3 settings for produce a high quality set of filters
#varscan fpfilter $3".varscan.hc.vcf" $3".varscan.hc.vcf.var.readcount" --output-file $3".varscan.hc.readcount.fpfilter.vcf" --dream3-settings 1 --keep-failures
java -Xmx20G -jar /home/ahgillmo/miniconda3/pkgs/varscan-2.4.3-2/share/varscan-2.4.3-2/VarScan.jar fpfilter $3".varscan.leftaligned.hc.vcf" $3".varscan.leftaligned.hc.vcf.var.readcount" --output-file $3".varscan.leftaligned.hc.readcount.fpfilter.vcf" --dream3-settings 1 --keep-failures


#Add to appropriate Filter ID's
bcftools view -h $3".varscan.leftaligned.hc.readcount.fpfilter.vcf" > $3".header.hr"
sed -i '$i##FILTER=<ID=RefMMQS,Description="None">' $3".header.hr" &&
sed -i '$i##FILTER=<ID=MinMMQSdiff,Description="None">' $3".header.hr" &&
sed -i '$i##FILTER=<ID=RefAvgRL,Description="None">' $3".header.hr" &&
sed -i '$i##FILTER=<ID=VarAvgRL,Description="None">' $3".header.hr" &&
sed -i '$i##FILTER=<ID=RefReadPos,Description="None">' $3".header.hr" &&
sed -i '$i##FILTER=<ID=RefDist3,Description="None">' $3".header.hr" &&

#Replace commas with semi-colons
less $3".varscan.leftaligned.hc.readcount.fpfilter.vcf" | egrep -v "#" | awk -F"\t" '{ gsub(",",";",$7); print $0}' | sed 's/ /\t/g' > $3".varscan.fpfilter.converted.txt"

#Move stuff
cat $3".header.hr" $3".varscan.fpfilter.converted.txt" > $3".varscan.leftaligned.hc.readcount.fpfilter.final.txt"
mv $3".varscan.leftaligned.hc.readcount.fpfilter.final.txt" $3".varscan.leftaligned.hc.readcount.fpfilter.final.vcf"

bgzip $3".varscan.leftaligned.hc.readcount.fpfilter.final.vcf"
tabix $3".varscan.leftaligned.hc.readcount.fpfilter.final.vcf.gz"


echo -e "Completed running Varscan on tumor: "$3" and normal "$4

#wait for cleaning
sleep 2m 

#Clean-up
#rm $3".varscan.leftaligned.hc.readcount.fpfilter.final.txt"
#rm $3".header.hr" #Add to appropriate Filter ID's
rm *.snp.Somatic.vcf
rm *.snp.LOH.vcf
rm *.snp.Germline.vcf
rm *.indel.Somatic.vcf
rm *.indel.LOH.vcf
rm *.indel.Germline.vcf
rm *.hc.vcf
#rm $snpName".gz"
#rm $indelName".gz"
#rm $3".varscan.hc.vcf"
#rm $3".varscan.hc.vcf.var"
#rm $3".varscan.hc.vcf.var.readcount"
#rm $3".varscan.hc.readcount.fpfilter.vcf.gz"


