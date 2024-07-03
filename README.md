# Functional-annotation-of-regulatory-elements-in-rainbow-trout



## Rainbow Trout

## Bioinformatics Methods and Analysis Steps

## ChipSeq

#### Trim low-quality base and adapter using trimgalor and fastqc

``` bash
# check QC within the same directory of the fastq
# -t number of threads
fastqc -t 6 *.fq.gz
multiqc .
firefox multiqc_report.html

# or create a folder such as trim
mkdir trim
cd trim
# and run the following command
# for individual pair end file
trim_galore --paired --length 50 --cores 4 --fastqc R1.fastq R2.fstq
# or for all files
for i in *R1_001.fastq.gz; do j=${i/R1/R2} ; trim_galore --paired  --cores  4 --fastqc  $i $j ; done
# --fastqc will run the fastqc and remove any low-quality reads
```

#### Build bowtie2 index and map reads

``` bash
# create bowtie2 index using Arlee refrence genome  
bowtie2-build GCF_013265735.2_USDA_OmykA_1.1_genomic.fna Arleebowtie2

# map reads
# for pair-end reads adding the 2>> tmp_file will save the state of the mapping
 for i in *R1_001_val_1.fq.gz ; do echo $i >> map_stat  ; j=${i/R1/R2} ; out=${i/R1_001_val_1\.fq\.gz/Arl\.bam}; out=${out/fastq/trim}; bowtie2 -p 4 -q --end-to-end --very-sensitive  -x /scratch3/trout_ChipSeq/genomeArlee/Arleebowtie2   -p 24  -k 10 -x  /path_to_refrence_genome/Arlee_bowtie/Arleebowtie2 -q  $i   $j 2>> map_stat  |  samtools     view  -h -bS -o $out; done
 
 # Using Samtools, sort the bam file and create an index file
 # sort bam and create an index
 for i in *bam; do samtools index $i ; done
 for i in *bam ; do  out=${i/\.bam/sorted\.bam} ; samtools sort --threads 6 $i -o $out ; done
 
 # filter based on 20 q
 for i in *sorted.bam ; do out=${i/sorted/filtered_sorted};  samtools view  -q 20 -b -o     $out  $i  ; done
 for i in *filtered_sorted.bam ; do  samtools index  $i  ; done

 # Use picard tools to mark duplicate                                                                      
for i in *filtered_sorted.bam; do out=${i/orted/orted_PCRDup};  java -jar ~/path_to_Picard/picard.jar MarkDuplicates I=$i O=$out  M=Aligned_Sorted_PCRD.txt AS=true ; done
```

#### Use macs tool for peak calling

``` bash
# The following parameters were used for macs2
  -n: name string
  -g: genome size as 2341688614
  --keep-dup, '3': this is an arbitrary number, and we select to keep three  
  --extsize, '200': extend reads in 5'->3' direction to 200 bp
  -B: store the fragment pileup, control lambda in bedGraph files
  --SPMR 
  -q, '0.01' for narrow marks
  -q, '0.05' for broad marks
 # We calculated peak numbers for each mark as follows:
 # narrow_peaks: [H3K4me3, H3K4me1, H3K27ac]
 # broad_peaks: [H3K27me3]
  
 # narrow peaks calling
 # [H3K4me3, H3K4me1, H3K27ac]
for i in  H3K4me3*PCRDup.bam; do in=${i/H3K4me3/Input}; outdir=${i/H3K4me3*PCRDup\.bam/Peak_H3K4me3}  ; out=${i/sorted_PCRDup\.bam/NarrowPeak};  out=${out/\/nfshome\/path\/Chipseq\/Map_0_sort\//}; macs3 callpeak -t $i -c $in -f BAM -g 2.3e9 -n $out --outdir $outdir  --keep-dup 3 -B --SPMR -q 0.01   ; done
 
 # broad peaks calling 
 for i in  H3K27me3*PCRDup.bam; do in=${i/H3K27me3/Input}; outdir=${i/H3K27me3*PCRDup\.bam/Peak_H3K27me3}  ;out=${i/sorted_PCRDup\.bam/NarrowSpecialPeak};      out=${out/\/nfshome\/path\/Chipseq\/Map_0_sort\//}; macs3 callpeak -t $i -c $in -f BAM -g 2.3e9 -n $out --outdir $outdir  --keep-dup 3 -B --SPMR  --broad --broad-cutoff 0.1   ;  done
```

#### ATACseq Analysis

``` bash
# Analysis follows the same procedures in the chipSeq and uses broad peaks
for i in *RDup.bam; do   out=${i/RDup\.bam/broadPeak};   out=${out/\/path\/ATAC\/trim\//}; macs3 callpeak -t $i  -f BAM -g 2.3e9 -n $out --outdir /path/ATAC/trim/Peak_ATAC/  --keep-dup 3 -B --SPMR -q 0.05 --broad --broad-cutoff 0.1 ; done
```

