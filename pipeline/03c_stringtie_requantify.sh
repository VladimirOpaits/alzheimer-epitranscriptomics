#!/bin/bash
# Second-pass StringTie: requantify each sample against the merged transcriptome.
# -e restricts output to transcripts in the reference GTF (no new assembly).
# This puts all samples in the same coordinate space before SQANTI/ML.
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/00_config.sh"

MERGED_GTF="$DATA_DIR/stringtie/merged.gtf"

if [[ ! -f "$MERGED_GTF" ]]; then
  echo "ERROR: $MERGED_GTF not found. Run 03b_stringtie_merge.sh first."
  exit 1
fi

for sample in "${SAMPLES[@]}"; do
  mkdir -p "$DATA_DIR/stringtie/${sample}"
  echo "Requantifying $sample against merged GTF..."

  stringtie "$DATA_DIR/${sample}/bam/${BAM_FILE[$sample]}" \
    -L \
    -e \
    -G "$MERGED_GTF" \
    -o "$DATA_DIR/stringtie/${sample}/transcripts_requantified.gtf" \
    -p "$THREADS"

  echo "$sample done"
done

echo "Requantification complete"
