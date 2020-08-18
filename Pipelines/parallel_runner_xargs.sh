#!/usr/bin/env bash

source $(conda info --base)/etc/profile.d/conda.sh
conda activate gtc27
#conda activate gtc35

export work_dir=/home2/yup1
export data_dir=/opt/genomics/ohiaatlasqcEIADA

#export code_dir=GTCtoVCF
#export code_dir=GTCtoVCF_github
#export code_dir=GTCtoVCF_github_20200617
export code_dir=dgit-cloudformation-master@e2aa45ae59d/gtc2vcf-batch/Repo/docker/GTCtoVCF

export uid_dir=/opt/genomics/ohiaatlasqcEIADA/data/uid
mkdir -p ${uid_dir}

#export vcf_dir=${work_dir}/output_ismail_more_contig
#export vcf_dir=/opt/genomics/ohiaatlasqcEIADA/data/output/20200617_1.1.1e
#export vcf_dir=/opt/genomics/ohiaatlasqcEIADA/data/output/20200617_1.2.1
#export vcf_dir=/opt/genomics/ohiaatlasqcEIADA/data/output/20200618_1.1.1e
#export vcf_dir=/opt/genomics/ohiaatlasqcEIADA/data/output/20200719_1.1.1e
#export vcf_dir=/opt/genomics/ohiaatlasqcEIADA/data/output/20200617_1.2.1
#export vcf_dir=/opt/genomics/ohiaatlasqcEIADA/data/output/20200617_1.2.1_python3
#export vcf_dir=/opt/genomics/azureatlasqccontainer/AtlasQC_WESTUS/VCF_Sample_AWS/script_yupan/20200728_1.1.1e
#export vcf_dir=/opt/genomics/azureatlasqccontainer/AtlasQC_WESTUS/VCF_Sample_AWS/script_yupan/20200805_1.1.1e
export vcf_dir=/opt/genomics/azureatlasqccontainer/AtlasQC_WESTUS/VCF_Sample_AWS/script_yupan/20200814_1.1.1e

mkdir -p ${vcf_dir}

#export plink_dir=/opt/genomics/ohiaatlasqcEIADA/data/output/20200618_1.1.1e_plink
#export plink_dir=/opt/genomics/ohiaatlasqcEIADA/data/output/20200719_1.1.1e_plink
#export plink_dir=/opt/genomics/azureatlasqccontainer/AtlasQC_WESTUS/VCF_Sample_AWS/script_yupan/20200728_1.1.1e_plink
#export plink_dir=/opt/genomics/azureatlasqccontainer/AtlasQC_WESTUS/VCF_Sample_AWS/script_yupan/20200805_1.1.1e_plink
export plink_dir=/opt/genomics/azureatlasqccontainer/AtlasQC_WESTUS/VCF_Sample_AWS/script_yupan/20200814_1.1.1e_plink

