#!/bin/bash
set -e
DATA_DIR="/home/vlad/data"

for bam in $DATA_DIR/alzheimer/bam/*.bam \
           $DATA_DIR/alzheimer2/bam/*.bam \
           $DATA_DIR/healthy/bam/*.bam \
           $DATA_DIR/healthy2/bam/*.bam; do
  samtools index $bam &
done
wait
echo "Indexing complete"
