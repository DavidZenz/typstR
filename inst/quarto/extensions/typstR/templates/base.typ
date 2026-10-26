// base.typ — Page setup, typography defaults, heading numbering
// Compatible with Typst version bundled in Quarto >= 1.4.11
// No @preview imports allowed

#let apply-base-styles(
  primary-font: "Libertinus Serif",
  title-font: none,
  margins: (x: 1in, y: 1in),
  accent-color: none,
  footer-content: none,
  paper: "us-letter",
  font-size: 11pt,
  section-numbering: "1.1",
  page-numbering: "1",
  body,
) = {
  set page(
    paper: paper,
    margin: margins,
    numbering: page-numbering,
    footer: if footer-content == none { auto } else { context {
      footer-content
      if page.numbering != none {
        parbreak()
        align(center, counter(page).display(page.numbering))
      }
    } },
  )

  set text(font: primary-font, size: font-size)
  set par(justify: true, leading: 0.65em)
  set heading(numbering: section-numbering)

  show heading: it => {
    set text(fill: if accent-color == none { black } else { accent-color })
    it
  }

  // TMPL-08: Consistent caption sizing for figures and tables
  show figure.caption: it => {
    set text(size: 9.5pt)
    it
  }

  body
}
