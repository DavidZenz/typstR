// workingpaper.typ — Working paper format overlay composing all shared modules
// Compatible with Typst version bundled in Quarto >= 1.4.11
// No @preview imports allowed

#import "../templates/base.typ": apply-base-styles
#import "../templates/titleblock.typ": render-title-block
#import "../templates/authors.typ": render-author-block
#import "../templates/abstract.typ": render-abstract

#let working-paper(
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
  primary-font: "Linux Libertine",
  title-font: none,
  margins: (x: 1in, y: 1in),
  accent-color: none,
  logo: none,
  footer: none,
  // Disclaimer page
  disclaimer-page: false,
  disclaimer-position: "last",
  disclaimer-text: none,
  // Format control
  anonymized: false,
  format-variant: "workingpaper",
  abstract-label: "Abstract",
  show-jel: true,
  show-orcid: true,
  show-report-number: true,
  body,
) = {
  show: apply-base-styles.with(
    primary-font: primary-font,
    title-font: title-font,
    margins: margins,
    accent-color: accent-color,
  )

  render-title-block(
    title: title,
    subtitle: subtitle,
    date: date,
    report-number: if show-report-number { report-number } else { none },
  )

  render-author-block(
    authors: authors,
    affiliations: affiliations,
    anonymized: anonymized,
  )

  render-abstract(
    abstract: abstract,
    keywords: keywords,
    jel: if show-jel { jel } else { () },
    abstract-label: abstract-label,
  )

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

  // Disclaimer page (appended at end when disclaimer-position is "last")
  if disclaimer-page and disclaimer-text != none and disclaimer-position == "last" {
    pagebreak()
    align(center + horizon)[
      #text(size: 10pt)[#disclaimer-text]
    ]
  }
}
