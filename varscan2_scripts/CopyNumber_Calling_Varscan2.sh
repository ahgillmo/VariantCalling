#!/usr/bin/bash


###Do copyNumber Calling through Varscan2, DNAcopy and GenVisR.
echo -e "The normal Bam is "'\t'$1
echo -e "The tumor bam is "'\t'$2

echo -e "The -q map qaulity filter is 30 and the -Q base quality is 30"
echo -e "The Min normal Coverage is 10 and the min Tumor coverage is 12"
echo -e "The Min var freq is 0.05 or 5%"

#For BCGSC
#normalBam=/tiered/smorrissy/aaronhg/bcgsc/Genome_chromium/LongrangerRun/$1/outs/phased_possorted_bam.bam
#tumorBam=/tiered/smorrissy/aaronhg/bcgsc/Genome_chromium/LongrangerRun/$2/outs/phased_possorted_bam.bam


#For TCAG
#normalBam=/tiered/smorrissy/aaronhg/adultGBM/ExecutedLR/$1"_LongerRunTime"/outs/phased_possorted_bam.bam
#tumorBam=/tiered/smorrissy/aaronhg/adultGBM/ExecutedLR/$2"_LongerRunTime"/outs/phased_possorted_bam.bam


#For pedGBM
normalBam=/tiered/smorrissy/aaronhg/pedGBM/pedGBM_FastQ/LongRangerRun/$1/outs/phased_possorted_bam.bam
tumorBam=/tiered/smorrissy/aaronhg/pedGBM/pedGBM_FastQ/LongRangerRun/$2/outs/phased_possorted_bam.bam


#For Ependyoma
#normalBam=/tiered/smorrissy/aaronhg/Ependymoma_taylor_wgs/$1/outs/phased_possorted_bam.bam
#tumorBam=/tiered/smorrissy/aaronhg/Ependymoma_taylor_wgs/$2/outs/phased_possorted_bam.bam

echo -e "Normal Bam Locations is"'\t' $normalBam
echo -e "tumor Bam Locations is"'\t' $tumorBam
mpileupOutName=$(echo $1"_"$2".mpileup")


###
#Create the mpileup and do basic calling
/home/aaronhg/miniconda3/bin/samtools mpileup -B -f /tiered/smorrissy/tools/references/grch38_2-1-0/refdata-GRCh38-2.1.0/fasta/genome.fa -q 20 -Q 20 $normalBam $tumorBam | /home/aaronhg/miniconda3/bin/varscan copynumber -mpileup $mpileupOutName --min-coverage-normal 10 --min-coverage-tumor 10 --min-var-freq 0.05 --strand-filter 1


#| bsub -n 12 -e $PWD/varscan_CopyNumber.err -o $PWD/varscan_CopyNumber.out -R "span[hosts=1]" -R "rusage[mem=5000]" -We 48:00 -W 48:00

###
#Adjust for GC content -- Varscan copyCaller
InputCopyCaller=$(echo $mpileupOutName".copynumber")
adjustedCall=$(echo $mpileupOutName".adjustedcall")
homdel=$(echo $mpileupOutName".homdel")

/home/aaronhg/miniconda3/bin/varscan copyCaller $InputCopyCaller --output-file $adjustedCall --output-homdel-file $homdel

#bsub -n 1 -e $PWD/varscan_CopyCaller.err -o $PWD/varscan_CopyCaller.out -R "span[hosts=1]" -R "rusage[mem=1200]" -We 48:00 -W 48:00


###
#Circular binary segmentation using DNACopy
##BEST to split by chromosome!!!!

bash /tiered/smorrissy/aaronhg/adultGBM/Somatic_Calling/run_DNACopy_segmentation.sh $adjustedCall


##TODO ##COMBINE all the chromosome_specific_CBS things!##

#XXX doesn't work from here on !!!!



#sdundoAll=$(echo $1"_"$2".allChrSdundo.txt")
#cat *_sdundo.txt > $sdundoAll

#MergedSdundoAll=$(echo $1"_"$2".allChrSdundo.txt.ASM_merged.txt")
#bash /tiered/smorrissy/aaronhg/adultGBM/Somatic_Calling/merge_sdundo_segments.sh $sdundoAll > $MergedSdundoAll 

###CHECK FOR RECENTER <<OPTIONAL>>

#AbsoluteCNV=$(echo $MergedSdundoAll".absoluteCNV.txt")

#while read -r line; do 
#logRation=$(echo $line | grep -v chrom | awk '{print $5}' | awk '{ print sprintf("%.4f", $0); }' ) && 

#absCNV=$(echo 'e('$logRation'*l(2))*2') | bc -l | awk '{ print sprintf("%.4f", $0); }' ) && 

#echo $line | awk -v var="$absCNV" '{print $1"\t"$2"\t"$3"\t"var}' | sed 's/chr//g'; 
#done < $MergedSdundoAll




##gmerge_segmentompletedSegments.txt
#http://hgdownload.cse.ucsc.edu/goldenpath/hg38/database/cytoBand.txt.gz ---> location of the P and Q arm

#for fileSD in *_Pval_sdundo.txt ; do 

#base=$(echo $fileSD".mergedSegs")
#perl /tiered/smorrissy/aaronhg/adultGBM/Somatic_Calling/mergeSegments.pl $fileSD --ref-arm-sizes /tiered/smorrissy/aaronhg/adultGBM/Somatic_Calling/Varscan_CytoBand_hg38_PnQ_arms_noSexchr.tsv --output-basename $base ; done





###LOH plots (GENVISR)



###CNV plots (GENVISR)


