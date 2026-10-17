// Compatibility shim — real implementation in formats/workingpaper.typ
$if(typstR-extension-path)$
#import ("$typstR-extension-path$".replace("\\", "") + "/formats/workingpaper.typ"): working-paper
$else$
#import "_extensions/typstR/formats/workingpaper.typ": working-paper
$endif$
