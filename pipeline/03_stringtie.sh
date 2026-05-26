#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/00_config.sh"

for sample in "${SAMPLES[@]}"; do
  mkdir -p "$DATA_DIR/stringtie/${sample}"
done

for sample in "${SAMPLES[@]}"; do
  echo "StringTie: $sample..."

  stringtie "$DATA_DIR/${sample}/bam/${BAM_FILE[$sample]}" \
    -L \
    -G "$DATA_DIR/reference/gencode.v44.annotation.gtf" \
    -o "$DATA_DIR/stringtie/${sample}/transcripts.gtf" \
    -p "$THREADS"

  grep -v "_random\|_alt\|_fix\|chrUn" \
    "$DATA_DIR/stringtie/${sample}/transcripts.gtf" \
    > "$DATA_DIR/stringtie/${sample}/transcripts_filtered.gtf"

  echo "$sample done"
done

echo "StringTie complete"
