#!/usr/bin/bash
#SBATCH --partition=razi-bf,apophis-bf,theia-bf,pawson-bf
#SBATCH --job-name=fpfilter_Varscan_snv_loh_germline
#SBATCH --mem=100G
#SBATCH --time=5:00:00
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err

echo -e "The input sample id is: "'\t'$1
echo -e "The tumor bam is : "'\t'$2
#This subscript` starts from $1".varscan.hc.vcf

#Step 6 -  normalize but left aligning and splitting multiallelic sites. output must be uncompressed VCF
bcftools norm -m-both -o $1".varscan.leftaligned.hc.vcf" -Ov $1".varscan.hc.vcf"

#Step 7 - Generate bed file for readcounts
awk 'BEGIN {OFS="\t"} {if (!/^#/) { InsDelLen=(length($4) > length($5)) ? length($4) : length($5); print $1,($2-1),($2-1+InsDelLen); }}' $1".varscan.leftaligned.hc.vcf" > $1".varscan.leftaligned.hc.vcf.var" &&

#Step 8 - Read count on snp and indel locations
bam-readcount -w 1 -q 1 -b 20 -l $1".varscan.leftaligned.hc.vcf.var" -f /home/ahgillmo/references/grch38_2-1-0/refdata-GRCh38-2.1.0/fasta/genome.fa $2 > $1".varscan.leftaligned.hc.vcf.var.readcount"

#Step 9 - Use dream 3 settings for produce a high quality set of filters
#varscan fpfilter $3".varscan.hc.vcf" $3".varscan.hc.vcf.var.readcount" --output-file $3".varscan.hc.readcount.fpfilter.vcf" --dream3-settings 1 --keep-failures
java -Xmx20G -jar /home/ahgillmo/miniconda3/pkgs/varscan-2.4.3-2/share/varscan-2.4.3-2/VarScan.jar fpfilter $1".varscan.leftaligned.hc.vcf" $1".varscan.leftaligned.hc.vcf.var.readcount" --output-file $1".varscan.leftaligned.hc.readcount.fpfilter.vcf" --dream3-settings 1 --keep-failures


#Step 10 - Prepare the final file here (OPTIONAL norm and leftalign with bcftools)
bgzip $1".varscan.leftaligned.hc.readcount.fpfilter.vcf"
tabix $1".varscan.leftaligned.hc.readcount.fpfilter.vcf.gz"


#java -Xmx80G -jar /home/ahgillmo/miniconda3/pkgs/varscan-2.4.3-2/share/varscan-2.4.3-2/VarScan.jar fpfilter $1".varscan.hc.vcf" $1".varscan.hc.vcf.var.readcount" --output-file $1".varscan.hc.readcount.fpfilter.vcf" --dream3-settings 1 --keep-failures


#Clean UP
#rm *.snp.Somatic.vcf
#rm *.snp.LOH.vcf
#rm *.snp.Germline.vcf
#rm *.indel.Somatic.vcf
#rm *.indel.LOH.vcf
#rm *.indel.Germline.vcf
#rm *.hc.vcf
#rm $snpName".gz"
#rm $indelName".gz"
#rm $3".varscan.hc.vcf"
#rm $3".varscan.hc.vcf.var"
#rm $3".varscan.hc.vcf.var.readcount"



