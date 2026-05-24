#!/bin/bash
set -e
DATA_DIR="/home/vlad/data"
BUCKET="gs://alzheimer-lrseq"

# SQANTI results
gsutil -m cp -r $DATA_DIR/sqanti/ $BUCKET/sqanti/

# RNA modifications
for sample in alzheimer alzheimer2 healthy healthy2; do
  gsutil -m cp -r $DATA_DIR/${sample}/bed/ $BUCKET/modifications/${sample}/
done

echo "Upload complete"
