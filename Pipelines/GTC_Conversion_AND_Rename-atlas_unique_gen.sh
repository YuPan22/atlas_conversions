#!/usr/bin/env bash

source $(conda info --base)/etc/profile.d/conda.sh
conda activate gtc27

set -x
export host='localhost:5432'

#export datab='postgres'
export datab='AtlasGtcToVcf'

#export usname='postgres'
#export usname='gtctovcfloader@ohiapsaepgsqlgdbp01'
#export popp=$(sh /popp.sh $SOURCE_BUCKET)
#export popp="postgre_pswd22"
#export DB_URL="postgresql://${usname}:${popp}@${host}/${datab}"
#export DB_URL="postgresql://${usname}:@${host}/${datab}"
#export DB_URL="postgresql://${usname}:${PGPASSWORD}@${host}/${datab}"
export DB_URL="postgresql://gtctovcfloader@ohiapsaepgsqlgdbp01:fqv2mIyQnFsg9d9@ohiapsaepgsqlgdbp01.postgres.database.azure.com/AtlasGtcToVcf"

export DATABASE_NAME="AtlasGenotype"  # this is the key stored in "eiada_Config"."DataSource"

convertGTC(){

local gtc_file=$(basename $1)

#BSID=$(grep ${gtc_file%%.*} ${samplesheet} | awk -F',' '{print $1}')

BSID=${gtc_file%%.*}

#/usr/local/bin/python /scratch/source_content/UCLA_register_rename.py --command rename \
#python /Users/yp/Downloads/atlas/dgit-cloudformation-master@b385f1c933e/gtc2vcf-batch/Pipelines/scripts/UCLA_register_rename_py.py --command rename \
python "/Users/yp/Google Drive/think for mac/ucla_health/ucla/atlas/UniqueIDGen/UCLA_register_rename.py" --command rename \
--database_name "$DATABASE_NAME" \
--ext_id "$BSID" \
--db_url "$DB_URL" \
--code_path "/Users/yp/Google Drive/think for mac/ucla_health/ucla/atlas/UniqueIDGen" \
--output_path "/Users/yp/Downloads/atlas/test"

#Redoing Header of VCF file
#bcftools reheader --samples /scratch/${DATABASE_NAME}-${BSID}-postname.txt  -o /scratch/final_vcfs/${gtc_file%%.*}.cleaned.vcf /scratch/vcf_files/${gtc_file%%.*}.recode.vcf

}

export -f convertGTC

sample_names='/Users/yp/Downloads/atlas/GTCtoVCF/data/gtcs/203954340066_R01C07.gtc'
echo $sample_names | xargs -n 1 -P 10 -I {} bash -c 'convertGTC "$@"' _ {}
