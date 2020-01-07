#! /bin/bash
#
# Prepare transcriptome index for RSEM
#   and generate Ng vector for EBSeq
#
# Usage:
#   qsub this.sh <transcripts.fasta>
#
#$ -S /bin/bash
#$ -l s_vmem=16G -l mem_req=16G
#$ -cwd
#$ -o tmp/
#$ -e tmp/

fasta=$1
output_base=$(basename $(basename ${fasta} .fasta) .fa)
output_dir=tmp

mkdir -p ${output_dir}/rsem
mkdir -p ${output_dir}/ebseq

output_prefix_rsem=${output_dir}/rsem/${output_base}

# Build index
cmd="rsem-prepare-reference \
    ${fasta} \
    ${output_prefix_rsem}"
echo ${cmd}
${cmd}


# Generate ngvector for EBSeq
# WARNING: Rscript execution in the container cannot find EBSeq library　included in RSEM
output_prefix_ebseq=${output_dir}/ebseq/${output_base}

cmd="rsem-generate-ngvector \
    ${fasta} \
    ${output_prefix_ebseq}.tmp"
echo ${cmd}
${cmd}

# Combine transcript name and ngvector
echo "grep \">\" ${fasta} > ${output_prefix_ebseq}.tmp.names"
grep '>' ${fasta} > ${output_prefix_ebseq}.tmp.names

echo sed -e 's/^>//' ${output_prefix_ebseq}.tmp.names
sed -e 's/^>//' ${output_prefix_ebseq}.tmp.names > ${output_prefix_ebseq}.tmp.names.trimmed

cmd="paste ${output_prefix_ebseq}.tmp.names.trimmed ${output_prefix_ebseq}.tmp.ngvec"
echo ${cmd}
${cmd} > ${output_prefix_ebseq}.ngvec
