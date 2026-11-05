# Required installed-package render scenarios; ordinary tests never source this file.
audit_yaml <- function(x) {
  yaml::as.yaml(x, handlers = list(logical = function(value) {
    structure(ifelse(value, "true", "false"), class = "verbatim")
  }))
}

run_pdf_audit_case <- function(out, variant, mode, rasterize = FALSE) {
  id <- paste("audit", variant, mode, sep = "-")
  project <- file.path(out, paste(id, "project with spaces"))
  create <- switch(variant, workingpaper = create_working_paper,
                   article = create_article, brief = create_policy_brief)
  create(project, open = FALSE)
  numbered <- mode == "identified"
  anonymous <- mode == "anonymous-unnumbered"
  config <- list(project = list(type = "default"))
  if (variant == "article") config$project$`output-dir` <- "results"
  dir <- project
  if (variant == "article") {
    dir <- file.path(project, "nested chapter")
    dir.create(dir)
    unlink(file.path(project, "template.qmd"))
  }
  input <- file.path(dir, "template.qmd")
  options <- list(`keep-typ` = TRUE, toc = numbered, `toc-title` = "AuditContents",
                  `toc-depth` = 1L, `number-sections` = numbered,
                  papersize = if (numbered) "a4" else "us-letter",
                  `page-numbering` = if (numbered) "i" else FALSE,
                  `section-numbering` = "1.1",
                  mainfont = "DejaVu Sans Mono", fontsize = "12pt",
                  margin = list(x = "2in", y = "2in"))
  typ <- list(`format-variant` = variant, anonymized = anonymous,
              `primary-font` = if (numbered) "Libertinus Serif" else "DejaVu Sans Mono",
              `title-font` = "DejaVu Sans Mono", margins = list(x = "1in", y = "1in"),
              acknowledgements = "SecretAcknowledgement", `report-number` = 'AuditReport "quoted"',
              funding = "AuditFunding", `data-availability` = "AuditDataStatement",
              `code-availability` = "AuditCodeStatement")
  if (numbered) {
    typ$keywords <- list('AuditKeyword trade "policy" C:\\data Identifier_one \u00dcber & 50%')
    typ$jel <- list("F10")
  } else {
    # Exercise standard font/margin fallback as well as typstR precedence above.
    typ$`primary-font` <- NULL
    typ$margins <- NULL
    options$margin <- list(x = "1in", y = "1in")
  }
  meta <- list(title = paste('AuditTitle "quoted": \u00dcber', variant, mode),
               author = list(list(name = "SecretAuthor", email = "secret@example.org",
                                  orcid = "0000-0001-2345-6789", corresponding = TRUE,
                                  affiliation = list("institute"))),
               affiliations = list(list(id = "institute", name = 'SecretInstitute "quoted" & Research', department = 'Department "one"')),
               subtitle = "*AuditSubtitle* **bold**", abstract = "*AuditAbstract*", format = list(`typstR-typst` = options), typstR = typ)
  if (numbered) {
    dir.create(file.path(project, "assets"))
    writeLines('<svg xmlns="http://www.w3.org/2000/svg" width="200" height="60"><rect width="200" height="60" fill="#002147"/><text x="10" y="40" font-size="30" fill="white">typstR</text></svg>',
               file.path(project, "assets", "logo_mark.svg"))
    typ$logo <- "assets/logo_mark.svg"
    typ$footer <- 'AuditFooter "quoted" C:\\archive\n\u00dcber & 50%'
    typ$`accent-color` <- "#002147"
    typ$`disclaimer-page` <- TRUE
    typ$`disclaimer-text` <- "AuditDisclaimer"
    if (variant != "article") config$bibliography <- "references.bib"
    if (variant == "workingpaper") typ$`disclaimer-position` <- "first"
  }
  if (variant == "workingpaper") {
    meta$`include-in-header` <- list(text = "#set page(header: [AuditHeader])")
  }
  if (variant == "workingpaper" && anonymous) {
    typ$`disclaimer-page` <- TRUE
    typ$`disclaimer-position` <- "first"
    typ$`disclaimer-text` <- "AuditFirstDisclaimer"
  }
  # Inherited project metadata must survive document-level format options.
  # Format-specific document values must win over inherited anonymization.
  typ$anonymized <- !anonymous
  meta$format$`typstR-typst`$typstR <- list(anonymized = anonymous)
  if (anonymous || variant == "article") {
    # Remove the document override so filename selection determines anonymity.
    meta$format$`typstR-typst`$typstR <- NULL
    directory_meta <- list(typstR = list(anonymized = anonymous))
    if (variant == "article") {
      writeLines(audit_yaml(list(typstR = list(anonymized = !anonymous))), file.path(project, "_metadata.yml"), useBytes = TRUE)
      directory_meta <- list(format = list(`typstR-typst` = directory_meta))
    }
    writeLines(audit_yaml(directory_meta), file.path(dir, "_metadata.yml"), useBytes = TRUE)
    writeLines(audit_yaml(list(typstR = list(anonymized = !anonymous))), file.path(dir, "_metadata.yaml"), useBytes = TRUE)
  }
  if (numbered && variant != "brief") {
    meta$references <- list(list(id = "doe2020", type = "article-journal",
                                title = "AuditInlineReference",
                                author = list(list(family = "InlineAuthor", given = "Jane")),
                                issued = list(`date-parts` = list(list(2020L)))))
    # Mixed working papers exercise automatic selection; articles opt in explicitly.
    if (variant == "article") meta$format$`typstR-typst`$citeproc <- TRUE
  }
  config$typstR <- typ
  meta$typstR <- NULL
  writeLines(audit_yaml(config), file.path(project, "_quarto.yml"), useBytes = TRUE)
  if (variant != "workingpaper") meta$`output-file` <- "review copy.pdf"
  # H2-only articles exercise Quarto's heading-level shift as well as H1 papers.
  level <- if (variant == "article") 2L else 1L
  heading <- function(text, n = level) paste0(strrep("#", n), " ", text)
  appendix <- function(title) sub("{.appendix}", "{#sec-audit-data .appendix}",
                                 capture.output(appendix_title(title, level)), fixed = TRUE)
  body <- c(heading("AuditMain"), "", "BodyMarker sees @eq-audit.", "",
            "$$ y = x $$ {#eq-audit}", "",
            appendix("AuditData"), "", "AppendixBody", "",
            heading("AuditDetail", level + 1L), "", "NestedBody", "",
            capture.output(appendix_title("AuditMethods", level)), "", "MethodsBody")
  citation <- if (variant == "article") "[@doe2020]" else if (variant == "workingpaper") "[@smith2020; @doe2020]" else "@smith2020"
  if (numbered) body <- c(body, "", paste("Citation resolves to", citation, ". Footnote marker.[^audit]"),
                          "", "[^audit]: AuditFootnote", "",
                          "| AuditTable | Estimate |", "|:--|--:|", "| Treatment | 1.25 |")
  if (numbered && variant == "workingpaper") body <- c(body, "", "CrossAndCite [@eq-audit; @doe2020].")
  writeLines(c("---", audit_yaml(meta), "---", "", body), input, useBytes = TRUE)
  if (variant == "article" && anonymous) {
    override <- file.path(project, "_quarto.yaml.local")
    writeLines("typstR: {anonymized: false}", override)
    blocked <- tryCatch(validate_manuscript(input), error = identity)
    if (!inherits(blocked, "typstR_diagnostics_error") ||
        !any(vapply(blocked$diagnostics, function(x) identical(x$location$file, override), logical(1)))) {
      stop("Local override did not fail closed: ", id)
    }
    writeLines("editor: source", override)
  }
  preflight <- validate_manuscript(input)
  if (!preflight$ok || !identical(preflight$metadata$typstR$anonymized, anonymous)) stop("Audit preflight failed: ", id)
  result <- withVisible(render_pub(input, quiet = FALSE, open = FALSE))
  if (result$visible || !is.null(result$value)) stop("Render return contract changed")
  pdf <- if (variant == "article") file.path(project, "results", "nested chapter", "review copy.pdf") else
    file.path(dir, if (variant == "workingpaper") "template.pdf" else "review copy.pdf")
  if (!file.exists(pdf)) stop("Missing resolved PDF: ", pdf)
  extract <- function(tool, args) {
    value <- system2(tool, args, stdout = TRUE, stderr = TRUE)
    if (!is.null(attr(value, "status"))) stop(tool, " failed: ", paste(value, collapse = "\n"))
    # Poppler emits UTF-8 even in containers whose native R locale is C.
    Encoding(value) <- "UTF-8"
    value
  }
  text <- extract("pdftotext", c("-layout", shQuote(pdf), "-"))
  info <- extract("pdfinfo", shQuote(pdf))
  fonts <- extract("pdffonts", shQuote(pdf))
  bbox <- extract("pdftotext", c("-bbox", shQuote(pdf), "-"))
  writeLines(text, file.path(out, paste0(id, ".txt")))
  writeLines(info, file.path(out, paste0(id, "-pdfinfo.txt")))
  writeLines(fonts, file.path(out, paste0(id, "-fonts.txt")))
  writeLines(bbox, file.path(out, paste0(id, "-bbox.html")))
  flat <- gsub("[[:space:]]+", " ", paste(text, collapse = " "))
  assert <- function(ok, message) if (!isTRUE(ok)) stop(id, ": ", message)
  assert(grepl("BodyMarker", flat, fixed = TRUE), "body is missing")
  title_text <- chartr("\u201c\u201d", '\"\"', flat)
  assert(grepl('AuditTitle "quoted": \u00dcber', title_text, fixed = TRUE), "literal title changed")
  assert(grepl("AuditSubtitle bold", flat, fixed = TRUE), "formatted subtitle missing")
  if (!anonymous) assert(grepl('SecretInstitute "quoted" & Research', title_text, fixed = TRUE), "literal affiliation changed")
  assert(grepl("BodyMarker sees Equation 1.", flat, fixed = TRUE), "cross-reference content was lost")
  assert(!grepl("@eq-audit|@doe2020|@smith2020|\\?\\?", flat), "unresolved cross-reference or citation")
  secret <- c("SecretAuthor", "SecretInstitute", "secret@example.org", "0000-0001-2345-6789", "SecretAcknowledgement")
  if (anonymous) {
    combined <- paste(flat, paste(info, collapse = " "))
    assert(!any(vapply(secret, grepl, logical(1), x = combined, fixed = TRUE)), "anonymous PDF exposes author metadata")
  } else {
    expected <- if (variant == "brief") secret[-4L] else secret
    assert(all(vapply(expected, grepl, logical(1), x = flat, fixed = TRUE)), "identified author fields are missing")
  }
  assert(grepl("DejaVuSansMono", paste(fonts, collapse = ""), fixed = TRUE), "title font is not embedded")
  assert(grepl(if (numbered) "LibertinusSerif" else "DejaVuSansMono", paste(fonts, collapse = ""), fixed = TRUE), "body font precedence failed")
  page <- info[grepl("Page size:", info, fixed = TRUE)]
  assert(grepl(if (numbered) "595" else "612 x 792", page, fixed = TRUE), "paper size was ignored")
  word <- bbox[grepl(">BodyMarker</word>", bbox, fixed = TRUE)]
  x <- as.numeric(sub('.*xMin="([^"]+)".*', "\\1", word))
  assert(length(x) == 1L && abs(x - 72) < 2, "margin precedence failed")
  typ_source <- paste(readLines(sub("\\.qmd$", ".typ", input), warn = FALSE), collapse = "\n")
  assert(grepl("font-size: 12pt", typ_source, fixed = TRUE), "font size was ignored")
  for (token in c("AuditFunding", "AuditDataStatement", "AuditCodeStatement")) {
    assert(grepl(token, flat, fixed = TRUE), paste("publication statement missing:", token))
  }
  if (numbered) {
    assert(grepl('AuditKeyword trade "policy" C:\\data Identifier_one \u00dcber & 50%', title_text, fixed = TRUE), "literal keyword changed")
    assert(grepl('AuditFooter "quoted" C:\\archive', title_text, fixed = TRUE), "literal footer changed")
    if (variant != "article") assert(grepl('AuditReport "quoted"', title_text, fixed = TRUE), "literal report number changed")
    assert(grepl("F10", flat, fixed = TRUE) == (variant != "brief"), "JEL variant behavior changed")
    assert(grepl("AuditReport", flat, fixed = TRUE) == (variant != "article"), "report-number variant behavior changed")
    assert(grepl("AuditContents", flat, fixed = TRUE), "TOC is missing")
    for (token in c("AuditFooter", "AuditDisclaimer", "AuditFootnote", "AuditTable", "1.25", if (variant != "article") "Smith")) {
      assert(grepl(token, flat, fixed = TRUE), paste("enriched content missing:", token))
    }
    if (variant != "brief") {
      assert(grepl("AuditInlineReference", flat, fixed = TRUE), "inline reference title missing")
      assert(lengths(regmatches(flat, gregexpr("AuditInlineReference", flat, fixed = TRUE))) == 1L,
             "inline bibliography entry was duplicated")
      assert(grepl("InlineAuthor", flat, fixed = TRUE), "inline citation author missing")
      if (variant == "workingpaper") {
        assert(grepl("CrossAndCite Equation 1; (InlineAuthor 2020).", flat, fixed = TRUE),
               "mixed cross-reference/citation group was lost")
      }
    } else {
      # Early Pandoc omits the author prefix for textual native Typst cites.
      assert(grepl("Citation resolves to (J[.] Smith )?\\[1\\]", flat),
             "native numeric bibliography style changed")
    }
    numeral <- if (variant == "workingpaper") ">ii</word>" else ">i</word>"
    assert(any(grepl(numeral, bbox, fixed = TRUE)), "page-numbering pattern was ignored")
    assert(regexpr("AuditAbstract", flat)[[1]] < regexpr("AuditContents", flat)[[1]], "TOC precedes abstract")
    outline <- strsplit(flat, "AuditContents", fixed = TRUE)[[1]][[2]]
    outline <- strsplit(outline, "BodyMarker", fixed = TRUE)[[1]][[1]]
    assert(!grepl("AuditDetail", outline, fixed = TRUE), "TOC depth was ignored")
    if (variant != "brief") {
      assert(grepl("A Appendix: AuditData", flat, fixed = TRUE), "first appendix is not A")
      assert(grepl("A.1 AuditDetail", flat, fixed = TRUE), "nested appendix is not A.1")
      assert(grepl("B Appendix: AuditMethods", flat, fixed = TRUE), "second appendix is not B")
    } else assert(!grepl("A Appendix:", flat, fixed = TRUE), "brief appendix switched to letters")
  } else {
    assert(!grepl("AuditKeyword|F10", flat), "omitted keyword/JEL metadata appears")
    assert(!grepl("AuditContents", flat, fixed = TRUE), "disabled TOC appears")
    assert(!grepl("[0-9A-Z] Appendix:|[0-9] AuditMain", flat), "disabled numbering appears")
    footer_words <- bbox[grepl(">[0-9ivx]+</word>", bbox)]
    footer_y <- as.numeric(sub('.*yMin="([^"]+)".*', "\\1", footer_words))
    assert(!any(footer_y > 720), "disabled page numbering appears")
  }
  # Inspect physical pages as well as the flattened text: blank first pages
  # and misplaced numbering are otherwise invisible to content assertions.
  page_count <- as.integer(sub("^Pages:[[:space:]]+", "", info[grepl("^Pages:", info)]))
  pages <- lapply(seq_len(page_count), function(n) extract("pdftotext", c("-f", n, "-l", n, "-layout", shQuote(pdf), "-")))
  page_flat <- vapply(pages, function(x) gsub("[[:space:]]+", " ", paste(x, collapse = " ")), character(1))
  writeLines(unlist(Map(function(n, x) c(paste("PAGE", n), x), seq_along(pages), pages)), file.path(out, paste0(id, "-pages.txt")))
  for (content in page_flat) {
    assert(grepl("AuditTitle|BodyMarker|AppendixBody|AuditTable|AuditDisclaimer|AuditFirstDisclaimer|Bibliography|References|AuditFunding|AuditDataStatement|AuditCodeStatement", content), "empty physical page")
  }
  first_disclaimer <- variant == "workingpaper"
  disclaimer <- if (anonymous) "AuditFirstDisclaimer" else "AuditDisclaimer"
  if (first_disclaimer) {
    assert(grepl(disclaimer, page_flat[[1]], fixed = TRUE), "first disclaimer is not on physical page 1")
    assert(!grepl("AuditTitle", page_flat[[1]], fixed = TRUE), "disclaimer shares the manuscript title page")
    assert(grepl("AuditTitle", page_flat[[2]], fixed = TRUE), "manuscript does not follow first disclaimer")
    assert(!any(grepl("^[ivxlcdm0-9]+$", trimws(pages[[1]]))), "first disclaimer has a page number")
    assert(all(vapply(page_flat[1:2], grepl, logical(1), pattern = "AuditHeader", fixed = TRUE)), "header was lost")
    if (anonymous) assert(page_count == 2L, "minimal first-disclaimer document is not exactly two pages")
    else {
      assert(all(vapply(page_flat[1:2], grepl, logical(1), pattern = "AuditFooter", fixed = TRUE)), "footer was lost")
      assert(any(trimws(pages[[2]]) == "ii"), "manuscript page counter was reset")
    }
  } else if (numbered) {
    assert(grepl(disclaimer, tail(page_flat, 1), fixed = TRUE), "last disclaimer moved")
    assert(!grepl("AuditTitle", tail(page_flat, 1), fixed = TRUE), "last disclaimer shares title page")
    assert(!any(grepl("^[ivxlcdm0-9]+$", trimws(tail(pages, 1)[[1]]))), "last disclaimer has a page number")
  } else assert(!grepl("Audit(First)?Disclaimer", flat), "disabled disclaimer appears")
  file.copy(pdf, file.path(out, paste0(id, ".pdf")), overwrite = TRUE)
  if (rasterize && system2("pdftoppm", c("-scale-to", "1200", "-png", shQuote(pdf), shQuote(file.path(out, id))))) stop("Rasterization failed")
  invisible(pdf)
}
