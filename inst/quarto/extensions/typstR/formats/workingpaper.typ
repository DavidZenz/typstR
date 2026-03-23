// workingpaper.typ — Working paper format overlay composing all shared modules
// Compatible with Typst version bundled in Quarto >= 1.4.11
// No @preview imports allowed

#import "../templates/base.typ": apply-base-styles
#import "../templates/titleblock.typ": render-title-block
#import "../templates/authors.typ": render-author-block
#import "../templates/abstract.typ": render-abstract
#import "../templates/branding.typ": render-logo, render-footer
#import "../templates/disclaimer.typ": render-disclaimer

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
  // Apply format-variant defaults. User-supplied YAML values take precedence
  // because the parameter already carries the user's value at this point.
  // The logic only overrides when the value matches the function's own default,
  // ensuring an explicit YAML override is still respected.
  let abstract-label = if format-variant == "brief" and abstract-label == "Abstract" { "Summary" } else { abstract-label }
  let show-jel = if format-variant == "brief" { false } else { show-jel }
  let show-orcid = if format-variant == "brief" { false } else { show-orcid }
  let show-report-number = if format-variant == "article" { false } else { show-report-number }

  show: apply-base-styles.with(
    primary-font: primary-font,
    title-font: title-font,
    margins: margins,
    accent-color: accent-color,
    footer-content: render-footer(footer),
  )

  // Disclaimer at top (position == "first")
  render-disclaimer(
    text: disclaimer-text,
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

  // Disclaimer at end (position == "last", the default)
  render-disclaimer(
    text: disclaimer-text,
    position: disclaimer-position,
    enabled: disclaimer-page and disclaimer-position == "last",
  )
}
