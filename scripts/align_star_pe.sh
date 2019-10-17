#! /bin/bash
#
# Map reads to genome and transcripts using STAR
#
# Usage:
#   find '*.fastq.gz' | sort | xargs qsub -t 1-n:2 this.sh
#
#$ -S /bin/bash
#$ -pe def_slot 8
#$ -l s_vmem=8G -l mem_req=8G
#$ -cwd
#$ -o ./tmp/
#$ -e ./tmp/


inputs=($@)
r1=${inputs[$((SGE_TASK_ID-1))]}
r2=${inputs[$((SGE_TASK_ID))]}
output_dir="tmp/$(basename ${r1} .fastq.gz)"

if [ ! -e ${output_dir} ]; then
  mkdir -p ${output_dir}
fi


star_index="tmp/GRCh38.primary_assembly.genome"
annotation="tmp/gencode.v32.basic.annotation.gtf"
library_id=""      # Library identifier which will be added to bam header.
ncpus=8            # Number of cpus available.
ram_GB=48          # ram memory avaliable for STAR sorting

# Additional options from ENCODE pipeline
# --sjdbGTFfile: Highly recommended (described in the manual)
# --readNameSeparator: For polyester generated reads
# --outReadsUnmapped Fastx: Collect unmapped reads
# --readFilesCommand zcat: For gz compressed input
cmd="STAR --genomeDir ${star_index} \
    --runThreadN $ncpus --genomeLoad NoSharedMemory \
    --outFilterMultimapNmax 20 --alignSJoverhangMin 8 --alignSJDBoverhangMin 1 \
    --outFilterMismatchNmax 999 --outFilterMismatchNoverReadLmax 0.04 \
    --alignIntronMin 20 --alignIntronMax 1000000 --alignMatesGapMax 1000000 \
    --outSAMheaderCommentFile COfile.txt --outSAMheaderHD @HD VN:1.4 SO:coordinate \
    --outSAMunmapped Within --outFilterType BySJout --outSAMattributes NH HI AS NM MD \
    --outSAMtype BAM SortedByCoordinate --quantMode TranscriptomeSAM --sjdbScore 1 \
    --limitBAMsortRAM ${ram_GB}000000000 \
    --sjdbGTFfile ${annotation} \
    --readNameSeparator \"|\" \
    --outReadsUnmapped Fastx \
    --readFilesCommand zcat \
    --readFilesIn "

echo ${cmd} ${r1} ${r2} --outFileNamePrefix ${output_dir}/
${cmd} ${r1} ${r2} --outFileNamePrefix ${output_dir}/
