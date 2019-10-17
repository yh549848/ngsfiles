# NGS related sample file set for testing

## Usage

```bash
workspace="path/to/workspace" && cd ${workspace}
git clone https://github.com/yh549848/ngsfiles.git
```


## Sources

- MAQC A/B sample (SRR896743, SRR896663)
- GENCODE human release 32 (basic)


## FYR: Generating procedure

### Requirements

- [gffread](https://github.com/gpertea/gffread)
- [STAR](https://github.com/alexdobin/STAR)
- [samtools](http://www.htslib.org/)
- [bedtools](https://bedtools.readthedocs.io/en/latest/)

### Download and subsampling FASTQ 

```bash
wget -P tmp -i scripts/uri_fastq.txt 
find tmp/*.fastq.gz | xargs scripts/subsample_fastq.sh
rm tmp/SRR896743_1.fastq.gz tmp/SRR896743_2.fastq.gz tmp/SRR896663_1.fastq.gz tmp/SRR896663_2.fastq.gz
mv tmp/*.*.fastq.gz assets/FASTQ
```

### Download and subsampling GTF

```bash
wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_32/gencode.v32.basic.annotation.gtf.gz -P tmp
gunzip tmp/gencode.v32.basic.annotation.gtf.gz
scripts/subsample_gtf.sh tmp/gencode.v32.basic.annotation.gtf
mv tmp/*.chr*.gtf assets/GTF
```

### Convert GTF to GFF

```bash
for f in `find assets/GTF -name "*.gtf"`; do gffread ${f} -o ${f/.gtf/.gff}; done
mv assets/GTF/*.gff assets/GFF
```

### Align to refrence and extract records located specified chromosome

```bash
wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_32/GRCh38.primary_assembly.genome.fa.gz -P tmp
gunzip tmp/GRCh38.primary_assembly.genome.fa.gz
qsub -V scripts/build_idx_star.sh tmp/GRCh38.primary_assembly.genome.fa
find assets/FASTQ/*.fastq.gz | sort | xargs qsub -V -t 1-4:2 scripts/align_star_pe.sh
cd tmp && cp --parents */*bam ../assets/BAM && cd ${workspace}
find assets/BAM/*/Aligned.sortedByCoord.out*.bam | sort | xargs -I {} samtools index {}
find assets/BAM/*/Aligned.sortedByCoord.out.bam | sort | xargs scripts/subsample_bam.sh
find assets/BAM/*/Aligned.sortedByCoord.out*.bam | sort | xargs -I {} samtools index {}
```

### Convert BAM to BED

```bash
for f in `find assets/BAM -name "*.bam"`; do bedtools bamtobed -i ${f} > ${f/.bam/.bed}; done
cd assets/BAM; cp --parents */*.bed ../BED/ && rm */*.bed; cd ${workspace}
```

### Clean up workspace

```bash
rm tmp/*
```

