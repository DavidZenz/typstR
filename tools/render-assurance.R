# Run against an installed package in a clean R session; never skips.
args <- commandArgs(trailingOnly = TRUE)
out <- if (length(args)) args[[1]] else "artifacts/render"
dir.create(out, recursive = TRUE, showWarnings = FALSE)
out <- normalizePath(out, winslash = "/", mustWork = TRUE)
stopifnot(requireNamespace("typstR", quietly = TRUE), requireNamespace("quarto", quietly = TRUE))
library(typstR)
if (!quarto::quarto_available()) stop("Required Quarto CLI is unavailable")
quarto_version <- as.character(quarto::quarto_version())
typst_probe <- typstR:::probe_typst(typstR:::probe_quarto())
if (!isTRUE(typst_probe$ok)) stop("Required Typst compiler is unavailable")
typst_version <- typst_probe$raw
expected_quarto <- Sys.getenv("TYPSTR_EXPECT_QUARTO")
expected_typst <- Sys.getenv("TYPSTR_EXPECT_TYPST")
if (nzchar(expected_quarto) && quarto_version != expected_quarto) stop("Unexpected Quarto version")
if (nzchar(expected_typst) && !any(grepl(paste0("typst ", expected_typst, " "), typst_version, fixed = TRUE))) stop("Unexpected Typst version")
for (tool in c("pdftotext", "pdfinfo", "pdftoppm", "pdffonts")) {
  if (!nzchar(Sys.which(tool))) stop("Required PDF tool is unavailable: ", tool)
}
toolchain <- c(capture.output(sessionInfo()),
               paste("Package:", packageVersion("typstR")),
               paste("Quarto:", quarto::quarto_version()),
               typst_version, paste("Typst provider:", typst_probe$provider),
               paste("Commit:", system2("git", c("rev-parse", "HEAD"), stdout = TRUE)))
writeLines(toolchain, file.path(out, "toolchain.txt"))
cat(paste(toolchain, collapse = "\n"), "\n")

source("tools/render/cases.R", encoding = "UTF-8")

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
# Nine named scenarios: three unchanged scaffolds, three enriched numbered
# documents, and three anonymous unnumbered documents.
scenarios <- expand.grid(variant = names(specs),
                         family = c("default", "identified", "anonymous-unnumbered"),
                         stringsAsFactors = FALSE)
completed <- character()
for (row in seq_len(nrow(scenarios))) {
  kind <- scenarios$variant[[row]]
  family <- scenarios$family[[row]]
  if (family != "default") {
    run_pdf_audit_case(out, kind, family, rasterize = TRUE)
    completed <- c(completed, paste("audit", kind, family, sep = "-"))
    next
  }
  spec <- specs[[kind]]
  id <- paste(kind, "default", sep = "-")
  project <- file.path(out, paste(id, "project with spaces"))
  if (dir.exists(project)) stop("Refusing to reuse a scaffold: ", project)
  spec$create(project, open = FALSE)
  manuscript <- file.path(project, "template.qmd")
  # Keep the manuscript and publication defaults unchanged; retain only the
  # intermediate source as evidence via the project's keep-typ option.
  config_path <- file.path(project, "_quarto.yml")
  config <- yaml::read_yaml(config_path)
  config$format <- list(`typstR-typst` = list(`keep-typ` = TRUE))
  writeLines(audit_yaml(config), config_path, useBytes = TRUE)
  if (kind == "brief") {
    previous <- setwd(project)
    result <- tryCatch(withVisible(spec$render(NULL, quiet = FALSE, open = FALSE)),
                       finally = setwd(previous))
  } else {
    input <- if (kind == "article") project else manuscript
    result <- withVisible(spec$render(input, quiet = FALSE, open = FALSE))
  }
  if (result$visible || !is.null(result$value)) stop("Render return contract changed: ", id)
  pdf <- file.path(project, "template.pdf")
  if (!file.exists(pdf) || file.info(pdf)$size < 1000) stop("Missing/empty PDF: ", id)
  textfile <- file.path(out, paste0(id, ".txt"))
  if (system2("pdftotext", c("-layout", shQuote(pdf), shQuote(textfile)))) stop("PDF extraction failed")
  text <- gsub("[[:space:]]+", " ", paste(readLines(textfile, warn = FALSE, encoding = "UTF-8"), collapse = " "))
  first_heading <- if (kind == "brief") "Key Findings" else "Introduction"
  expected <- c(spec$title, spec$lead, first_heading)
  meta <- validate_manuscript(manuscript)$metadata
  expected <- c(expected, unlist(meta$typstR$keywords),
                if (kind != "brief") unlist(meta$typstR$jel))
  for (token in expected) if (!grepl(token, text, fixed = TRUE)) stop(id, " missing content: ", token)
  if (!grepl(paste("1", first_heading), text, fixed = TRUE)) stop("Default numbering missing: ", id)
  if (grepl("@smith2020|\\?\\?", text)) stop("Unresolved reference: ", id)
  info <- system2("pdfinfo", shQuote(pdf), stdout = TRUE)
  fonts <- system2("pdffonts", shQuote(pdf), stdout = TRUE)
  if (!is.null(attr(info, "status")) || !is.null(attr(fonts, "status"))) stop("PDF inspection failed")
  if (!any(grepl("612 x 792", info, fixed = TRUE))) stop("Default paper is not Letter: ", id)
  if (!any(grepl("LibertinusSerif", fonts, fixed = TRUE))) stop("Default font missing: ", id)
  writeLines(info, file.path(out, paste0(id, "-pdfinfo.txt")))
  writeLines(fonts, file.path(out, paste0(id, "-fonts.txt")))
  file.copy(pdf, file.path(out, paste0(id, ".pdf")), overwrite = TRUE)
  if (system2("pdftoppm", c("-scale-to", "1200", "-png", shQuote(pdf), shQuote(file.path(out, id))))) stop("Page rasterization failed")
  completed <- c(completed, id)
}
stopifnot(length(completed) == 9L, !anyDuplicated(completed))
writeLines(c("PASS: nine required renders; zero skipped", completed), file.path(out, "RESULTS.txt"))
cat("PASS: nine required renders; zero skipped\n")
