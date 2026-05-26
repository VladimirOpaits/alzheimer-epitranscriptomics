#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/00_config.sh"

for sample in "${SAMPLES[@]}"; do
  bam="$DATA_DIR/${sample}/bam/${BAM_FILE[$sample]}"
  echo "Indexing $bam..."
  samtools index "$bam" &
done
wait

echo "Indexing complete"
