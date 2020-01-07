#! /bin/bash
#
# Prepare index for STAR
#
# Usage:
#   qsub this.sh <genome.fasta>
#
#$ -S /bin/bash
#$ -pe def_slot 8
#$ -l s_vmem=8G -l mem_req=8G
#$ -cwd
#$ -o ./tmp/
#$ -e ./tmp/

fasta=$1
gtf=$2

output_dir=tmp/star
output_base=$(basename $(basename ${fasta} .fasta) .fa)

mkdir -p ${output_dir}/${output_base}

cmd="STAR --runThreadN 8 --runMode genomeGenerate --genomeDir ${output_dir}/${output_base} --genomeFastaFiles ${fasta}"
echo $cmd
$cmd