#### Peak annotation

``` bash
# We use ChIPseeker R package for annotation 
# and we Use the Homer to annotate the peaks
for i in *summits.bed ; do out=${i/summits\.bed/Annotated\.csv} ; annotatePeaks.pl $i  /localstorage/TroutNewGenome/OmyArlee_1_1/TroutArlee.fa -gtf /localstorage/TroutNewGenome/OmyArlee_1_1/TroutArlee.gtf 2>> Annotatio_stat.txt > $out ; done
```

#### Methylation Analysis

``` bash
# QC and trim using cut adapter through Trimglore and used fastqc for quality control
 or i in *R1.fq.gz ; do j=${i/R1/R2} ; trim_galore --paired --cores 6 --fastqc $i $j ; done
 
 #Alignments and methylation calling
 #Bismark_genome_preparation ../genome/The folder of the genome has a fast file and includes bowtie index files, too
 #genome had to be prepared before using
 bismark_genome_preparation [options] <path_to_genome_folder>
  
 # mapping data using Bismark
 for i in *val_1.fq.gz ; do j=${i/R1/R2} ; j=${j/_1\./_2\.}; bismark --non_directional --local  ../genome_Arrly/ -1 $i -2 $j -p 4 ; done
 
 
 #extract CpG sites use bismark_methylation_extractor with --cytosine_report to get genome-wide methylation
for i in *deduplicated.bam ; do bismark_methylation_extractor -p   --merge_non_CpG  --multicore 2  --scaffolds  --genome_folder ../genome/ --cytosine_report   --bedGraph --gzip $i ; done
 ## for individual run
 bismark_methylation_extractor -p  --include_overlap --merge_non_CpG   --scaffolds  --output  ../Bismark_clip53_local/   --genome_folder /localstorage/Methylation_Data/genome/  --cytosine_report   --bedGraph --gzip  zr4449_10_S9_R1_001_val_1_bismark_bt2_pe.deduplicated.bam
 
 
## Output header of Bismark
# The coverage output end with .cov
<chromosome> <start position> <end position> <methylation percentage> <count methylated> <count unmethylated>

# genome wide header
#the file end with the following : bismark_bt2_pe.CpG_report.txt.gz
<chromosome> <position> <strand> <count methylated> <count unmethylated> <C-context>  <trinucleotide context>

#further analysis using a local script
# Append to the file info about CPG location within the promoter and TSS               
get_meth_cluster_1k.pl to get the location within TSS

#get island info from island files from NCBI and annotate the CpG file
```

#### ChromHMM analysis

``` bash
#chromHMM analysis
 # Prepare the genome files as follows
 #find the chromosome length and store the file in the directory chromHMM directory
 samtools faidx refrenceGenome.fa
 cut -f1,2 refrenceGenome.fai > TroutArrly_chrom_lenth
  
 # Convert gtf or gff to genePred and bigGenePred.txt file of ucsc browser use the next two steps
 gtfToGenePred Omyk_2.0_sorted.gtf Omyk_2.0_genePred -allErrors
 genePredToBigGenePred Omyk_2.0_genePred Omyk_2.0_bigGenePred.txt
  
  
 # Add the trout genome to the chromHmm directory by running the following code in the ~/path/ChromHMM/ANCHORFILES directory
java -mx32G -jar ~/path/ChromHMM/ChromHMM.jar ConvertGeneTable -l /path/TroutArlee_ChrLength -noheader -w 2000 -biggenepred   /path/TroutArlee.bigGen Arlee Trout

 # Use bedtools to convert bam files to bed files using                                              

for i in *sorted_PCRDup.bam; do out=${i/\.bam/\.bed} ; bamToBed -i $i > $out ; done
 
 # Prepare the cellmarkfiletable.txt file, such as
 #use all available tissue in our case, we use sex chipseq and 3 atac seq 
 # file available for references
 cell1 mark1 cell1_mark1.bed cell1_control.bed
 cell1 mark2 cell1_mark2.bed cell1_control.bed
 cell2 mark1 cell2_mark1.bed cell2_control.bed
 cell2 mark2 cell2_mark2.bed cell2_control.bed
 Brain_FA        H3K27ac H3K27ac_Brain_FAsorted.bed      Input_Brain_FAsorted.bed
 Brain_FB        H3K27ac H3K27ac_Brain_FBsorted.bed      Input_Brain_FBsorted.bed
 Spleen_FA       H3K4me3 H3K4me3_Spleen_FAsorted.bed     Input_Spleen_FAsorted.bed
 Spleen_FB       H3K4me3 H3K4me3_Spleen_FBsorted.bed     Input_Spleen_FBsorted.bed
  

# Convert bed file to binarize as one of these command
java -mx32G -jar ~/path_to/ChromHMM.jar BinarizeBed -b 200  path_to_/TroutArlee_ChrLength  /pathh_to_dicroty_hold_bed_files/BED_files/  cellmarkfiletable.txt /Output_directory/
  
  
# Run the model using different models and determine the one based on genomic features
# All bed files used for annotation are available in the SupportFile folder
#java -mx32G -jar ChromHMM.jar LearnModel /binarizedDataDirctory  MYOUTPUTDirectory 10  hg18
java -mx32G -jar ~/path_to/ChromHMM.jar  LearnModel  -p 6 -printstatebyline -printposterior  /path_to_binaries_files_directory/ /OUTPUTdirectory  10 Trout
```

