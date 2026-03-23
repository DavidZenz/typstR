// branding.typ — Logo rendering and footer content helpers
// Compatible with Typst version bundled in Quarto >= 1.4.11
// No @preview imports allowed

// render-logo(logo-path) — Renders logo aligned right at the top of the page.
// If logo-path is none or empty, renders nothing.
// Pandoc escapes underscores in YAML metadata (my_logo.png -> my\_logo.png),
// so we strip backslashes before passing to image().
#let render-logo(logo-path) = {
  if logo-path == none { return }
  if logo-path == "" { return }
  let clean-path = logo-path.replace("\\", "")
  align(right)[#image(clean-path, width: 2.5cm)]
  v(0.5em)
}

// render-footer(footer-text) — Returns a Typst content value for use in
// set page(footer: ...).  Returns none if footer-text is none.
#let render-footer(footer-text) = {
  if footer-text == none { return none }
  align(center)[#text(size: 8pt)[#footer-text]]
}
