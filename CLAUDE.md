# Alzheimer Epitranscriptomics — Project Context

NO COMMENTS IN CODE OR SCRIPTS

## What this project is
Comparative analysis of long-read RNA-seq (Nanopore Direct RNA) from human dorsolateral prefrontal cortex. Goal: find isoform-level and RNA modification differences between Alzheimer's disease and healthy aging brain.

## Samples
| sample_id | condition | age | sex | ENCODE experiment | BAM file |
|-----------|-----------|-----|-----|-------------------|----------|
| alzheimer_90 | alzheimer | 90 | female | ENCSR872GND | ENCFF318LAS.bam |
| alzheimer_86 | alzheimer | 86 | female | ENCSR543NWW | ENCFF848JRR.bam |
| healthy_90 | healthy | 90 | female | ENCSR111GJE | ENCFF609UIN.bam |
| healthy_85 | healthy | 85 | female | ENCSR697CSS | ENCFF222AEA.bam |

## GCP Infrastructure
- VM: `instance-20260524-113650`, zone `us-central1-a`, e2-standard-8, 200GB disk
- SSH: `gcloud compute ssh instance-20260524-113650 --zone=us-central1-a` (logs in as `vlad`)
- Stop VM: `gcloud compute instances stop instance-20260524-113650 --zone=us-central1-a`
- Start VM: `gcloud compute instances start instance-20260524-113650 --zone=us-central1-a`
- GCS bucket: `gs://alzheimer-lrseq`
- Repo cloned on VM at: `/home/vlad/alzheimer-epitranscriptomics/`

## Data on VM (/home/g663vova/data/)
Note: pipeline scripts run as user `vlad` but data lives in `/home/g663vova/data/`.
```
data/
  alzheimer/bam/ENCFF318LAS.bam        # annotated BAM, GRCh38
  alzheimer/bed/                        # RNA modifications (m6A, m5C, pseudouridine, inosine, Nm)
  alzheimer2/bam/ENCFF848JRR.bam
  alzheimer2/bed/
  healthy/bam/ENCFF609UIN.bam
  healthy/bed/
  healthy2/bam/ENCFF222AEA.bam
  healthy2/bed/
  reference/
    GRCh38.primary_assembly.genome.fa
    gencode.v44.annotation.gtf
  stringtie/
    alzheimer/transcripts_filtered.gtf
    alzheimer2/transcripts_filtered.gtf
    healthy/transcripts_filtered.gtf
    healthy2/transcripts_filtered.gtf
    merged.gtf                           # merged transcriptome (all 4 samples)
  sqanti/
    alzheimer/alzheimer_classification.txt   # MAIN FILE FOR ML
    alzheimer2/alzheimer2_classification.txt
    healthy/healthy_classification.txt
    healthy2/healthy2_classification.txt
  bambu_results/                         # output from Bambu (alternative quantification)
```

## Pipeline (conda envs)
- StringTie2: `conda activate stringtie`
- SQANTI3: `conda activate sqanti3`

Key commands:
```bash
# StringTie2
stringtie data/${sample}/bam/*.bam \
  -L -G data/reference/gencode.v44.annotation.gtf \
  -o data/stringtie/${sample}/transcripts.gtf -p 8

# Filter non-standard chromosomes
grep -v "_random\|_alt\|_fix\|chrUn" transcripts.gtf > transcripts_filtered.gtf

# SQANTI3
sqanti3_qc.py \
  --isoforms data/stringtie/${sample}/transcripts_filtered.gtf \
  --refGTF data/reference/gencode.v44.annotation.gtf \
  --refFasta data/reference/GRCh38.primary_assembly.genome.fa \
  --dir data/sqanti/${sample} --output ${sample} -t 8
```

## SQANTI3 Results Summary
| sample | isoforms | FSM | NIC | NNC |
|--------|----------|-----|-----|-----|
| alzheimer_90 | 39,912 | 20,269 | 6,227 | 1,102 |
| alzheimer_86 | 49,664 | 27,668 | 10,615 | 2,753 |
| healthy_90 | 57,316 | 29,332 | 13,377 | 3,729 |
| healthy_85 | 41,072 | 23,858 | 8,776 | 1,579 |

FSM = Full Splice Match (known isoform)
NIC = Novel In Catalog (new combo of known splice sites)
NNC = Novel Not in Catalog (completely new splice sites)

## RNA Modifications in bed files
Each sample has 10 bed files (plus/minus strand):
- m6A methylation (most important for Alzheimer's)
- m5C methylation
- pseudouridine
- inosine
- Nm methylation

## ML Plan
**Data:** SQANTI classification.txt (~50 features per isoform) + bed modification files

**Approach:**
1. PCA/batch effect check first — verify samples cluster by condition not by sequencing date
2. Residualizing age effect (85 vs 90) from all features before ML
3. Merge SQANTI features with RNA modification data per transcript
4. XGBoost + SHAP for feature importance
5. Bayesian logistic regression with biological priors (APOE, APP, MAPT, TREM2)

**Key consideration:** n=2 per group — focus on feature importance and biological interpretation, not accuracy metrics. Use SHAP for per-transcript explanation.

**Known Alzheimer's genes to use as priors:** APOE, APP, MAPT, TREM2, PSEN1, PSEN2, BIN1, CLU

## GitHub
Repo: `VladimirOpaits/alzheimer-epitranscriptomics`
- pipeline/ — shell scripts for full pipeline reproduction
- data/ — classification.txt, junctions.txt, bed files (TODO: push from VM)
- CLAUDE.md — this file

## TODO
- [ ] Start VM, download classification.txt and bed files locally, push to GitHub
- [ ] Add batch effect check (PCA on isoform TPM values)
- [ ] Build ML notebook: load all 4 classification.txt, merge with bed modifications
- [ ] Residualize age effect
- [ ] XGBoost + SHAP
- [ ] Bayesian model with Alzheimer's gene priors
- [ ] Consider rerunning SQANTI with --include_ORF and Illumina short reads for TSS
- [ ] Consider Nextflow pipeline when analysis is stable
- [ ] Fix rel_pos calculation in data_treatment.ipynb: currently divides genomic distance by transcript length — need to convert genomic coords to transcriptomic coords using exon structure from exons_by_sample GTF
