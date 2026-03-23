// base.typ — Page setup, typography defaults, heading numbering
// Compatible with Typst version bundled in Quarto >= 1.4.11
// No @preview imports allowed

#let apply-base-styles(
  primary-font: "Linux Libertine",
  title-font: none,
  margins: (x: 1in, y: 1in),
  accent-color: none,
  footer-content: none,
  body,
) = {
  set page(
    paper: "us-letter",
    margin: margins,
    numbering: "1",
    footer: footer-content,
  )

  set text(font: primary-font, size: 11pt)
  set par(justify: true, leading: 0.65em)
  set heading(numbering: "1.1")

  if accent-color != none {
    show heading: set text(fill: accent-color)
  }

  // TMPL-08: Consistent caption sizing for figures and tables
  show figure.caption: it => {
    set text(size: 9.5pt)
    it
  }

  body
}
