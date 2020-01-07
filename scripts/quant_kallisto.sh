#! /bin/bash
#
# Qantification using kallisto
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
r1=${inputs[$((SGE_TASK_ID-1))]}
r2=${inputs[$((SGE_TASK_ID))]}

output_dir="assets/kallisto/${output_dir}/$(basename ${r1} .fastq.gz)"

if [ ! -e ${output_dir} ]; then
  mkdir -p ${output_dir}
fi

index="tmp/kallisto/gencode.v32.basic.transcripts"
gtf="tmp/gencode.v32.basic.annotation.gtf"

opts_extra="-t 4 --seed 42 -b 100"

cmd="kallisto quant \
     -i ${index} \
     -o ${output_dir} \
     --pseudobam \
     --genomebam \
     --gtf ${gtf} \
     ${opts_extra} \
     ${r1} ${r2}"

echo $cmd
$cmd
