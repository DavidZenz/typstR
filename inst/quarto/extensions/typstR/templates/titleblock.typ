// titleblock.typ — Title, subtitle, date, report-number rendering
// Compatible with Typst version bundled in Quarto >= 1.4.11
// No @preview imports allowed

#let render-title-block(
  title: none,
  subtitle: none,
  date: none,
  report-number: none,
) = {
  if title != none {
    align(center)[
      #text(size: 16pt, weight: "bold")[#title]
    ]
    v(0.5em)
  }

  if subtitle != none {
    align(center)[
      #text(size: 13pt)[#subtitle]
    ]
    v(0.3em)
  }

  if date != none {
    align(center)[
      #text(size: 10pt)[#date]
    ]
    v(0.3em)
  }

  if report-number != none {
    align(center)[
      #text(size: 10pt, style: "italic")[#report-number]
    ]
    v(0.5em)
  }
}
