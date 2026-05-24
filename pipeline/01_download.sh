#!/bin/bash
set -e
HOME_DIR="/home/vlad"
DATA_DIR="$HOME_DIR/data"

mkdir -p $DATA_DIR/{alzheimer,alzheimer2,healthy,healthy2}/{bam,bed}
mkdir -p $DATA_DIR/reference

# BAM files
curl -o $DATA_DIR/alzheimer/bam/ENCFF318LAS.bam \
  -L https://www.encodeproject.org/files/ENCFF318LAS/@@download/ENCFF318LAS.bam

curl -o $DATA_DIR/alzheimer2/bam/ENCFF848JRR.bam \
  -L https://www.encodeproject.org/files/ENCFF848JRR/@@download/ENCFF848JRR.bam

curl -o $DATA_DIR/healthy/bam/ENCFF609UIN.bam \
  -L https://www.encodeproject.org/files/ENCFF609UIN/@@download/ENCFF609UIN.bam

curl -o $DATA_DIR/healthy2/bam/ENCFF222AEA.bam \
  -L https://www.encodeproject.org/files/ENCFF222AEA/@@download/ENCFF222AEA.bam

# Alzheimer bed files
for id in ENCFF648EJN ENCFF271IEJ ENCFF618GCJ ENCFF967FYK ENCFF151RGT \
          ENCFF676FXA ENCFF560YMC ENCFF261JSC ENCFF625SGQ ENCFF399PRQ; do
  curl -o $DATA_DIR/alzheimer/bed/${id}.bed.gz \
    -L https://www.encodeproject.org/files/${id}/@@download/${id}.bed.gz
done

# Alzheimer2 bed files
for id in ENCFF770NES ENCFF317NKY ENCFF685WDQ ENCFF650ZST ENCFF582HOV \
          ENCFF037VCI ENCFF593NRV ENCFF424TSR ENCFF738FGG ENCFF673LOU; do
  curl -o $DATA_DIR/alzheimer2/bed/${id}.bed.gz \
    -L https://www.encodeproject.org/files/${id}/@@download/${id}.bed.gz
done

# Healthy bed files
for id in ENCFF021KEM ENCFF189ISL ENCFF748LCT ENCFF599CVZ ENCFF424BNS \
          ENCFF896MCF ENCFF302AZY ENCFF562OIB ENCFF568NOR ENCFF819BCT; do
  curl -o $DATA_DIR/healthy/bed/${id}.bed.gz \
    -L https://www.encodeproject.org/files/${id}/@@download/${id}.bed.gz
done

# Healthy2 bed files
for id in ENCFF375SLZ ENCFF906NNT ENCFF262WOH ENCFF945TFF ENCFF407HCD \
          ENCFF949LVE ENCFF695BNP ENCFF200IWT ENCFF653XTI ENCFF769OLC; do
  curl -o $DATA_DIR/healthy2/bed/${id}.bed.gz \
    -L https://www.encodeproject.org/files/${id}/@@download/${id}.bed.gz
done

# Reference genome and annotation
wget -P $DATA_DIR/reference/ \
  https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_44/GRCh38.primary_assembly.genome.fa.gz
wget -P $DATA_DIR/reference/ \
  https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_44/gencode.v44.annotation.gtf.gz

gunzip $DATA_DIR/reference/gencode.v44.annotation.gtf.gz
gunzip $DATA_DIR/reference/GRCh38.primary_assembly.genome.fa.gz

echo "Download complete"
