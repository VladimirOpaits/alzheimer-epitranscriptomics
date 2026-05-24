#!/bin/bash
set -e
DATA_DIR="/home/vlad/data"

mkdir -p $DATA_DIR/stringtie/{alzheimer,alzheimer2,healthy,healthy2}

for sample in alzheimer alzheimer2 healthy healthy2; do
  echo "Processing $sample..."
  
  stringtie $DATA_DIR/${sample}/bam/*.bam \
    -L \
    -G $DATA_DIR/reference/gencode.v44.annotation.gtf \
    -o $DATA_DIR/stringtie/${sample}/transcripts.gtf \
    -p 8

  grep -v "_random\|_alt\|_fix\|chrUn" \
    $DATA_DIR/stringtie/${sample}/transcripts.gtf \
    > $DATA_DIR/stringtie/${sample}/transcripts_filtered.gtf

  echo "$sample done"
done

echo "StringTie complete"
