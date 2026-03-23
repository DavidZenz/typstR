// abstract.typ — Abstract, keywords, JEL rendering with configurable labels
// Compatible with Typst version bundled in Quarto >= 1.4.11
// No @preview imports allowed

#let render-abstract(
  abstract: none,
  keywords: (),
  jel: (),
  abstract-label: "Abstract",
) = {
  if abstract != none {
    pad(x: 1.5cm)[
      *#abstract-label.* #abstract
    ]
    v(0.5em)
  }

  if keywords.len() > 0 {
    pad(x: 1.5cm)[
      *Keywords:* #keywords.join(", ")
    ]
    v(0.3em)
  }

  if jel.len() > 0 {
    pad(x: 1.5cm)[
      *JEL Classification:* #jel.join(", ")
    ]
    v(0.3em)
  }

  v(1em)
}
