// Compatibility wrapper for direct Typst imports.
#import "../templates/publication.typ": publication
#let policy-brief(..args) = {
  let options = (format-variant: "brief", primary-font: "Linux Libertine") + args.named()
  publication(..options, ..args.pos())
}
