// Compatibility shim — real implementation in formats/workingpaper.typ
$if(typstR-extension-path)$
#import ("$typstR-extension-path$".replace("\\", "") + "/formats/workingpaper.typ"): working-paper
$else$
#import "_extensions/typstR/formats/workingpaper.typ": working-paper
$endif$

// Pandoc bundled with early Quarto 1.4 emits string citation keys. Current
// Typst expects labels; keep the adapter valid for either writer generation.
#let typstr-cite = cite
#let cite(key, ..options) = typstr-cite(if type(key) == str { label(key) } else { key }, ..options)
