library(shiny)
library(bslib)
library(tidyverse)
library(plotly)
library(DT)

# Load preprocessed data (run data_prep.R first)
sqanti     <- readRDS("data/sqanti_all.rds")
bed_summ   <- readRDS("data/bed_summary.rds")
bed_m6a    <- readRDS("data/bed_m6a.rds")

ad_genes <- c("APOE", "APP", "MAPT", "TREM2", "PSEN1", "PSEN2", "BIN1", "CLU")

# Colour palette: consistent condition colours across all plots
cond_pal <- c(Healthy = "#2196F3", Alzheimer = "#E53935")

sample_labels <- sqanti |>
  distinct(sample_id, condition, age) |>
  mutate(label = paste0(condition, " (", age, ")")) |>
  arrange(condition, age)

# ── UI ────────────────────────────────────────────────────────────────────────
ui <- page_navbar(
  title = "Alzheimer Epitranscriptomics",
  theme = bs_theme(bootswatch = "flatly", primary = "#2c3e50"),
  fillable = FALSE,

  # ── Tab 1: Overview ─────────────────────────────────────────────────────────
  nav_panel("Overview",
    layout_columns(
      col_widths = 12,
      card(
        card_header("Isoforms by structural category per sample"),
        plotlyOutput("cat_bar", height = "380px")
      )
    ),
    layout_columns(
      col_widths = c(6, 6),
      card(
        card_header("Transcript length distribution"),
        plotlyOutput("len_violin", height = "320px")
      ),
      card(
        card_header("Exon count distribution"),
        plotlyOutput("exon_bar", height = "320px")
      )
    ),
    layout_columns(
      col_widths = 12,
      card(
        card_header("Key metrics — summary table"),
        DTOutput("overview_table")
      )
    )
  ),

  # ── Tab 2: Alzheimer Genes ──────────────────────────────────────────────────
  nav_panel("Alzheimer Genes",
    layout_sidebar(
      sidebar = sidebar(
        width = 260,
        selectizeInput("gene_sel", "Gene",
          choices  = NULL,
          selected = "APOE",
          options  = list(placeholder = "Search gene / ENSEMBL ID…")
        ),
        hr(),
        checkboxGroupInput("cond_filter", "Show conditions",
          choices  = c("Alzheimer", "Healthy"),
          selected = c("Alzheimer", "Healthy")
        ),
        checkboxGroupInput("cat_filter", "Structural categories",
          choices  = c("full-splice_match", "incomplete-splice_match",
                       "novel_in_catalog", "novel_not_in_catalog", "other"),
          selected = c("full-splice_match", "incomplete-splice_match",
                       "novel_in_catalog", "novel_not_in_catalog", "other")
        )
      ),
      layout_columns(
        col_widths = c(5, 7),
        card(
          card_header("Isoform counts"),
          plotlyOutput("gene_bar", height = "320px")
        ),
        card(
          card_header("Expression (iso_exp TPM)"),
          plotlyOutput("gene_expr", height = "320px")
        )
      ),
      card(
        card_header("Isoform table"),
        DTOutput("gene_tbl")
      )
    )
  ),

  # ── Tab 3: RNA Modifications ────────────────────────────────────────────────
  nav_panel("RNA Modifications",
    layout_columns(
      col_widths = c(7, 5),
      card(
        card_header("Modification sites per sample"),
        plotlyOutput("mod_bar", height = "380px")
      ),
      card(
        card_header("Summary table"),
        DTOutput("mod_tbl")
      )
    ),
    layout_columns(
      col_widths = c(6, 6),
      card(
        card_header("m6A frequency distribution"),
        plotlyOutput("m6a_hist", height = "320px")
      ),
      card(
        card_header("Mean modification frequency by type"),
        plotlyOutput("mod_freq_bar", height = "320px")
      )
    )
  )
)

