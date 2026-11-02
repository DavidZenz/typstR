// Compatibility wrapper for direct Typst imports.
#import "../templates/publication.typ": publication
#let article(..args) = {
  let options = (format-variant: "article", primary-font: "Linux Libertine") + args.named()
  publication(..options, ..args.pos())
}
