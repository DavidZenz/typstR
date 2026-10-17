# Run against an installed package in a clean R session; never skips.
args <- commandArgs(trailingOnly = TRUE)
out <- if (length(args)) args[[1]] else "artifacts/render"
dir.create(out, recursive = TRUE, showWarnings = FALSE)
out <- normalizePath(out, winslash = "/", mustWork = TRUE)
stopifnot(requireNamespace("typstR", quietly = TRUE), requireNamespace("quarto", quietly = TRUE))
library(typstR)
if (!quarto::quarto_available()) stop("Required Quarto CLI is unavailable")
quarto_version <- as.character(quarto::quarto_version())
typst_version <- system2(quarto::quarto_path(), c("typst", "--version"), stdout = TRUE, stderr = TRUE)
if (!is.null(attr(typst_version, "status"))) stop("Required bundled Typst is unavailable")
expected_quarto <- Sys.getenv("TYPSTR_EXPECT_QUARTO")
expected_typst <- Sys.getenv("TYPSTR_EXPECT_TYPST")
if (nzchar(expected_quarto) && quarto_version != expected_quarto) stop("Unexpected Quarto version")
if (nzchar(expected_typst) && !any(grepl(paste0("typst ", expected_typst, " "), typst_version, fixed = TRUE))) stop("Unexpected Typst version")
for (tool in c("pdftotext", "pdfinfo", "pdftoppm")) {
  if (!nzchar(Sys.which(tool))) stop("Required PDF tool is unavailable: ", tool)
}
toolchain <- c(capture.output(sessionInfo()),
               paste("Package:", packageVersion("typstR")),
               paste("Quarto:", quarto::quarto_version()),
               typst_version,
               paste("Commit:", system2("git", c("rev-parse", "HEAD"), stdout = TRUE)))
writeLines(toolchain, file.path(out, "toolchain.txt"))
cat(paste(toolchain, collapse = "\n"), "\n")

specs <- list(
  workingpaper = list(create = create_working_paper, render = render_working_paper,
                     lead = "Elena Fischer1",
                     title = "Trade Fragmentation and Supplier Adjustment"),
  article = list(create = create_article, render = render_pub,
                 lead = "Ana Ribeiro1",
                 title = "Market Concentration and Export Resilience"),
  brief = list(create = create_policy_brief, render = render_pub,
               lead = "Sofia Novak1",
               title = "How Energy Price Shocks Reach Small Manufacturers")
)
completed <- character()
for (kind in names(specs)) {
  spec <- specs[[kind]]
  for (enriched in c(FALSE, TRUE)) {
    id <- paste(kind, if (enriched) "representative" else "default", sep = "-")
    project <- file.path(out, paste(id, "project with spaces"))
    if (dir.exists(project)) stop("Refusing to reuse a scaffold: ", project)
    spec$create(project, open = FALSE)
    manuscript <- file.path(project, "template.qmd")
    if (enriched) {
      lines <- readLines(manuscript)
      end <- which(lines == "---")[[2]]
      meta <- yaml::yaml.load(paste(lines[2:(end - 1)], collapse = "\n"))
      dir.create(file.path(project, "assets"))
      writeLines('<svg xmlns="http://www.w3.org/2000/svg" width="200" height="60"><rect width="200" height="60" fill="#002147"/><text x="10" y="40" font-size="30" fill="white">typstR</text></svg>', file.path(project, "assets", "logo_mark.svg"))
      meta$typstR$logo <- "assets/logo_mark.svg"
      meta$typstR$footer <- "Reliability footer"
      meta$typstR$`accent-color` <- "#002147"
      meta$typstR$`disclaimer-page` <- TRUE
      meta$typstR$`disclaimer-text` <- "Reliability disclaimer: illustrative research only."
      # Put branding/bibliography in project YAML to exercise inheritance.
      config <- list(project = list(type = "default"), bibliography = "references.bib",
                     typstR = meta$typstR)
      yaml::write_yaml(config, file.path(project, "_quarto.yml"))
      meta$typstR <- NULL
      meta$bibliography <- NULL
      body <- c(lines[(end + 1):length(lines)],
                "", "## Render assurance", "", "Citations resolve to @smith2020.", "",
                "| ReliabilityTable | Estimate |", "|:--|--:|", "| Treatment | 1.25 |", "",
                "### Equation assurance", "", "$$ y_i = \\alpha + \\beta x_i + \\epsilon_i $$", "")
      writeLines(c("---", yaml::as.yaml(meta), "---", body), manuscript)
      if (kind == "article") {
        dir.create(file.path(project, "nested chapter"))
        nested <- file.path(project, "nested chapter", "template.qmd")
        stopifnot(file.rename(manuscript, nested))
        manuscript <- nested
      }
    }
    cat("\nRendering", id, "via public R helper\n")
    # Use file, directory and NULL dispatch. Working paper is the README path
    # invoked from outside the project; article exercises directory input.
    if (kind == "brief" && !enriched) {
      previous <- setwd(project)
      tryCatch(spec$render(NULL, quiet = FALSE, open = FALSE), finally = setwd(previous))
    } else {
      input <- if (kind == "article" && !enriched) project else manuscript
      spec$render(input, quiet = FALSE, open = FALSE)
    }
    pdf <- file.path(dirname(manuscript), "template.pdf")
    if (!file.exists(pdf) || file.info(pdf)$size < 1000) stop("Missing/empty PDF: ", id)
    textfile <- file.path(out, paste0(id, ".txt"))
    if (system2("pdftotext", c("-layout", shQuote(pdf), shQuote(textfile))) != 0L) stop("PDF text extraction failed")
    text <- paste(readLines(textfile, warn = FALSE), collapse = " ")
    text <- gsub("[[:space:]]+", " ", text)
    expected <- c(spec$title, spec$lead, if (enriched) c("ReliabilityTable", "1.25", "Equation assurance", "Reliability footer", "Reliability disclaimer", "Smith"))
    for (token in expected) if (!grepl(token, text, fixed = TRUE)) stop(id, " missing PDF content: ", token)
    if (enriched && grepl("@smith2020|\\?\\?", text)) stop("Unresolved citation in ", id)
    file.copy(pdf, file.path(out, paste0(id, ".pdf")), overwrite = TRUE)
    if (system2("pdfinfo", shQuote(pdf), stdout = file.path(out, paste0(id, "-pdfinfo.txt")))) stop("Unreadable PDF")
    if (system2("pdftoppm", c("-scale-to", "1200", "-png", shQuote(pdf), shQuote(file.path(out, id))))) stop("Page rasterization failed")
    completed <- c(completed, id)
  }
}
stopifnot(length(completed) == 6L)
writeLines(c("PASS: six required renders; zero skipped", completed), file.path(out, "RESULTS.txt"))
cat("PASS: six required renders; zero skipped\n")
