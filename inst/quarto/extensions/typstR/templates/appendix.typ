// appendix.typ — Lettered appendix numbering reset
// Compatible with Typst version bundled in Quarto >= 1.4.11
// No @preview imports allowed

#let start-appendix() = {
  set heading(numbering: "A.1", supplement: [Appendix])
  counter(heading).update(0)
}
