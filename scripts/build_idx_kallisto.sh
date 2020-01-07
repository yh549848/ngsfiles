#! /bin/bash
#
# Prepare transcriptome index for kallisto
#
# Usage:
#   qsub this.sh <transcripts.fasta>
#
#$ -S /bin/bash
#$ -l s_vmem=32G -l mem_req=32G
#$ -cwd
#$ -o tmp/
#$ -e tmp/

fasta=$1
output_dir=tmp/kallisto
output="${output_dir}/$(basename $(basename $(basename ${fasta} .fasta) .fa) .fna)"

mkdir -p $output_dir

cmd="kallisto index -i ${output} ${fasta}"

echo $cmd
$cmd
