#!/bin/env bash

threads=4

#plink_dir=/home2/yup1/vcf_to_plink
plink_dir=/opt/genomics/azureatlasqccontainer/AtlasQC_WESTUS/VCF_Sample_AWS/script_yupan

#input_dir=/opt/genomics/azureatlasqccontainer/AtlasQC_WESTUS/VCF_Sample_AWS/script_test/vcf_files_big
#output_dir=/opt/genomics/azureatlasqccontainer/AtlasQC_WESTUS/VCF_Sample_AWS/output

input_dir=$1
output_dir=$2

<<ABOUT_PLINK
Download plink 1.9 from https://www.cog-genomics.org/plink2/
scp -r plink_linux_x86_64_20200616 yup1@lapgnomap20:/opt/genomics/azureatlasqccontainer/AtlasQC_WESTUS/VCF_Sample_AWS/script_test/
ABOUT_PLINK

########### Merging VCF files ##########

# First generate list of VCF files to combine
ls ${input_dir}/*.vcf.gz > ${output_dir}/vcf_merge_list
#ls ${input_dir}/2042*.cleaned.reheader.vcf.gz > ${output_dir}/vcf_merge_list
#ls ${input_dir}/2043*.cleaned.reheader.vcf.gz > ${output_dir}/vcf_merge_list

# To do a merge using bcftools, we must index files
# Use --tbi for tabix index since it is more common
<<COMMENTOUT
for each in $(ls ${input_dir}/*.vcf.gz);
do
	bcftools index --tbi --threads ${threads} $each
done
COMMENTOUT

<<OUTPUT
[E::main_vcfindex] the index file exists. Please use '-f' to overwrite vcf_files/201334780033_R01C01.cleaned.vcf.tbi
[E::main_vcfindex] the index file exists. Please use '-f' to overwrite vcf_files/201334780033_R01C02.cleaned.vcf.tbi


vcf_files
	201334780033_R01C01.cleaned.vcf
	201334780033_R01C01.cleaned.vcf.tbi
	201334780033_R01C02.cleaned.vcf
	201334780033_R01C02.cleaned.vcf.tbi
OUTPUT

# Use bcftools to combine the VCFs
# -Oz flag output as a compressed VCF, which should help with space
# Use more threads to speed it up, but not necessarily needed
echo "start bcftools merge -l ${output_dir}/vcf_merge_list -o ${output_dir}/merged.vcf.gz -Oz --threads ${threads}"
bcftools merge -l ${output_dir}/vcf_merge_list -o ${output_dir}/merged.vcf.gz -Oz --threads ${threads}

<<OUTPUT
merged.vcf.gz
OUTPUT

####### Converting merged VCF to PLINK ########

## There are two ways to convert to PLINK: VCFtools or PLINK

## Using VCFtools is probably the more foolproof way since it has less options that we need to control

# Use VCFtools to output as PLINK PED and MAP
echo "start vcftools --gzvcf ${output_dir}/merged.vcf.gz --out ${output_dir}/vcftools_convert --plink"
vcftools --gzvcf ${output_dir}/merged.vcf.gz --out ${output_dir}/vcftools_convert --plink

<<OUTPUT
VCFtools - v0.1.13
(C) Adam Auton and Anthony Marcketta 2009

Parameters as interpreted:
	--gzvcf merged.vcf.gz
	--out vcftools_convert
	--plink

Using zlib version: 1.2.7
After filtering, kept 2 out of 2 Individuals
Writing PLINK PED and MAP files ... 
	PLINK: Only outputting biallelic loci.
Done.
After filtering, kept 687347 out of a possible 687347 Sites
Run Time = 5.00 seconds


vcftools_convert.log
vcftools_convert.map
vcftools_convert.ped
OUTPUT

########### Use VCFtools to generate VCF by chromosome ###########

## We can generate the VCF by chromosome from merged VCF
## 	or we can generate it from PLINK files
mkdir ${output_dir}/vcftools_chr_split
# Split by chromosome from VCF file
for i in $(seq 1 22);
do
	# Use VCFtools to split by chromosome
	# --recode-INFO-all flag make sure all INFO fields are kept
	# --recode is the flag that actually output files
	vcftools --gzvcf ${output_dir}/merged.vcf.gz --chr "$i" --recode-INFO-all --out ${output_dir}/vcftools_chr_split/vcf_chr"$i" --recode
	# Run through bgzip to compress and reduce size
	bgzip -f ${output_dir}/vcftools_chr_split/vcf_chr"$i".recode.vcf
done

<<OUTPUT
Parameters as interpreted:
	--gzvcf merged.vcf.gz
	--chr 1
	--recode-INFO-all
	--out vcftools_chr_split/vcf_chr1
	--recode

Using zlib version: 1.2.7
After filtering, kept 2 out of 2 Individuals
Outputting VCF file...
After filtering, kept 54668 out of a possible 687347 Sites
Run Time = 2.00 seconds


vcftools_chr_split
	vcf_chr1.log
	vcf_chr1.recode.vcf.gz
	...
	vcf_chr22.log
	vcf_chr22.recode.vcf.gz
OUTPUT


# Use PLINK to convert to PLINK PED and MAP
# Use --keep-allele-order to make sure PLINK doesn't flip alleles
# --double-id is for preserving naming convention
# --recode produces MAP and PED
# Could also potentially convert this step straight to BED/BIM/FAM
#/opt/genomics/tools/plink-1.90-x86_64/plink190 --vcf merged.vcf.gz --out plink_convert --double-id --keep-allele-order --recode
${plink_dir}/plink_linux_x86_64_20200616/plink --vcf ${output_dir}/merged.vcf.gz --out ${output_dir}/plink_convert --double-id --keep-allele-order --recode

<<OUTPUT
PLINK v1.90b6.18 64-bit (16 Jun 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to plink_convert.log.
Options in effect:
  --double-id
  --keep-allele-order
  --out plink_convert
  --recode
  --vcf merged.vcf.gz

64411 MB RAM detected; reserving 32205 MB for main workspace.
--vcf: plink_convert-temporary.bed + plink_convert-temporary.bim +
plink_convert-temporary.fam written.
687347 variants loaded from .bim file.
2 people (0 males, 0 females, 2 ambiguous) loaded from .fam.
Ambiguous sex IDs written to plink_convert.nosex .
Using 1 thread (no multithreaded calculations invoked).
Before main variant filters, 2 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Warning: Nonmissing nonmale Y chromosome genotype(s) present; many commands
treat these as missing.
Total genotyping rate is 0.99258.
687347 variants and 2 people pass filters and QC.
Note: No phenotypes present.
--recode ped to plink_convert.ped + plink_convert.map ... done.


plink_convert.nosex
plink_convert.ped
plink_convert.map
plink_convert.log
OUTPUT


########### Use PLINK to generate VCF by chromosome ###########
mkdir ${output_dir}/plink_chr_split
# Split by chromosome from PLINK file
for i in $(seq 1 22);
do
	# --recode vcf-iid bgz preserves sample labels and bgzips
	# --keep-allele-order and --real-ref-alleles preserve allele coding
	#/opt/genomics/tools/plink-1.90-x86_64/plink190 --file plink_convert --chr "$i" --out plink_chr_split/plink_chr_"$i" --recode vcf-iid bgz --keep-allele-order --real-ref-alleles
	${plink_dir}/plink_linux_x86_64_20200616/plink --file ${output_dir}/plink_convert --chr "$i" --out ${output_dir}/plink_chr_split/plink_chr_"$i" --recode vcf-iid bgz --keep-allele-order --real-ref-alleles	
done

<<OUTPUT
PLINK v1.90b6.18 64-bit (16 Jun 2020)          www.cog-genomics.org/plink/1.9/
(C) 2005-2020 Shaun Purcell, Christopher Chang   GNU General Public License v3
Logging to plink_chr_split/plink_chr_1.log.
Options in effect:
  --chr 1
  --file plink_convert
  --keep-allele-order
  --out plink_chr_split/plink_chr_1
  --real-ref-alleles
  --recode vcf-iid bgz

64411 MB RAM detected; reserving 32205 MB for main workspace.
.ped scan complete (for binary autoconversion).
Performing single-pass .bed write (54668 variants, 2 people).
--file: plink_chr_split/plink_chr_1-temporary.bed +
plink_chr_split/plink_chr_1-temporary.bim +
plink_chr_split/plink_chr_1-temporary.fam written.
54668 variants loaded from .bim file.
2 people (0 males, 0 females, 2 ambiguous) loaded from .fam.
Ambiguous sex IDs written to plink_chr_split/plink_chr_1.nosex .
Using up to 31 threads (change this with --threads).
Before main variant filters, 2 founders and 0 nonfounders present.
Calculating allele frequencies... done.
Total genotyping rate is 0.992921.
54668 variants and 2 people pass filters and QC.
Note: No phenotypes present.
--recode vcf-iid bgz to plink_chr_split/plink_chr_1.vcf.gz ... done.

plink_chr_split
	plink_chr_1.log
	plink_chr_1.nosex
	plink_chr_1.vcf.gz
	...
	plink_chr_22.log
	plink_chr_22.nosex
	plink_chr_22.vcf.gz
OUTPUT
