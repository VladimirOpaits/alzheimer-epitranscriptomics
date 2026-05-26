library(tidyverse)
library(data.table)

BASE <- "data/alzheimer-lrseq"
OUT  <- "shiny/data"

samples <- tribble(
  ~sample_id,   ~condition,   ~age,
  "alzheimer",  "Alzheimer",  90,
  "alzheimer2", "Alzheimer",  86,
  "healthy",    "Healthy",    90,
  "healthy2",   "Healthy",    85
)

ad_gene_map <- c(
  ENSG00000130203 = "APOE",
  ENSG00000142192 = "APP",
  ENSG00000186868 = "MAPT",
  ENSG00000095970 = "TREM2",
  ENSG00000080815 = "PSEN1",
  ENSG00000164690 = "PSEN2",
  ENSG00000136717 = "BIN1",
  ENSG00000120885 = "CLU"
)

mod_type_map <- c(
  "a"     = "m6A",
  "m"     = "m5C",
  "17802" = "Pseudouridine",
  "17596" = "Inosine",
  "19227" = "Nm",
  "19228" = "Nm",
  "19229" = "Nm",
  "69426" = "Nm"
)

message("Loading SQANTI files...")

sqanti_paths <- c(
  alzheimer  = file.path(BASE, "sqanti/sqanti/alzheimer/alzheimer_classification.txt"),
  alzheimer2 = file.path(BASE, "sqanti/sqanti/alzheimer2/alzheimer2_classification.txt"),
  healthy    = file.path(BASE, "sqanti/sqanti/healthy/healthy_classification.txt"),
  healthy2   = file.path(BASE, "sqanti/sqanti/healthy2/healthy2_classification.txt")
)

sqanti_all <- map_dfr(names(sqanti_paths), function(sid) {
  message("  ", sid)
  fread(sqanti_paths[sid], na.strings = c("NA", ".", "")) |>
    mutate(sample_id = sid)
}) |>
  left_join(samples, by = "sample_id") |>
  mutate(
    ensembl_base = str_remove(associated_gene, "\\.\\d+$"),
    gene_name = coalesce(ad_gene_map[ensembl_base], ensembl_base),
    condition = factor(condition, levels = c("Healthy", "Alzheimer"))
  )

saveRDS(sqanti_all, file.path(OUT, "sqanti_all.rds"))
message("Saved sqanti_all.rds — ", nrow(sqanti_all), " isoforms")

message("Loading BED files...")

bed_cols <- c("chrom","start","end","mod_code","score","strand",
              "thick_start","thick_end","color","coverage","mod_freq",
              "mod_count","unmod_count","v14","v15","v16","v17","v18")

bed_all <- map_dfr(samples$sample_id, function(sid) {
  dir <- file.path(BASE, "modifications", sid, "bed")
  files <- list.files(dir, pattern = "\\.bed\\.gz$", full.names = TRUE)
  message("  ", sid, ": ", length(files), " files")

  map_dfr(files, function(f) {
    dt <- fread(cmd = paste("zcat", shQuote(f)), header = FALSE, fill = TRUE)
    n  <- min(ncol(dt), length(bed_cols))
    setnames(dt, seq_len(n), bed_cols[seq_len(n)])
    dt |>
      select(chrom, start, end, mod_code, mod_freq, coverage, strand) |>
      mutate(
        sample_id = sid,
        mod_code  = as.character(mod_code),
        mod_type  = coalesce(mod_type_map[mod_code], mod_code)
      )
  })
}) |>
  left_join(samples, by = "sample_id") |>
  mutate(condition = factor(condition, levels = c("Healthy", "Alzheimer")))

bed_summary <- bed_all |>
  group_by(sample_id, condition, age, mod_type) |>
  summarise(
    n_sites     = n(),
    mean_freq   = mean(mod_freq, na.rm = TRUE),
    median_freq = median(mod_freq, na.rm = TRUE),
    .groups     = "drop"
  )

bed_m6a <- bed_all |> filter(mod_type == "m6A")

saveRDS(bed_summary, file.path(OUT, "bed_summary.rds"))
saveRDS(bed_m6a,     file.path(OUT, "bed_m6a.rds"))

message("Saved bed_summary.rds — ", nrow(bed_summary), " rows")
message("Saved bed_m6a.rds — ", nrow(bed_m6a), " sites")
message("Done.")
