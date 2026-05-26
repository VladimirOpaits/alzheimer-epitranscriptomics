#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/00_config.sh"

for sample in "${SAMPLES[@]}"; do
  mkdir -p "$DATA_DIR/sqanti/${sample}"
done

for sample in "${SAMPLES[@]}"; do
  echo "SQANTI3: $sample..."

  sqanti3_qc.py \
    --isoforms "$DATA_DIR/stringtie/${sample}/transcripts_requantified.gtf" \
    --refGTF    "$DATA_DIR/reference/gencode.v44.annotation.gtf" \
    --refFasta  "$DATA_DIR/reference/GRCh38.primary_assembly.genome.fa" \
    --dir       "$DATA_DIR/sqanti/${sample}" \
    --output    "${sample}" \
    -t "$THREADS"

  echo "$sample done"
done

echo "SQANTI3 complete"
