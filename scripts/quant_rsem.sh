#! /bin/bash
#
# Quantificate expression using RSEM
#
# Usage:
#   find '*.bam' | sort | xargs qsub -t 1-n this.sh
#
#$ -S /bin/bash
#$ -l s_vmem=48G -l mem_req=48G
#$ -cwd
#$ -o tmp/
#$ -e tmp/


inputs=($@)
input=${inputs[$((SGE_TASK_ID-1))]}
output_dir="assets/RSEM/$(basename $(dirname ${input}))"

if [ ! -e ${output_dir} ]; then
  mkdir -p ${output_dir}
fi

index_prefix="tmp/rsem/gencode.v32.basic.transcripts"
rnd_seed=12345
ncpus=4
extra_flags="--paired-end --strandedness none"

cmd="rsem-calculate-expression \
    --bam --estimate-rspd --calc-ci --seed ${rnd_seed} -p ${ncpus} \
    --no-bam-output --ci-memory 30000 ${extra_flags} \
    ${input} \
    ${index_prefix} \
    ${output_dir}/quant"

echo ${cmd}
${cmd}
