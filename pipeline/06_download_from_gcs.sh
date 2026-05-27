#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
DEST="$REPO_DIR/data/alzheimer-lrseq"
GTF_DEST="$REPO_DIR/.data/stringtie"

mkdir -p "$DEST"

echo "Downloading SQANTI classification files..."
for sample in alzheimer alzheimer2 healthy healthy2; do
  mkdir -p "$DEST/sqanti/$sample"
  gsutil cp "gs://alzheimer-lrseq/sqanti/$sample/${sample}_classification.txt" "$DEST/sqanti/$sample/"
done

echo "Downloading BED modification files..."
for sample in alzheimer alzheimer2 healthy healthy2; do
  echo "  $sample"
  mkdir -p "$DEST/modifications/$sample"
  gsutil -m cp -r "gs://alzheimer-lrseq/modifications/$sample" "$DEST/modifications/"
done

echo "Downloading StringTie GTF files..."
for sample in alzheimer alzheimer2 healthy healthy2; do
  mkdir -p "$GTF_DEST/$sample"
  gsutil cp "gs://alzheimer-lrseq/stringtie/$sample/transcripts_filtered.gtf" "$GTF_DEST/$sample/"
done

echo "Done. Data at: $DEST, GTF at: $GTF_DEST"
