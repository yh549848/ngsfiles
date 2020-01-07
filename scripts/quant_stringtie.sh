#! /bin/bash
#
# Estimate abundance using StringTie
#
# Usage:
#   find mapping/*.bam | sort | xargs qsub -t 1-n this.sh
#
#$ -S /bin/bash
#$ -l s_vmem=8G -l mem_req=8G
#$ -cwd
#$ -o tmp/
#$ -e tmp/

inputs=($@)
input=${inputs[$((SGE_TASK_ID-1))]}

output_dir=assets/StringTie

if [ ! -e ${output_dir} ]; then
  mkdir -p ${output_dir}
fi

annotation="tmp/gencode.v32.basic.annotation.gtf"
output_gtf="${output_dir}/$(basename $(dirname ${input}))/quant.gtf"
extra_flags="--fr"

cmd="stringtie -e -B -p 8 ${extra_flags} -G ${annotation} -o ${output_gtf} ${input}"
echo ${cmd}
${cmd}
