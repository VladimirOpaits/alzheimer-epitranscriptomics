#!/bin/bash
# Merge per-sample GTFs into a unified transcriptome reference.
# Run after 03_stringtie.sh, before 04_sqanti.sh.
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/00_config.sh"

GTF_LIST=()
for sample in "${SAMPLES[@]}"; do
  GTF_LIST+=("$DATA_DIR/stringtie/${sample}/transcripts_filtered.gtf")
done

echo "Merging ${#SAMPLES[@]} GTFs..."
stringtie --merge \
  "${GTF_LIST[@]}" \
  -G "$DATA_DIR/reference/gencode.v44.annotation.gtf" \
  -o "$DATA_DIR/stringtie/merged.gtf"

echo "Merged GTF: $DATA_DIR/stringtie/merged.gtf"
