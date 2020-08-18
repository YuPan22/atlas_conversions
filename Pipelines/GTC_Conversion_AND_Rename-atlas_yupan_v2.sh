#!/usr/bin/env bash

source $(conda info --base)/etc/profile.d/conda.sh
conda activate gtc27


# PY: Define a function of the transformation: gtc to vcf; then apply "recode&filter -> reheader&annotate -> index" to vcf
#convertGTC(){

work_dir=/home2/yup1
mkdir -p ${work_dir}/output
mkdir -p ${work_dir}/BSID

filter_list="${work_dir}/data/JaeHoon-QC-RemoveRSIDS.txt"
#touch ${filter_list}

# GTC converter - WARNING - Provided manifest name: /home2/yup1/data/small_manifest.csv and manifest file used to generate GTC file: GSAMD-24v1-0_20011747_A1.bpm do not match, skipping
export gtc_manifest="${work_dir}/data/GSAMD-24v1-0_20011747_A1.csv"
#export gtc_manifest="${work_dir}/data/small_manifest.csv"
export reference="${work_dir}/data/Homo_sapiens.GRCh38.dna.primary_assembly.fa"

# Modify the gtc_to_vcf code, it's the code inside Ismail's docker, not the code from github
# sed -i 's/default=\["GT", "GQ"\], choi/default=\["GT", "GQ", "LRR","BAF"\], choi/' ${work_dir}/GTCtoVCF/gtc_to_vcf.py

gtc_file=$(basename "$1")
echo "$1"
echo "gtc_file: $gtc_file"

# convert gtc_file to vcf
echo """python ${work_dir}/GTCtoVCF/gtc_to_vcf.py \
--manifest-file ${gtc_manifest} \
--genome-fasta-file ${reference} \
--gtc-paths "$1" \
--skip-indels \
--output-vcf-path "${work_dir}/output/${gtc_file%%.*}.vcf"
"""

python ${work_dir}/GTCtoVCF/gtc_to_vcf.py \
--manifest-file ${gtc_manifest} \
--genome-fasta-file ${reference} \
--gtc-paths "$1" \
--skip-indels \
--output-vcf-path "${work_dir}/output/${gtc_file%%.*}.vcf"

# PY: vcftools is a suite of functions for use on genetic variation data in the form of VCF and BCF files.
# PY: The tools provided will be used mainly to summarize data, run calculations on data, filter out data, and convert data into other useful file formats.
# PY: Here seems mainly for applying the filter_list
echo """vcftools --vcf "${work_dir}/output/${gtc_file%%.*}.vcf" \
--recode \
--exclude "${filter_list}" \
--out "${work_dir}/output/${gtc_file%%.*}"
"""

vcftools --vcf "${work_dir}/output/${gtc_file%%.*}.vcf" \
--recode \
--exclude "${filter_list}" \
--out "${work_dir}/output/${gtc_file%%.*}"

# Getting UniqueID from Postres Database
DATABASE_NAME="atlas"
BSID=${gtc_file%%.*}
echo "${DATABASE_NAME}-${BSID}" > ${work_dir}/BSID/${DATABASE_NAME}-${BSID}-postname.txt

# Redoing Header of VCF file
# PY: I guess ${DATABASE_NAME}-${BSID}-postname.txt is the output of UCLA_register_rename.py.
# PY: I guess ${gtc_file%%.*}.recode.vcf is the output of aforementioned vcftools.
# BCFtools is a set of utilities that manipulate variant calls in the Variant Call Format (VCF) and its binary counterpart BCF.
bcftools reheader --samples ${work_dir}/BSID/${DATABASE_NAME}-${BSID}-postname.txt  -o ${work_dir}/output/${gtc_file%%.*}.cleaned.vcf ${work_dir}/output/${gtc_file%%.*}.recode.vcf

sed -i '/##contig=/d' ${work_dir}/output/${gtc_file%%.*}.cleaned.vcf

