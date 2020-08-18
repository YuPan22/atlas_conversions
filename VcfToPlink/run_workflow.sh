#!/bin/env bash


########### Merging VCF files ##########

# First generate list of VCF files to combine
ls vcf_files/*vcf > vcf_merge_list

# To do a merge using bcftools, we must index files
# Use --tbi for tabix index since it is more common
for each in $(ls vcf_files/*vcf);
do
	bcftools index --tbi --threads 4 $each
done

# Use bcftools to combine the VCFs
# -Oz flag output as a compressed VCF, which should help with space
# Use more threads to speed it up, but not necessarily needed
bcftools merge -l vcf_merge_list -o merged.vcf.gz -Oz --threads 4


####### Converting merged VCF to PLINK ########

## There are two ways to convert to PLINK: VCFtools or PLINK

## Using VCFtools is probably the more foolproof way
## 	since it has less options that we need to control


# Use VCFtools to output as PLINK PED and MAP
vcftools --gzvcf merged.vcf.gz --out vcftools_convert --plink

# Use PLINK to convert to PLINK PED and MAP
# Use --keep-allele-order to make sure PLINK doesn't flip alleles
# --double-id is for preserving naming convention
# --recode produces MAP and PED
# Could also potentially convert this step straight to BED/BIM/FAM
/opt/genomics/tools/plink-1.90-x86_64/plink190 --vcf merged.vcf.gz --out plink_convert --double-id --keep-allele-order --recode


########### Generating VCF by chromosome ###########

## We can generate the VCF by chromosome from merged VCF
## 	or we can generate it from PLINK files

mkdir vcftools_chr_split
# Split by chromosome from VCF file
for i in $(seq 1 22);
do
	# Use VCFtools to split by chromosome
	# --recode-INFO-all flag make sure all INFO fields are kept
	# --recode is the flag that actually output files
	vcftools --gzvcf merged.vcf.gz --chr "$i" --recode-INFO-all --out vcftools_chr_split/vcf_chr"$i" --recode
	# Run through bgzip to compress and reduce size
	bgzip vcftools_chr_split/vcf_chr"$i".recode.vcf
done

mkdir plink_chr_split
# Split by chromosome from PLINK file
for i in $(seq 1 22);
do
	# --recode vcf-iid bgz preserves sample labels and bgzips
	# --keep-allele-order and --real-ref-alleles preserve allele coding
	/opt/genomics/tools/plink-1.90-x86_64/plink190 --file plink_convert --chr "$i" --out plink_chr_split/plink_chr_"$i" --recode vcf-iid bgz --keep-allele-order --real-ref-alleles
done



