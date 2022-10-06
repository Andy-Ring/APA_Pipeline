#!/bin/bash

#This bash script assumes that you have created .bam alignment files from your RNA Sequencing run. This script will convert those .bam file to .bedgraph files and run APA Trap. It also assumes that you have a text file with a list of your sample ID'S called "ids". APA Trap is not a part of bioconda and must be downloaded directly from sourceforge.

#First activate a bioinformaics environement

source /home/ringa/miniconda3/bin/activate bioinfo

#First we set some paths

#Path to directory containing .bam files and ids file

p = /data/ringa/ryandata/bam

#Path to reference transcripts in .bed format

r = /home/ringa/refs/hg38.bed

#Path to directory containing APAtrap scripts

a = /home/ringa/bin

# The first step in formatting the .bedgraph files is converting .bam files to .bed files using bedtools

cat $p/ids | parallel "bedtools bamtobed -i $p/{}.bam > $p/bed/{}.bed"

#This script allows for you to keep the .bed files becuase they can be useful in other pipelines. However, they will not be needed for APA trap. Next we convert .bed to .bedgraph by cutting colums no longer needed, sorting the intervals and mergering overlapping intervals

cat $p/ids | parallel "cut -f1-3,5 $p/bed/{}.bed > $p/bedgraph/{}.bedgraph | sort -k1,1 -k2,2n $p/bedgraph/{}.bedgraph > $p/bedgraph/{}.bedgraph | bedtools merge -i $p/bedgraph/{}.bedgraph -c 4 -d 0 -o max > $p/bedgraph/{}.bedgraph"

#Now that the conversion to .bedgraph is complete, we can run the first script of APA trap which is identifyDistal3UTR

$a/identifyDistal3UTR -i $p/bedgraph/*.bedgraph -m $r -o $p/apa/utr.bed

#The next step in APA trap is to run the script predictAPA. These parameters are specific for myexperimetnal setup. The parameters can be adjusted, check the APA trap github for details

$a/predictAPA -i $p/bedgraph/*.bedgraph -g 3 -n 15 20 16 -u $p/apa/utr.bed -o $p/apa/APA.txt

#After the APA have been called, we can perform differential APA site usage by applying the R package deAPA. THis is best run on your local machine by exporting the APA.txt file and running deAPA.r through Rstudio

#end
