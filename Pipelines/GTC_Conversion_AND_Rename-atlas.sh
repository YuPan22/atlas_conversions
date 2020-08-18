#!/usr/bin/env bash

set -x
export PYTHONPATH=/uniqueID
export SOURCE_BUCKET='s3://ucla-iph-iph-atlas-dev-v1-source-bucket/source_content'
export host='ucla-iph-iph-atlas-gtc2vcfpipeline-dev-v1-id-rds.c1rakudqgbuo.us-west-2.rds.amazonaws.com:5432'
export datab='postgres'
export usname='DatabaseAdmin'
export popp=$(sh /popp.sh $SOURCE_BUCKET)
export DB_URL="postgresql://${usname}:${popp}@${host}/${datab}"

#Change these Parameters before kicking off pipeline or updating ingestion
uploaded_plates='gtc_files'
sample_names='/scratch/source_content/devGTC.txt'
samplesheet='/scratch/source_content/batch_dec2018.csv'
filter_list='/scratch/source_content/JaeHoon-QC-RemoveRSIDS.txt'
export DATABASE_NAME="atlas"

#Defined Variables
export gtc_manifest="/scratch/source_content/GSAMD-24v1-0_20011747_A1.bpm"
export reference="/scratch/source_content/REFERENCE/GRCh37/Homo_sapiens.GRCh37.dna.primary_assembly.fa"
export destination_bucket='s3://ucla-iph-iph-atlas-dev-v1-destination-bucket'
export source_bucket='s3://ucla-iph-iph-atlas-dev-v1-source-bucket'

#Copy Source Content
aws s3 cp --recursive ${source_bucket}/source_content /scratch/source_content/

mkdir -p /scratch/gtc
mkdir -p /scratch/vcf_files
mkdir -p /scratch/final_vcfs

sed -i 's/default=\["GT", "GQ"\], choi/default=\["GT", "GQ", "LRR","BAF"\], choi/' /gtc_to_vcf.py

#Download all gtc files
aws s3 cp ${source_bucket}/${uploaded_plates}/ /scratch/gtc/ --recursive
find /scratch/gtc/ -iname "*.gtc" > $sample_names


convertGTC(){

local gtc_file=$(basename $1)

echo """/usr/local/bin/python /gtc_to_vcf.py \
--manifest-file ${gtc_manifest} \
--genome-fasta-file ${reference} \
--gtc-paths "/scratch/gtc/${gtc_file}" \
--skip-indels \
--output-vcf-path "/scratch/vcf_files/${gtc_file%%.*}.vcf"
"""

/usr/local/bin/python /gtc_to_vcf.py \
--manifest-file ${gtc_manifest} \
--genome-fasta-file ${reference} \
--gtc-paths "/scratch/gtc/${gtc_file}" \
--skip-indels \
--output-vcf-path "/scratch/vcf_files/${gtc_file%%.*}.vcf"


echo """vcftools --vcf "/scratch/vcf_files/${gtc_file%%.*}.vcf" \
--recode \
--exclude "${filter_list}" \
--out "/scratch/vcf_files/${gtc_file%%.*}"
"""

vcftools --vcf "/scratch/vcf_files/${gtc_file%%.*}.vcf" \
--recode \
--exclude "${filter_list}" \
--out "/scratch/vcf_files/${gtc_file%%.*}"

rm /scratch/vcf_files/${gtc_file%%.*}.vcf

#BSID=$(grep ${gtc_file%%.*} ${samplesheet} | awk -F',' '{print $1}')

BSID=${gtc_file%%.*}

#Getting UniqueID from Postres Database
echo """/usr/local/bin/python /scratch/source_content/UCLA_register_rename.py --command rename \
--database_name "$DATABASE_NAME" \
--ext_id "$BSID" \
--db_url "$DB_URL"
"""

/usr/local/bin/python /scratch/source_content/UCLA_register_rename.py --command rename \
--database_name "$DATABASE_NAME" \
--ext_id "$BSID" \
--db_url "$DB_URL"

#Redoing Header of VCF file
bcftools reheader --samples /scratch/${DATABASE_NAME}-${BSID}-postname.txt  -o /scratch/final_vcfs/${gtc_file%%.*}.cleaned.vcf /scratch/vcf_files/${gtc_file%%.*}.recode.vcf

sed -i '/##contig=/d' /scratch/final_vcfs/${gtc_file%%.*}.cleaned.vcf

#Change header to standarized format 1-22 MT Y X
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
""" > /scratch/StandardHeader.txt

bcftools annotate -h /scratch/StandardHeader.txt /scratch/final_vcfs/${gtc_file%%.*}.cleaned.vcf > /scratch/final_vcfs/${gtc_file%%.*}.cleaned.reheader.vcf

bgzip -c /scratch/final_vcfs/${gtc_file%%.*}.cleaned.reheader.vcf > /scratch/final_vcfs/${gtc_file%%.*}.cleaned.reheader.vcf.gz
tabix -p vcf /scratch/final_vcfs/${gtc_file%%.*}.cleaned.reheader.vcf.gz

rm /scratch/gtc_files/${gtc_file}
rm /scratch/final_vcfs/${gtc_file%%.*}.cleaned.vcf
rm /scratch/final_vcfs/${gtc_file%%.*}.cleaned.reheader.vcf
rm /scratch/${DATABASE_NAME}-${BSID}-postname.txt

aws s3 cp /scratch/final_vcfs/${gtc_file%%.*}.cleaned.reheader.vcf.gz ${destination_bucket}/${gtc_file%%.*}.cleaned.reheader.vcf.gz
aws s3 cp /scratch/final_vcfs/${gtc_file%%.*}.cleaned.reheader.vcf.gz.tbi ${destination_bucket}/${gtc_file%%.*}.cleaned.reheader.vcf.gz.tbi

rm /scratch/final_vcfs/${gtc_file%%.*}.cleaned.reheader.vcf.gz
rm /scratch/final_vcfs/${gtc_file%%.*}.cleaned.reheader.vcf.gz.tbi

}

export -f convertGTC

cat $sample_names

cat $sample_names | xargs -n 1 -P 10 -I {} bash -c 'convertGTC "$@"' _ {}
