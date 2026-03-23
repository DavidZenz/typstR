// disclaimer.typ — Disclaimer page rendering
// Compatible with Typst version bundled in Quarto >= 1.4.11
// No @preview imports allowed

// Default disclaimer text — used when caller passes none for text.
#let default-disclaimer-text = "The views expressed in this paper are those of the authors and do not necessarily reflect those of their affiliated institutions."

// render-disclaimer(text, position, enabled)
//
// Renders a standalone disclaimer page (preceded by a page break).
// The caller is responsible for calling this function at the correct position
// in the document (before the body for position == "first", after for "last").
//
// Parameters:
//   text     — disclaimer text content; if none, uses default: value above
//   position — "first" or "last" (informational only; not used here — caller branches)
//   enabled  — boolean; if false returns immediately without rendering anything
#let render-disclaimer(
  text: none,
  position: "last",
  enabled: false,
) = {
  if not enabled { return }

  let disclaimer-content = if text != none { text } else { default-disclaimer-text }

  pagebreak()
  {
    set page(numbering: none)
    align(center + horizon)[
      #block(width: 80%)[
        #set text(size: 10pt, style: "italic")
        #disclaimer-content
      ]
    ]
  }
}
