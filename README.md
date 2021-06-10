# mgSNP_2
mgSNP_2 (metagenomic SNP) analysis.	\
Version = 2.0	\
Date = March 10, 2020	\
DOI= 10.5281/zenodo.3706776 \
Note: This workflow is an updated version (version 2.0) of mgSNP (https://github.com/ranjit58/mgSNP). 

Provided scripts were written to work on SLURM cluster, thus included SLURM specific code for job submission. 

Requirements
------------
1. BWA
2. PICARD 
3. GATK 
4. VCFTools
5. BEDTools
6. Trimmomatic 
7. Unix command Parallel
8. Metaphlan2
9. SAMtools

Installation
------------
Download all provided scripts and reference folder. Then, please follow the commands below.	\
Create a folder that will be used for the analysis.	

>mkdir Test	\
>cd Test		

Then, put the downloaded reference folder and all the scripts into the Test folder.	\
Create a RAWDATA folder and put raw sequence files into the RAWDATA folder.

>mkdir RAWDATA	\
>cd RAWDATA	\
>ls	#this should show all your sequence files	\
>cd ..

It is now ready to modify config information. Note that files in reference folder are compressed. Make sure decompressed files before running the analysis. 

Config information
------------
Configuration information needs to be stored in a config file. An example of the config file has provided as “mgSNP.config.txt”. Please modify the folder paths and other necessary information. 

Usage
------------
All the commands will be executed in the Test folder created above. \
The "samples.list" file includes the name of all samples, without any extension such as fastq.gz. This file needs to be modified based on your sample names.	\
The "genomes.list" file includes the list of 93 reference genomes with the size that we have used for the analysis. 

The stepwise analysis process is as described below.	

Stepwise analysis
------------
1. Assume three samples (SampleA, SampleB, and SampleC; paired-end) are placed into the RAWDATA folder. The format of the sample pair should be SampleA_F.fastq.gz, SampleA_R.fastq.gz, SampleB_F.fastq.gz, SampleB_R.fastq.gz, SampleC_F.fastq.gz, and SampleC_R.fastq.gz.

2. (Optional) Remove host genome. If necessary, the host genome such as the human genome or mouse genome can be filtered from your raw sequence reads by running below command.
>sbatch filter_hostGenome.sh

Output: Create ${SAMPLE}_host_removed_F.fastq.gz and ${SAMPLE}_host_removed_R.fastq.gz. files in the RAWDATA folder.  

3. Perform QC. We used Trimmomatic for quality checks and preserved the mapping/correspondence of paired reads. We ignored single-end reads which created after the QC step for further analysis. Parameters for Trimmomatic can be modified, if necessary. 
>sbatch run_mgSNP_QC_afterHost.sh

Output: Creates a directory RAWDATA_QC with four files (two paired files and two single unmapped reads file) for each sample. The unpaired files such as ${SAMPLE}_F_P.fastq.gz and ${SAMPLE}_R_P.fastq.gz are used for further analysis.

4. BWA. Uses BWA-mem to map filtered reads on the 93 reference sequence to generate SAM file. 
>sbatch run_mgSNP_bwa.sh

Output: Creates a folder BWA_FILES with all sam files such as ${SAMPLE}.sam.

5. Filter SAM file to exclude reads mapped on multiple locations (XA: alternative hits) and if they are less than 90% similar. If necessary to change variables such as minimum alignment length and/or minimum percent match for the filtering process, edit the mgSNP_sam-filter.py. 
>sbatch run_mgSNP_sam-filter.sh

Output: Creates a folder BWA_FILTERED with filtered sam files such as ${SAMPLE}.filtered.sam and ${SAMPLE}.filtered2.sam

6. Follow GATK best practices before SNP calling. This script uses main script mgSNP_gatk.sh. If necessary, modify this file. 
>sbatch run_mgSNP_gatk-STEPS.sh 

Output: Creates a folder GATK_STEPS with BAM files, one for each sample. ${SAMPLE}_realigned.bai and ${SAMPLE}_realigned.bam files will be used for further analysis. Also, a list of bam files (bam.list) will be created. Additionally, bash mgSNP_gatk-SNP.sh within run_mgSNP_gatk-STEPS.sh will write the script (both command and job file separately) to call SNP (VCF files) using GATK for each sample and for each genome separately. This is a preparation step before running run_mgSNP_gatk-SNP.sh. 

>sbatch run_mgSNP_gatk-SNP.sh 

Output: Creates a folder GATK_SNP, inside that, one folder for each genome having VCF files such as ${SAMPLE}.g.vcf and ${SAMPLE}.g.vcf.idx. The bash mgSNP_gatk-GVCF.sh within the run_mgSNP_gatk-SNP.sh will creates a job file each genome – preparation step before running below command. 

>sbatch run_mgSNP_gatk-GVCF.sh 

Output: Create joint SNP calls (Multi-sample SNP calling) for each genome (all samples) within GATK_MULTISNP folder. It creates a vcf list of all samples for a given genome and creates a multi-sample VCF file for that genome such as Acidaminococcus_sp_D21.vcf and Acidaminococcus_sp_D21_vcf.idx.

7. Calculate coverage and depth. VCFtools is used to output how many bases are covered by at least 1 read (used to calculated coverage), and what is the mean depth in that region. The below command will calculate the coverage and depth for all samples for all genomes.
>sbatch run_mgSNP_cov.sh

Output: Creates a folder COV_STATS with the file allcov.stats, that has information that can be used to calculate coverage (use excel). Depth information is already included.

Note: The allcov.stats includes depth and coverage for each sample & each genome. The coverage is the total length of bases it can capture, which has to be compared with genomes.list (genome length) to calculate % genome coverage. We used genome coverage 30% and depth 3.5X in this analysis, however, this parameter can be edited as genome coverage 40% and depth 5X to increase accuracy.

8. The genome and sample for which pairwise calculation needs to be done are put on a file name filtered.txt (the first two columns of allcov.stats file). The format is like a genome name and sample name separated by a tab.
>Bacteroides_vulgatus    SampleA \
>Bacteroides_vulgatus    SampleB \
>Bacteroides_vulgatus    SampleC 

To make all pairwise comparisons of all samples for all genomes or selected genomes based on depth and coverage information, you can generate filtered.txt using below command
>cut -f 1,2 allcov.stats > filtered.txt 

Then, run below command to organize the data where each row has a genome and the samples being compared.
>bash mgSNP_transform.sh 

This command will create list_for_compare.txt file. The list_for_compare.txt file looks like below (each species is in one line). 
>Bacteroides_vulgatus SampleA SampleB SampleC

9. Run the pairwise comparison by running the below command. 
>bash mgSNP_compare.sh

This script will create several SLURM jobs for each genome and submits them to the cluster.\
Then, run below command. 
>sbatch run_mgSNP_compare.sh 

Output: Creates a folder COMPARE, inside that, one folder for each genome which has all the job script for pairwise comparison.

10. Summarize the comparisons by running the below command.
>cat COMPARE/*/*.out > all_comparison.out

Output: all_comparison.out file is created that has the pairwise similarity information with WSS Score. The list of Columns is as below.
>Genome/Species \
>Sample1 \
>Sample2 \
>Minimum genome coverage for two sample \
>WSS Score (percent identical windows) \
>Total windows count \
>Total good/usable windows count \
>Count of Identical windows count \
>Count of Non-identical windows count \
>Count of No SNP windows count \
>Loci count having Same SNP \
>Loci count having different base/SNP - 01 (snp in sample2 but not in sample 1) \
>Loci count having different base/SNP - 10 (snp in sample1 but not in sample 2)

11 (Optional) Run MetaPhlAn2 to observe entire taxonomic profile in each sample. 
>sbatch run_metaphlan_all.sh 

Output: creates a folder METAPHLAN, inside that, each sample will have bowtie.bz2 and profile.txt file. 
