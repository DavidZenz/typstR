// Phase 1: monolithic template -- refactored to modular in Phase 3
// Compatible with Typst version bundled in Quarto >= 1.4.11

#let working-paper(
  title: none,
  authors: (),
  abstract: none,
  body,
) = {
  // Page setup
  set page(
    paper: "us-letter",
    margin: (x: 1in, y: 1in),
    numbering: "1",
  )

  // Typography
  set text(font: "Linux Libertine", size: 11pt)
  set par(justify: true, leading: 0.65em)
  set heading(numbering: "1.1")

  // Title block
  if title != none {
    align(center)[
      #text(size: 16pt, weight: "bold")[#title]
    ]
    v(0.5em)
  }

  // Authors
  if authors.len() > 0 {
    align(center)[
      #authors.map(a => a.name).join(", ")
    ]
    v(1em)
  }

  // Abstract
  if abstract != none {
    pad(x: 1.5cm)[
      *Abstract.* #abstract
    ]
    v(1em)
  }

  // Body
  body
}