mkdir -p ${plink_dir}

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
##contig=<ID=GL000192.1,length=547496>
##contig=<ID=GL000225.1,length=211173>
##contig=<ID=GL000194.1,length=191469>
##contig=<ID=GL000193.1,length=189789>
##contig=<ID=GL000200.1,length=187035>
##contig=<ID=GL000222.1,length=186861>
##contig=<ID=GL000212.1,length=186858>
##contig=<ID=GL000195.1,length=182896>
##contig=<ID=GL000223.1,length=180455>
##contig=<ID=GL000224.1,length=179693>
##contig=<ID=GL000219.1,length=179198>
##contig=<ID=GL000205.1,length=174588>
##contig=<ID=GL000215.1,length=172545>
##contig=<ID=GL000216.1,length=172294>
##contig=<ID=GL000217.1,length=172149>
##contig=<ID=GL000199.1,length=169874>
##contig=<ID=GL000211.1,length=166566>
##contig=<ID=GL000213.1,length=164239>
##contig=<ID=GL000220.1,length=161802>
##contig=<ID=GL000218.1,length=161147>
##contig=<ID=GL000209.1,length=159169>
##contig=<ID=GL000221.1,length=155397>
##contig=<ID=GL000214.1,length=137718>
##contig=<ID=GL000228.1,length=129120>
##contig=<ID=GL000227.1,length=128374>
##contig=<ID=GL000191.1,length=106433>
##contig=<ID=GL000208.1,length=92689>
##contig=<ID=GL000198.1,length=90085>
##contig=<ID=GL000204.1,length=81310>
##contig=<ID=GL000233.1,length=45941>
##contig=<ID=GL000237.1,length=45867>
##contig=<ID=GL000230.1,length=43691>
##contig=<ID=GL000242.1,length=43523>
##contig=<ID=GL000243.1,length=43341>
##contig=<ID=GL000241.1,length=42152>
##contig=<ID=GL000236.1,length=41934>
##contig=<ID=GL000240.1,length=41933>
##contig=<ID=GL000206.1,length=41001>
##contig=<ID=GL000232.1,length=40652>
##contig=<ID=GL000234.1,length=40531>
##contig=<ID=GL000202.1,length=40103>
##contig=<ID=GL000238.1,length=39939>
##contig=<ID=GL000244.1,length=39929>
##contig=<ID=GL000248.1,length=39786>
##contig=<ID=GL000196.1,length=38914>
##contig=<ID=GL000249.1,length=38502>
##contig=<ID=GL000246.1,length=38154>
##contig=<ID=GL000203.1,length=37498>
##contig=<ID=GL000197.1,length=37175>
##contig=<ID=GL000245.1,length=36651>
##contig=<ID=GL000247.1,length=36422>
##contig=<ID=GL000201.1,length=36148>
##contig=<ID=GL000235.1,length=34474>
##contig=<ID=GL000239.1,length=33824>
##contig=<ID=GL000210.1,length=27682>
##contig=<ID=GL000231.1,length=27386>
##contig=<ID=GL000229.1,length=19913>
##contig=<ID=GL000226.1,length=15008>
##contig=<ID=GL000207.1,length=4262>
""" > ${vcf_dir}/StandardHeader.txt
GRCh37

#<<GRCh37
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
""" > ${vcf_dir}/StandardHeader.txt
#GRCh37

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
""" > ${vcf_dir}/StandardHeader.txt
GRCh38

# PY: Define a function of the transformation: gtc to vcf; then apply "recode&filter -> reheader&annotate -> index" to vcf
convertGTC(){

filter_list="${data_dir}/data/JaeHoon-QC-RemoveRSIDS.txt"
#touch ${filter_list}

# GTC converter - WARNING - Provided manifest name: /home2/yup1/data/small_manifest.csv and manifest file used to generate GTC file: GSAMD-24v1-0_20011747_A1.bpm do not match, skipping
export gtc_manifest="${data_dir}/data/GSAMD-24v1-0_20011747_A1.csv"
#export gtc_manifest="${data_dir}/data/GSAMD-24v1-0_20011747_A1.bpm"

#export gtc_manifest="${work_dir}/data/small_manifest.csv"
#export reference="${data_dir}/data/Homo_sapiens.GRCh38.dna.primary_assembly.fa"
export reference="${data_dir}/data/Homo_sapiens.GRCh37.dna.primary_assembly.fa"

# Modify the gtc_to_vcf code, it's the code inside Ismail's docker, not the code from github
sed -i 's/default=\["GT", "GQ"\], choi/default=\["GT", "GQ", "LRR","BAF"\], choi/' ${work_dir}/${code_dir}/gtc_to_vcf.py
#default=["GT", "GQ"], choices=FormatFactory, choice is cut into choi

gtc_file=$(basename "$1")
echo "$1"
echo "gtc_file: $gtc_file"

# convert gtc_file to vcf
echo """python ${work_dir}/${code_dir}/gtc_to_vcf.py \
--manifest-file ${gtc_manifest} \
--genome-fasta-file ${reference} \
--gtc-paths "$1" \
--skip-indels \
--output-vcf-path "${vcf_dir}/${gtc_file%%.*}.vcf"
"""

python ${work_dir}/${code_dir}/gtc_to_vcf.py \
--manifest-file ${gtc_manifest} \
--genome-fasta-file ${reference} \
--gtc-paths "$1" \
--skip-indels \
--output-vcf-path "${vcf_dir}/${gtc_file%%.*}.vcf"

# PY: vcftools is a suite of functions for use on genetic variation data in the form of VCF and BCF files.
# PY: The tools provided will be used mainly to summarize data, run calculations on data, filter out data, and convert data into other useful file formats.
# PY: Here seems mainly for applying the filter_list
echo """vcftools --vcf "${vcf_dir}/${gtc_file%%.*}.vcf" \
--recode \
--exclude "${filter_list}" \
--out "${vcf_dir}/${gtc_file%%.*}"
"""

vcftools --vcf "${vcf_dir}/${gtc_file%%.*}.vcf" \
--recode \
--exclude "${filter_list}" \
--out "${vcf_dir}/${gtc_file%%.*}"

# Getting UniqueID from Postres Database
#DATABASE_NAME="atlas"
export DATABASE_NAME="AtlasGenotype"

export DB_URL="postgresql://${POSTGRESUSER}:${POSTGRESPSWD}@ohiapsaepgsqlgdbp01.postgres.database.azure.com/AtlasGtcToVcf"

BSID=${gtc_file%%.*}

#echo "${DATABASE_NAME}-${BSID}" > ${uid_dir}/${DATABASE_NAME}-${BSID}-postname.txt
# DON'T DELETE ${uid_dir}/${DATABASE_NAME}-${BSID}-postname.txt

python "${work_dir}/UniqueIDGen/UCLA_register_rename.py" --command rename \
--database_name "$DATABASE_NAME" \
--ext_id "$BSID" \
--db_url "$DB_URL" \
--code_path "${work_dir}/UniqueIDGen" \
--output_path "${uid_dir}"

# Redoing Header of VCF file
# PY: I guess ${DATABASE_NAME}-${BSID}-postname.txt is the output of UCLA_register_rename.py.
# PY: I guess ${gtc_file%%.*}.recode.vcf is the output of aforementioned vcftools.
# BCFtools is a set of utilities that manipulate variant calls in the Variant Call Format (VCF) and its binary counterpart BCF.
bcftools reheader --samples ${uid_dir}/${DATABASE_NAME}-${BSID}-postname.txt  -o ${vcf_dir}/${gtc_file%%.*}.cleaned.vcf ${vcf_dir}/${gtc_file%%.*}.recode.vcf

sed -i '/##contig=/d' ${vcf_dir}/${gtc_file%%.*}.cleaned.vcf

bcftools annotate -h ${vcf_dir}/StandardHeader.txt ${vcf_dir}/${gtc_file%%.*}.cleaned.vcf > ${vcf_dir}/${gtc_file%%.*}.cleaned.reheader.vcf

bgzip -c ${vcf_dir}/${gtc_file%%.*}.cleaned.reheader.vcf > ${vcf_dir}/${gtc_file%%.*}.cleaned.reheader.vcf.gz

# Tabix is the first generic tool that indexes position sorted files in TAB-delimited formats such as GFF, BED, PSL, SAM and SQL export, and quickly retrieves features overlapping specified regions.
# PY: this should generated ${gtc_file%%.*}.cleaned.reheader.vcf.gz.tbi
tabix -p vcf ${vcf_dir}/${gtc_file%%.*}.cleaned.reheader.vcf.gz

#rm ${vcf_dir}/${gtc_file%%.*}.log
rm ${vcf_dir}/${gtc_file%%.*}.vcf
rm ${vcf_dir}/${gtc_file%%.*}.recode.vcf
rm ${vcf_dir}/${gtc_file%%.*}.cleaned.vcf
rm ${vcf_dir}/${gtc_file%%.*}.cleaned.reheader.vcf

}

start_time=`date +%s%N | cut -b1-13`
echo "start_time: $start_time"

# Iterate the list of gtc files in $sample_names and foreach call convertGTC
export -f convertGTC

#input_dir="/home2/yup1/data"
#input_dir="/opt/genomics/azureatlasqccontainer/AtlasQC_WESTUS/iScan Scans/204236570048"
#input_dir="/opt/genomics/azureatlasqccontainer/AtlasQC_WESTUS/iScan\ Scans/204236570048"

#input_dir=$1
#echo "ls -1 \"${input_dir}/*.gtc\""
#ls -1 ${input_dir}/*.gtc  | xargs -n 1 -P 3 -I {} bash -c 'convertGTC "$@"' _ {}


#ls -1 /opt/genomics/azureatlasqccontainer/AtlasQC_WESTUS/iScan\ Scans/204379770103/204379770103_R12C*.gtc > /home2/yup1/list
#ls -1 /opt/genomics/azureatlasqccontainer/AtlasQC_WESTUS/iScan\ Scans/2042265600*/*.gtc > /home2/yup1/list
#ls -1 /opt/genomics/ohiaatlasqcEIADA/data/203954340066_R01C01.gtc > /home2/yup1/list
#ls -1 /opt/genomics/ohiaatlasqcEIADA/data/samples_10/*.gtc > /home2/yup1/list
#ls -1 /opt/genomics/ohiaatlasqcEIADA/data/samples_10/201629300013_R07C02.gtc > /home2/yup1/list

#cat /home2/yup1/list | xargs -n 1 -P 10 -I {} bash -c 'convertGTC "$@"' _ {}
cat /home2/yup1/list_ATLAS_Samples_26322-27470_6_25_2020 | xargs -n 1 -P 10 -I {} bash -c 'convertGTC "$@"' _ {}

echo "==========PLINK TO VCF START=========="
/home2/yup1/vcf_to_plink/run_workflow_py.sh ${vcf_dir} ${plink_dir} 
echo "==========PLINK TO VCF DONE=========="

end_time=`date +%s%N | cut -b1-13`
echo "end_time: $end_time"
runtime=`expr $end_time - $start_time` # ms
echo $runtime

#nohup time ./parallel_runner_xargs.sh > parallel_runner_xargs.log 2>&1 &


