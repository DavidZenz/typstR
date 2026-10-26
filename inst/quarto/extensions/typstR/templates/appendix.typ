// Scoped around all remaining document content by the appendix Lua filter.
#let start-appendix(enabled: true, body) = {
  if enabled {
    counter(heading).update(0)
    set heading(numbering: (..values) => {
      let numbers = values.pos()
      // A first appendix can be an H2/H3 after Quarto's heading shifts.
      // Discard unused ancestor counters so its first number is always A.
      while numbers.len() > 1 and numbers.first() == 0 { numbers.remove(0) }
      numbering("A.1", ..numbers)
    })
    body
  } else {
    body
  }
}
