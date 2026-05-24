#!/bin/bash
set -e
DATA_DIR="/home/vlad/data"

mkdir -p $DATA_DIR/sqanti/{alzheimer,alzheimer2,healthy,healthy2}

for sample in alzheimer alzheimer2 healthy healthy2; do
  echo "Running SQANTI3 on $sample..."
  
  sqanti3_qc.py \
    --isoforms $DATA_DIR/stringtie/${sample}/transcripts_filtered.gtf \
    --refGTF $DATA_DIR/reference/gencode.v44.annotation.gtf \
    --refFasta $DATA_DIR/reference/GRCh38.primary_assembly.genome.fa \
    --dir $DATA_DIR/sqanti/${sample} \
    --output ${sample} \
    -t 8

  echo "$sample done"
done

echo "SQANTI3 complete"
