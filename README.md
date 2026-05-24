# Alzheimer Epitranscriptomics

Long-read RNA-seq analysis of isoform landscape and RNA modifications in Alzheimer's disease prefrontal cortex.

## Samples
| Sample | Condition | Age | ENCODE ID |
|--------|-----------|-----|-----------|
| alzheimer | AD | 90y | ENCSR872GND |
| alzheimer2 | AD | 86y | ENCSR543NWW |
| healthy | Control | 90y | ENCSR111GJE |
| healthy2 | Control | 85y | ENCSR697CSS |

Nanopore Direct RNA-seq, dorsolateral prefrontal cortex, female, Ali Mortazavi lab UCI.

## Pipeline
1. `01_download.sh` — download BAM + bed files from ENCODE + reference genome
2. `02_index.sh` — index BAM files with samtools
3. `03_stringtie.sh` — isoform assembly
4. `04_sqanti.sh` — isoform classification
5. `05_upload_gcs.sh` — upload results to GCS bucket

## Environment
- StringTie2: conda env `stringtie`
- SQANTI3: conda env `sqanti3`
- samtools: system

## Directory Structure
# Alzheimer Epitranscriptomics

Long-read RNA-seq analysis of isoform landscape and RNA modifications in Alzheimer's disease prefrontal cortex.

## Samples
| Sample | Condition | Age | ENCODE ID |
|--------|-----------|-----|-----------|
| alzheimer | AD | 90y | ENCSR872GND |
| alzheimer2 | AD | 86y | ENCSR543NWW |
| healthy | Control | 90y | ENCSR111GJE |
| healthy2 | Control | 85y | ENCSR697CSS |

Nanopore Direct RNA-seq, dorsolateral prefrontal cortex, female, Ali Mortazavi lab UCI.

## Pipeline
1. `01_download.sh` — download BAM + bed files from ENCODE + reference genome
2. `02_index.sh` — index BAM files with samtools
3. `03_stringtie.sh` — isoform assembly
4. `04_sqanti.sh` — isoform classification
5. `05_upload_gcs.sh` — upload results to GCS bucket

## Environment
- StringTie2: conda env `stringtie`
- SQANTI3: conda env `sqanti3`
- samtools: system

## Directory Structure
```
data/
  alzheimer/bam/
  alzheimer/bed/
  alzheimer2/bam/
  alzheimer2/bed/
  healthy/bam/
  healthy/bed/
  healthy2/bam/
  healthy2/bed/
  reference/
  stringtie/
  sqanti/
```
