// typst-show.typ: Pandoc template that maps Quarto/Pandoc metadata to the
// working-paper Typst function defined in formats/workingpaper.typ.
//
// Quarto 1.6+ normalises author metadata into a `by-author` variable (via its
// Lua filter).  The raw `author` variable is NOT used for author display; use
// `by-author` instead, where each item has:
//   - it.name.literal  : display name (string)
//   - it.email         : email address (may be absent)
//   - it.orcid         : ORCID (may be absent)
//   - it.attributes.corresponding : boolean (may be absent)
//   - it.affiliations  : list of {id, name} (may be empty)
//
// Top-level `affiliations` is the deduplicated list of affiliation objects.
// typstR: namespace fields come through as Pandoc metadata variables.

$if(typstR-extension-path)$
#import ($typstr-strings.typstR-extension-path$ + "/formats/workingpaper.typ"): working-paper, start-appendix
$else$
#import "_extensions/typstR/formats/workingpaper.typ": working-paper, start-appendix
$endif$

#let typstr-appendices-enabled = $if(typstr-numbered)$true$else$false$endif$ and $if(typstR.format-variant)$$typstr-strings.typstR.format-variant$$else$"workingpaper"$endif$ != "brief"

#show: working-paper.with(
  $if(papersize)$paper: $typstr-strings.papersize$,$endif$
  $if(typstR.primary-font)$primary-font: $typstr-strings.typstR.primary-font$,$elseif(mainfont)$primary-font: $typstr-strings.mainfont$,$endif$
  $if(fontsize)$font-size: $fontsize$,$endif$
  $if(typstR.margins)$
  margins: ($if(typstR.margins.x)$x: $typstR.margins.x$,$endif$$if(typstR.margins.y)$y: $typstR.margins.y$,$endif$),
  $elseif(margin)$margins: ($for(margin/pairs)$$margin.key$: $margin.value$,$endfor$),$endif$
  section-numbering: $if(typstr-numbered)$$typstr-strings.section-numbering$$else$none$endif$,
  page-numbering: $if(page-numbering)$$typstr-strings.page-numbering$$else$none$endif$,
  toc: $if(toc)$true$else$false$endif$,
  $if(toc-title)$toc-title: [$toc-title$],$endif$
  toc-depth: $typstr-toc-depth$,
  $if(toc-indent)$toc-indent: $toc-indent$,$endif$
  $if(title)$
  title: [$title$],
  $endif$
  $if(subtitle)$
  subtitle: [$subtitle$],
  $endif$
  $if(date)$
  date: [$date$],
  $endif$
  $if(by-author)$
  authors: (
    $for(by-author)$
    (
      $if(it.name.literal)$name: [$it.name.literal$],$endif$
      $if(it.email)$email: $it.typstr-email$,$endif$
      $if(it.orcid)$orcid: $it.typstr-orcid$,$endif$
      $if(it.attributes.corresponding)$corresponding: true,$endif$
      $if(it.affiliations)$
      affiliations: (
        $for(it.affiliations)$
        (ref: $if(it.ref)$$it.typstr-ref$$else$$it.typstr-id$$endif$),
        $endfor$
      ),
      $endif$
    ),
    $endfor$
  ),
  $endif$
  $if(affiliations)$
  affiliations: (
    $for(affiliations)$
    (
      $if(it.id)$id: $it.typstr-id$,$endif$
      $if(it.name)$name: $it.typstr-name$,$endif$
      $if(it.department)$department: $it.typstr-department$,$endif$
    ),
    $endfor$
  ),
  $endif$
  $if(abstract)$
  abstract: [$abstract$],
  $endif$
  $if(typstR)$
  $if(typstR.keywords)$
  keywords: ($for(typstr-strings.typstR.keywords)$
$it$, $endfor$),
  $endif$
  $if(typstR.jel)$
  jel: ($for(typstr-strings.typstR.jel)$
$it$, $endfor$),
  $endif$
  $if(typstR.acknowledgements)$
  acknowledgements: [$typstR.acknowledgements$],
  $endif$
  $if(typstR.report-number)$
  report-number: $typstr-strings.typstR.report-number$,
  $endif$
  $if(typstR.funding)$
  funding: [$typstR.funding$],
  $endif$
  $if(typstR.data-availability)$
  data-availability: [$typstR.data-availability$],
  $endif$
  $if(typstR.code-availability)$
  code-availability: [$typstR.code-availability$],
  $endif$
  $if(typstR.logo)$
  logo: image($typstr-strings.typstR.logo$, width: 2.5cm),
  $endif$
  $if(typstR.title-font)$
  title-font: $typstr-strings.typstR.title-font$,
  $endif$
  $if(typstR.accent-color)$
  accent-color: rgb($typstr-strings.typstR.accent-color$),
  $endif$
  $if(typstR.footer)$
  footer: $typstr-strings.typstR.footer$,
  $endif$
  $if(typstR.disclaimer-page)$
  disclaimer-page: true,
  $endif$
  $if(typstR.disclaimer-position)$
  disclaimer-position: $typstr-strings.typstR.disclaimer-position$,
  $endif$
  $if(typstR.disclaimer-text)$
  disclaimer-text: [$typstR.disclaimer-text$],
  $endif$
  $if(typstR.anonymized)$
  anonymized: true,
  $endif$
  $if(typstR.format-variant)$
  format-variant: $typstr-strings.typstR.format-variant$,
  $endif$
  $if(typstR.abstract-label)$
  abstract-label: $typstr-strings.typstR.abstract-label$,
  $endif$
  $endif$
)
