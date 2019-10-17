# NGS related sample file set for testing

## Usage



## Sources

- MAQC A/B sample (SRR896743, SRR896663)

- GENCODE human release 32 (comprehensive)



## Generating procedure

### Requirements

- [gffread](https://github.com/gpertea/gffread)
- [STAR](https://github.com/alexdobin/STAR)
- [bedtools](https://bedtools.readthedocs.io/en/latest/)

### Download and subsampling FASTQ 

```bash
cat scripts/uri_fastq.txt | xargs -P 4 -n 1 wget -P tmp -i
find tmp/*.fastq.gz | xargs scripts/subsample_fastq.sh
rm SRR896743_1.fastq.gz SRR896743_2.fastq.gz SRR896663_1.fastq.gz SRR896663_2.fastq.gz
mv tmp/*.fastq.gz assets/FASTQ
```

### Download and subsampling GTF

```bash
wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_32/gencode.v32.annotation.gtf.gz -P tmp
gunzip tmp/gencode.v32.annotation.gtf.gz
cat tmp/gencode.v32.annotation.gtf | grep "^chr1[[:space:]]" > tmp/gencode.v32.annotation.chr1.gtf
cat tmp/gencode.v32.annotation.gtf | grep "^chr11" > tmp/gencode.v32.annotation.chr11.gtf
cat tmp/gencode.v32.annotation.gtf | grep "^chr21" > tmp/gencode.v32.annotation.chr21.gtf
rm tmp/gencode.v32.annotation.gtf
```

### Convert GTF to GFF

```bash
for f in `find tmp -name "*.gtf"`;do gffread ${f} -o ${f/.gtf/.gff};done
mv tmp/*.gtf assets/GTF
mv tmp/*.gff assets/GFF
```

### Align to genome and transcriptome (@UGE)

```bash
find assets/FASTQ/*.fastq.gz | sort | xargs qsub -t 1-6:2 scripts/align_star_pe.sh --output-dir tmp
```

### Extract records located specified chromosome

```bash
find tmp/*.bam | xargs -I{} samtools view -b {} chr1 > {}.chr1
find tmp/*.bam | xargs -I{} samtools view -b {} chr11 > {}.chr11
find tmp/*.bam | xargs -I{} samtools view -b {} chr21 > {}.chr11
```

### Remove work files

```bash
rm tmp/*
```

