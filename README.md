# NGS related files for testing

## Usage

```bash
workspace="path/to/workspace" && cd ${workspace}
git clone https://github.com/yh549848/ngsfiles.git
```


## Sources

- [MAQC A/B sample (SRR896743, SRR896663)](https://www.ncbi.nlm.nih.gov/bioproject/PRJNA208369)
- [GENCODE human release 32 (basic)](https://www.gencodegenes.org/)


## FYR: Generating procedure

### Tools used

- [bedtools](https://bedtools.readthedocs.io/en/latest/)
- [gffread](https://github.com/gpertea/gffread)
- [HTSeq-count](https://htseq.readthedocs.io/en/release_0.11.1/index.html)
- [kallisto](https://pachterlab.github.io/kallisto/)
- [RSEM](https://deweylab.github.io/RSEM/)
- [samtools](http://www.htslib.org/)
- [STAR](https://github.com/alexdobin/STAR)
- [StringTie](https://ccb.jhu.edu/software/stringtie/)

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
./scripts/subsample_gtf.sh tmp/gencode.v32.basic.annotation.gtf
mv tmp/*.chr*.gtf assets/GTF
```

### Convert GTF to GFF

```bash
for f in `find assets/GTF -name "*.gtf"`; do gffread ${f} -o ${f/.gtf/.gff}; done
mv assets/GTF/*.gff assets/GFF
```

### Align to reference and extract records located specified chromosome

```bash
wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_32/GRCh38.primary_assembly.genome.fa.gz -P tmp
gunzip tmp/GRCh38.primary_assembly.genome.fa.gz
qsub -V scripts/build_idx_star.sh tmp/GRCh38.primary_assembly.genome.fa
find assets/FASTQ/*.fastq.gz | sort | xargs qsub -V -t 1-4:2 scripts/align_star_pe.sh
cd tmp && cp --parents */*bam ../assets/BAM && cd ${workspace}
find assets/BAM/*/Aligned.sortedByCoord.out.bam | sort | xargs -I {} samtools index {}
find assets/BAM/*/Aligned.sortedByCoord.out.bam | sort | xargs -I {} scripts/subsample_bam.sh {}
find assets/BAM/*/Aligned.sortedByCoord.out*.bam | sort | xargs -I {} samtools index {}
```

### Quant by RSEM

```bash
gffread -w tmp/gencode.v32.basic.transcripts_with_attr.fa -g tmp/GRCh38.primary_assembly.genome.fa tmp/gencode.v32.basic.annotation.gtf
./scripts/strip_attributes_fasta.py tmp/gencode.v32.basic.transcripts_with_attr.fa > tmp/gencode.v32.basic.transcripts.fa
qsub -V scripts/build_idx_rsem_with_ebseq_ngvector.sh tmp/gencode.v32.basic.transcripts.fa
find assets/BAM/*/Aligned.sortedByCoord.out.bam | sort | xargs qsub -V -t 1-2 scripts/quant_rsem.sh
```

### Quant by StringTie

```bash
find assets/BAM/*/Aligned.sortedByCoord.out.bam | sort | xargs qsub -V -t 1-2 scripts/quant_stringtie.sh
find assets/StringTie/*/*.gtf | xargs -I {} gzip {}
```

### Quant by kallisto

```bash
find assets/FASTQ/*.fastq.gz | sort | xargs qsub -V -t 1-4:2 scripts/quant_kallisto.sh
```

### Quant by htseq-count

```bash
find assets/BAM/*/Aligned.sortedByCoord.out.bam | sort | xargs qsub -V -t 1-2 scripts/quant_htseq.sh 
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