# Change header to standarized format 1-22 MT Y X
<<GRCh37
echo """##contig=<ID=1,length=249250621>
##contig=<ID=2,length=243199373>
##contig=<ID=3,length=198022430>
##contig=<ID=4,length=191154276>
##contig=<ID=5,length=180915260>
##contig=<ID=6,length=171115067>
##contig=<ID=7,length=159138663>
##contig=<ID=8,length=146364022>
##contig=<ID=9,length=141213431>
##contig=<ID=10,length=135534747>
##contig=<ID=11,length=135006516>
##contig=<ID=12,length=133851895>
##contig=<ID=13,length=115169878>
##contig=<ID=14,length=107349540>
##contig=<ID=15,length=102531392>
##contig=<ID=16,length=90354753>
##contig=<ID=17,length=81195210>
##contig=<ID=18,length=78077248>
##contig=<ID=19,length=59128983>
##contig=<ID=20,length=63025520>
##contig=<ID=21,length=48129895>
##contig=<ID=22,length=51304566>
##contig=<ID=MT,length=16569>
##contig=<ID=X,length=155270560>
##contig=<ID=Y,length=59373566>
""" > ${work_dir}/output/StandardHeader.txt
GRCh37

<<GRCh38
echo """##contig=<ID=1,length=248956422>
##contig=<ID=2,length=242193529>
##contig=<ID=3,length=198295559>
##contig=<ID=4,length=190214555>
##contig=<ID=5,length=181538259>
##contig=<ID=6,length=170805979>
##contig=<ID=7,length=159345973>
##contig=<ID=8,length=145138636>
##contig=<ID=9,length=138394717>
##contig=<ID=10,length=133797422>
##contig=<ID=11,length=135086622>
##contig=<ID=12,length=133275309>
##contig=<ID=13,length=114364328>
##contig=<ID=14,length=107043718>
##contig=<ID=15,length=101991189>
##contig=<ID=16,length=90338345>
##contig=<ID=17,length=83257441>
##contig=<ID=18,length=80373285>
##contig=<ID=19,length=58617616>
##contig=<ID=20,length=64444167>
##contig=<ID=21,length=46709983>
##contig=<ID=22,length=50818468>
##contig=<ID=MT,length=16569>
##contig=<ID=X,length=156040895>
##contig=<ID=Y,length=57227415>
""" > ${work_dir}/output/StandardHeader.txt
GRCh38

bcftools annotate -h ${work_dir}/output/StandardHeader.txt ${work_dir}/output/${gtc_file%%.*}.cleaned.vcf > ${work_dir}/output/${gtc_file%%.*}.cleaned.reheader.vcf
bgzip -c ${work_dir}/output/${gtc_file%%.*}.cleaned.reheader.vcf > ${work_dir}/output/${gtc_file%%.*}.cleaned.reheader.vcf.gz

# Tabix is the first generic tool that indexes position sorted files in TAB-delimited formats such as GFF, BED, PSL, SAM and SQL export, and quickly retrieves features overlapping specified regions.
# PY: this should generated ${gtc_file%%.*}.cleaned.reheader.vcf.gz.tbi
tabix -p vcf ${work_dir}/output/${gtc_file%%.*}.cleaned.reheader.vcf.gz

rm ${work_dir}/BSID/${DATABASE_NAME}-${BSID}-postname.txt
rm ${work_dir}/output/${gtc_file%%.*}.log
rm ${work_dir}/output/${gtc_file%%.*}.vcf
rm ${work_dir}/output/${gtc_file%%.*}.recode.vcf
rm ${work_dir}/output/${gtc_file%%.*}.cleaned.vcf
rm ${work_dir}/output/${gtc_file%%.*}.cleaned.reheader.vcf

#}

# Iterate the list of gtc files in $sample_names and foreach call convertGTC
# export -f convertGTC

#input_dir="/home2/yup1/data"
#input_dir="/opt/genomics/azureatlasqccontainer/AtlasQC_WESTUS/iScan Scans/204236570048"
#input_dir="/opt/genomics/azureatlasqccontainer/AtlasQC_WESTUS/iScan\ Scans/204236570048"

#ls -1 "${input_dir}/*.gtc" | xargs -n 1 -P 10 -I {} bash -c 'convertGTC "$@"' _ {}
