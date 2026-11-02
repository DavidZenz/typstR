// workingpaper.typ — Working paper format overlay composing all shared modules
// Compatible with Typst version bundled in Quarto >= 1.4.11
// No @preview imports allowed

#import "base.typ": apply-base-styles
#import "titleblock.typ": render-title-block
#import "authors.typ": render-author-block
#import "abstract.typ": render-abstract
#import "branding.typ": render-logo, render-footer
#import "disclaimer.typ": render-disclaimer

#let publication(
  // Core content fields
  title: none,
  subtitle: none,
  date: none,
  authors: (),
  affiliations: (),
  abstract: none,
  keywords: (),
  jel: (),
  acknowledgements: none,
  report-number: none,
  funding: none,
  data-availability: none,
  code-availability: none,
  // Branding hooks
  primary-font: "Libertinus Serif",
  title-font: none,
  margins: (x: 1in, y: 1in),
  accent-color: none,
  logo: none,
  footer: none,
  paper: "us-letter",
  font-size: 11pt,
  section-numbering: "1.1",
  page-numbering: "1",
  toc: false,
  toc-title: auto,
  toc-depth: 3,
  toc-indent: 1.5em,
  // Disclaimer page
  disclaimer-page: false,
  disclaimer-position: "last",
  disclaimer-text: none,
  // Format control
  anonymized: false,
  format-variant: "workingpaper",
  abstract-label: none,
  show-jel: true,
  show-orcid: true,
  show-report-number: true,
  body,
) = {
  let variants = (
    workingpaper: (abstract-label: "Abstract", show-jel: true, show-orcid: true, show-report-number: true),
    article: (abstract-label: "Abstract", show-jel: true, show-orcid: true, show-report-number: false),
    brief: (abstract-label: "Summary", show-jel: false, show-orcid: false, show-report-number: true),
  )
  let defaults = variants.at(format-variant)
  let abstract-label = if abstract-label == none { defaults.abstract-label } else { abstract-label }
  let show-jel = defaults.show-jel and show-jel
  let show-orcid = defaults.show-orcid and show-orcid
  let show-report-number = defaults.show-report-number and show-report-number

  show: apply-base-styles.with(
    primary-font: primary-font,
    title-font: title-font,
    margins: margins,
    accent-color: accent-color,
    footer-content: render-footer(footer),
    paper: paper,
    font-size: font-size,
    section-numbering: section-numbering,
    page-numbering: page-numbering,
  )

  // Disclaimer at top (position == "first")
  render-disclaimer(
    disclaimer-text: disclaimer-text,
    position: disclaimer-position,
    enabled: disclaimer-page and disclaimer-position == "first",
  )

  // Logo appears above title block
  render-logo(logo)

  render-title-block(
    title: title,
    subtitle: subtitle,
    date: date,
    report-number: if show-report-number { report-number } else { none },
    title-font: if title-font == none { primary-font } else { title-font },
  )

  render-author-block(
    authors: authors,
    affiliations: affiliations,
    anonymized: anonymized,
    show-orcid: show-orcid,
  )

  render-abstract(
    abstract: abstract,
    keywords: keywords,
    jel: if show-jel { jel } else { () },
    abstract-label: abstract-label,
  )

  if toc {
    block(above: 1em, below: 2em)[
      #outline(title: toc-title, depth: toc-depth, indent: toc-indent)
    ]
  }

  // Body
  body

  // Post-body sections
  if acknowledgements != none and not anonymized {
    v(1em)
    [*Acknowledgements*

    #acknowledgements]
  }

  if funding != none {
    v(1em)
    [*Funding*

    #funding]
  }

  if data-availability != none {
    v(1em)
    [*Data Availability*

    #data-availability]
  }

  if code-availability != none {
    v(1em)
    [*Code Availability*

    #code-availability]
  }

  // Disclaimer at end (position == "last", the default)
  render-disclaimer(
    disclaimer-text: disclaimer-text,
    position: disclaimer-position,
    enabled: disclaimer-page and disclaimer-position == "last",
  )
}
