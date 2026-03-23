// Phase 1: monolithic template -- refactored to modular in Phase 3
// Compatible with Typst version bundled in Quarto >= 1.4.11

#let working-paper(
  title: none,
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
      #authors.map(a => {
        let parts = (a.name,)
        if a.at("email", default: none) != none {
          parts.push(" <" + a.at("email") + ">")
        }
        if a.at("corresponding", default: false) == true {
          parts.push("*")
        }
        parts.join("")
      }).join(", ")
    ]

    // Show affiliations if present
    if affiliations.len() > 0 {
      v(0.3em)
      align(center)[
        #affiliations.map(af => {
          let parts = (af.name,)
          if af.at("department", default: none) != none {
            parts = (af.at("department") + ", " + af.name,)
          }
          parts.join("")
        }).join(" | ")
      ]
    }

    v(1em)
  }

  // Report number
  if report-number != none {
    align(center)[
      #text(size: 10pt, style: "italic")[#report-number]
    ]
    v(0.5em)
  }

  // Abstract
  if abstract != none {
    pad(x: 1.5cm)[
      *Abstract.* #abstract
    ]
    v(0.5em)
  }

  // Keywords
  if keywords.len() > 0 {
    pad(x: 1.5cm)[
      *Keywords:* #keywords.join(", ")
    ]
    v(0.3em)
  }

  // JEL Classification
  if jel.len() > 0 {
    pad(x: 1.5cm)[
      *JEL Classification:* #jel.join(", ")
    ]
    v(0.3em)
  }

  v(1em)

  // Body
  body

  // Post-body sections
  if acknowledgements != none {
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
}
