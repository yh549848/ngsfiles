#! /bin/bash
#
# Qant using HTSeq-count
#
# Usage:
#   find ./fastq.gz | sort | xargs qsub -t 1-n:2 this.sh
#
#$ -S /bin/bash
#$ -l s_vmem=16G -l mem_req=16G
#$ -cwd
#$ -o tmp/
#$ -e tmp/

inputs=($@)
input=${inputs[$((SGE_TASK_ID-1))]}
output_dir="assets/HTSeq/$(basename $(dirname ${input}))"

if [ ! -e ${output_dir} ]; then
  mkdir -p ${output_dir}
fi

output="${output_dir}/counts.txt"

gtf="tmp/gencode.v32.basic.annotation.gtf"
opts_extra="--stranded no -f bam -i transcript_id -m union"

cmd="htseq-count \
  ${strand} \
  ${opts_extra} \
  ${input} \
  ${gtf} \
  > ${output}"
echo $cmd
eval $cmd
