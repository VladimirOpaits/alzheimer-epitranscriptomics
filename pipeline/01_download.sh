#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/00_config.sh"

for sample in "${SAMPLES[@]}"; do
  mkdir -p "$DATA_DIR/${sample}/bam"
  mkdir -p "$DATA_DIR/${sample}/bed"
done
mkdir -p "$DATA_DIR/reference"

# BAM files
for sample in "${SAMPLES[@]}"; do
  bam="${BAM_FILE[$sample]}"
  echo "Downloading BAM for $sample ($bam)..."
  curl -o "$DATA_DIR/${sample}/bam/${bam}" \
    -L "https://www.encodeproject.org/files/${bam%.*}/@@download/${bam}"
done

# BED modification files
for sample in "${SAMPLES[@]}"; do
  echo "Downloading BED files for $sample..."
  for id in ${BED_IDS[$sample]}; do
    curl -o "$DATA_DIR/${sample}/bed/${id}.bed.gz" \
      -L "https://www.encodeproject.org/files/${id}/@@download/${id}.bed.gz"
  done
done

# Reference genome and annotation
echo "Downloading reference genome and annotation..."
wget -P "$DATA_DIR/reference/" \
  https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_44/GRCh38.primary_assembly.genome.fa.gz
wget -P "$DATA_DIR/reference/" \
  https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_44/gencode.v44.annotation.gtf.gz

gunzip "$DATA_DIR/reference/gencode.v44.annotation.gtf.gz"
gunzip "$DATA_DIR/reference/GRCh38.primary_assembly.genome.fa.gz"

# FANTOM5 CAGE peaks (hg38) — for SQANTI3 TSS validation
echo "Downloading FANTOM5 CAGE peaks..."
wget -P "$DATA_DIR/reference/" \
  https://fantom.gsc.riken.jp/5/datafiles/reprocessed/hg38_latest/extra/CAGE_peaks/hg38_fair+new_CAGE_peaks_phase1and2.bed.gz

gunzip "$DATA_DIR/reference/hg38_fair+new_CAGE_peaks_phase1and2.bed.gz"

echo "Download complete"
