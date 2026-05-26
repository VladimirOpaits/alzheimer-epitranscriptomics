#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/00_config.sh"

# SQANTI results
echo "Uploading SQANTI results..."
gsutil -m cp -r "$DATA_DIR/sqanti/" "$BUCKET/sqanti/"

# StringTie GTFs
echo "Uploading StringTie GTFs..."
gsutil -m cp -r "$DATA_DIR/stringtie/" "$BUCKET/stringtie/"

# RNA modifications
for sample in "${SAMPLES[@]}"; do
  echo "Uploading BED files for $sample..."
  gsutil -m cp -r "$DATA_DIR/${sample}/bed/" "$BUCKET/modifications/${sample}/"
done

echo "Upload complete"