#### ChromHMM plot generating data

``` bash
# The following analysis was used to create data for several plots
 #for emission coverage, use the missions_xx.txt file
 #convert it to csv, clean the header, and reorder it using awk script in Vim
 % !awk 'BEGIN {OFS=","}; {print $1, $6, $3, $4, $5, $2}'
  
 # #### Calculate Cov average and std
 # Create an overlap list using the Linux command
 ls *overlap.txt > overlap_list
 while read p; do touch New_overlap; cut -f2 $p |paste -  New_overlap > TTM_NEW ; mv TTM_NEW New_overlap  ; done < overlap_list
 #after cleaning the file and converting it to csv, remove the top and bottom lines
 #convert it to a csv file
 # use the following Python script with numpy as follow # part of the code
 import numpy as np
 array = np.loadtxt('New_overlap.csv',  delimiter=',')
 # find std
 y = np.std(array, axis=1)
 # find the mean
 row_mean = np.mean(array, axis=1)
 #convert the array to dataframe
 df1 = pd.DataFrame(row_mean, columns = ['State'])
# and plot it as a heatmap

 
## Retrieve the individual stat for all tissue combined into one file. OLD APPROACH
##./parse_chrohmm_chr_start_any.pl file_list
 
#combin state for down analysis not used for enrichment using Python and the actual result 
### To get enrichment, the following steps used
#split, sort, and merge based on overlap by at least 1 base
for i in *_10_dense.bed; do for j in {1..10} ;do  grep -P "\t$j\t" $i >> stat$j.csv ;   done ; done
for i in stat* ; do out=${i/\.csv/_sort\.csv} ; sort -k1,1 -k2,2n $i  > $out ; done 
for i in *sort.csv ; do out=${i/sort\.csv/merg\.csv} ; bedtools merge -i $i >  $out ; done 
for i in {1..10};  do   in=stat"$i"_merg.csv; s=s/$/\\t"$i"/  ; sed -i $s $in  ; done      
# This will add the stat to the file, which needed later on for the cluster file
for i in {1..10} ; do in=stat"$i"_merg.csv ; out=Enr_stat$i.Arrly; bedtools intersect -a ~/path/Arrly_annotaion_file_Enrichmnet_sorted -b $in -wo  > $out ; done
# Arrly_annotaion_file_Enrichmnet_sorted file that has all the features as a bed file, such as
      NC_048565.1 2098683 2098684 TES
      NC_048565.1 2100171 2100172 TES
      NC_048565.1 2100171 2101044 Exon
      NC_048565.1 2100171 2130819 Gene
      NC_048565.1 2100172 2100783 3UTR
      NC_048565.1 2100172 2130819 Exp_G                                                  
      NC_048565.1 2100172 2130819 transcript
      NC_048565.1 2100784 2100786 stop_codon
      NC_048565.1 2100784 2130653 muscl_qtl
      NC_048565.1 2100787 2101044 CDS
      NC_048565.1 2101349 2101433 Exon
      NC_048565.1 2101350 2101433 CDS
      NC_048565.1 2109216 2109407 Exon
      NC_048565.1 2109217 2109407 CDS
      NC_048565.1 2110707 2110863 Exon
      NC_048565.1 2110708 2110863 CDS
      NC_048565.1 2118979 2119108 Exon
      NC_048565.1 2118980 2119108 CDS
      NC_048565.1 2130559 2130819 Exon
      NC_048565.1 2130560 2130653 CDS
      NC_048565.1 2130651 2130653 start_codon
      NC_048565.1 2130654 2130819 5UTR
      NC_048565.1 2130818 2130819 TSS
      NC_048565.1 2151397 2154150 CpG

#preparing overlap file data
  
make backup for  the *ovelap.txt
for i in *overlap.txt ; do out=${i/txt/txtbackup} ; cp $i $out ; done
for i in *overlap.txt ;do  sed -i s/\%// $i; sed -i s/\(Emission// $i; sed -i s/order\)// $i; sed -i s/.Trout.bed//g $i; sed -i s/.bed//g $i; sed -i -r 's/[[:blank:]]+/,/g' $i; done
python3.10 ~/COMMAND/group_overlap.py
clean the file by removing last line and rename it


```

## 
