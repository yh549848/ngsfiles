# NGS related sample file set for testing

## Usage

```bash
git clone https://github.com/yh549848/ngsfiles.git
```


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
rm tmp/SRR896743_1.fastq.gz tmp/SRR896743_2.fastq.gz tmp/SRR896663_1.fastq.gz tmp/SRR896663_2.fastq.gz
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

### Clean up workspace

```bash
rm tmp/*
```
