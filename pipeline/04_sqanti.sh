#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/00_config.sh"

for sample in "${SAMPLES[@]}"; do
  mkdir -p "$DATA_DIR/sqanti/${sample}"
done

for sample in "${SAMPLES[@]}"; do
  echo "SQANTI3: $sample..."

  SQANTI_ARGS=(
    --isoforms    "$DATA_DIR/stringtie/${sample}/transcripts_requantified.gtf"
    --refGTF      "$DATA_DIR/reference/gencode.v44.annotation.gtf"
    --refFasta    "$DATA_DIR/reference/GRCh38.primary_assembly.genome.fa"
    --dir         "$DATA_DIR/sqanti/${sample}"
    --output      "${sample}"
    --include_ORF
    -t            "$THREADS"
  )

  [[ -n "${CAGE_PEAK:-}"  ]] && SQANTI_ARGS+=(--CAGE_peak  "$CAGE_PEAK")
  [[ -n "${COVERAGE:-}"   ]] && SQANTI_ARGS+=(--coverage    "$COVERAGE")
  [[ -n "${POLYA_PEAK:-}" ]] && SQANTI_ARGS+=(--polyA_peak "$POLYA_PEAK")

  sqanti3_qc.py "${SQANTI_ARGS[@]}"

  echo "$sample done"
done

echo "SQANTI3 complete"