# ── Server ────────────────────────────────────────────────────────────────────
server <- function(input, output, session) {

  # Populate gene search with gene_name + ENSEMBL IDs
  all_gene_names <- sort(unique(sqanti$gene_name))
  updateSelectizeInput(session, "gene_sel",
    choices  = all_gene_names,
    selected = "APOE",
    server   = TRUE
  )

  # ── Overview ────────────────────────────────────────────────────────────────
  output$cat_bar <- renderPlotly({
    df <- sqanti |>
      mutate(cat_group = case_when(
        structural_category == "full-splice_match"       ~ "FSM",
        structural_category == "incomplete-splice_match" ~ "ISM",
        structural_category == "novel_in_catalog"        ~ "NIC",
        structural_category == "novel_not_in_catalog"    ~ "NNC",
        TRUE                                             ~ "Other"
      )) |>
      count(sample_id, condition, age, cat_group) |>
      mutate(label = paste0(condition, "\n(", age, ")"))

    plot_ly(df, x = ~label, y = ~n, color = ~cat_group,
            type = "bar",
            colors = c(FSM="#1a237e", ISM="#7986CB", NIC="#81C784",
                       NNC="#FFB74D", Other="#B0BEC5")) |>
      layout(barmode = "stack",
             xaxis = list(title = ""),
             yaxis = list(title = "# isoforms"),
             legend = list(title = list(text = "Category")))
  })

  output$len_violin <- renderPlotly({
    plot_ly(sqanti, x = ~condition, y = ~length,
            color = ~condition, colors = cond_pal,
            type = "violin",
            box = list(visible = TRUE),
            meanline = list(visible = TRUE)) |>
      layout(xaxis = list(title = ""),
             yaxis = list(title = "Transcript length (bp)", type = "log"),
             showlegend = FALSE)
  })

  output$exon_bar <- renderPlotly({
    df <- sqanti |>
      filter(exons <= 25) |>
      count(condition, exons)
    plot_ly(df, x = ~exons, y = ~n, color = ~condition, colors = cond_pal,
            type = "bar", alpha = 0.75) |>
      layout(barmode = "overlay",
             xaxis = list(title = "# exons"),
             yaxis = list(title = "# isoforms"),
             legend = list(title = list(text = "Condition")))
  })

  output$overview_table <- renderDT({
    sqanti |>
      group_by(sample_id, condition, age) |>
      summarise(
        total_isoforms = n(),
        FSM = sum(structural_category == "full-splice_match"),
        NIC = sum(structural_category == "novel_in_catalog"),
        NNC = sum(structural_category == "novel_not_in_catalog"),
        median_length = round(median(length, na.rm = TRUE)),
        median_exons  = round(median(exons,  na.rm = TRUE), 1),
        .groups = "drop"
      ) |>
      arrange(condition, age) |>
      datatable(rownames = FALSE, options = list(dom = "t", pageLength = 10))
  })

  # ── Alzheimer Genes ─────────────────────────────────────────────────────────
  gene_data <- reactive({
    req(input$gene_sel)
    sqanti |>
      filter(
        gene_name == input$gene_sel,
        condition %in% input$cond_filter
      ) |>
      mutate(cat_group = case_when(
        structural_category == "full-splice_match"       ~ "FSM",
        structural_category == "incomplete-splice_match" ~ "ISM",
        structural_category == "novel_in_catalog"        ~ "NIC",
        structural_category == "novel_not_in_catalog"    ~ "NNC",
        TRUE                                             ~ "Other"
      )) |>
      filter(
        structural_category %in% input$cat_filter |
        ("other" %in% input$cat_filter & cat_group == "Other")
      )
  })

  output$gene_bar <- renderPlotly({
    df <- gene_data() |>
      count(sample_id, condition, age, cat_group) |>
      mutate(label = paste0(condition, "\n(", age, ")"))

    plot_ly(df, x = ~label, y = ~n, color = ~cat_group,
            type = "bar",
            colors = c(FSM="#1a237e", ISM="#7986CB", NIC="#81C784",
                       NNC="#FFB74D", Other="#B0BEC5")) |>
      layout(barmode = "stack",
             title = input$gene_sel,
             xaxis = list(title = ""),
             yaxis = list(title = "# isoforms"))
  })

  output$gene_expr <- renderPlotly({
    df <- gene_data() |>
      filter(!is.na(iso_exp), iso_exp > 0) |>
      mutate(label = paste0(condition, " (", age, ")"))

    plot_ly(df, x = ~label, y = ~iso_exp, color = ~condition, colors = cond_pal,
            type = "box", boxpoints = "all", jitter = 0.3, pointpos = 0) |>
      layout(xaxis = list(title = ""),
             yaxis = list(title = "iso_exp (TPM)", type = "log"),
             showlegend = FALSE)
  })

  output$gene_tbl <- renderDT({
    gene_data() |>
      select(isoform, sample_id, condition, cat_group,
             associated_transcript, length, exons,
             iso_exp, gene_exp, diff_to_TSS, diff_to_TTS) |>
      arrange(condition, sample_id) |>
      datatable(
        rownames = FALSE,
        filter   = "top",
        options  = list(pageLength = 15, scrollX = TRUE)
      )
  })

  # ── RNA Modifications ────────────────────────────────────────────────────────
  output$mod_bar <- renderPlotly({
    df <- bed_summ |>
      mutate(label = paste0(condition, " (", age, ")"))

    plot_ly(df, x = ~label, y = ~n_sites, color = ~mod_type,
            type = "bar",
            colors = c(m6A="#E53935", m5C="#FB8C00", Pseudouridine="#8E24AA",
                       Inosine="#039BE5", Nm="#43A047")) |>
      layout(barmode = "group",
             xaxis = list(title = ""),
             yaxis = list(title = "# modification sites"),
             legend = list(title = list(text = "Type")))
  })

  output$mod_tbl <- renderDT({
    bed_summ |>
      mutate(
        mean_freq   = round(mean_freq,   2),
        median_freq = round(median_freq, 2)
      ) |>
      arrange(mod_type, condition) |>
      datatable(rownames = FALSE, options = list(dom = "t", pageLength = 20))
  })

  output$m6a_hist <- renderPlotly({
    plot_ly(bed_m6a, x = ~mod_freq, color = ~condition, colors = cond_pal,
            type = "histogram", nbinsx = 50, alpha = 0.7) |>
      layout(barmode  = "overlay",
             xaxis    = list(title = "m6A frequency (%)"),
             yaxis    = list(title = "# sites"),
             bargap   = 0.05)
  })

  output$mod_freq_bar <- renderPlotly({
    plot_ly(bed_summ, x = ~mod_type, y = ~mean_freq, color = ~condition,
            colors = cond_pal, type = "bar") |>
      layout(barmode = "group",
             xaxis   = list(title = ""),
             yaxis   = list(title = "Mean modification frequency (%)"))
  })
}

shinyApp(ui, server)
