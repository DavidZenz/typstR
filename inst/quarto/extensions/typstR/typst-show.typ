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

#import "_extensions/typstR/formats/workingpaper.typ": working-paper

#show: working-paper.with(
  $if(title)$
  title: "$title$",
  $endif$
  $if(subtitle)$
  subtitle: "$subtitle$",
  $endif$
  $if(date)$
  date: "$date$",
  $endif$
  $if(by-author)$
  authors: (
    $for(by-author)$
    (
      $if(it.name.literal)$name: "$it.name.literal$",$endif$
      $if(it.email)$email: "$it.email$",$endif$
      $if(it.orcid)$orcid: "$it.orcid$",$endif$
      $if(it.attributes.corresponding)$corresponding: true,$endif$
      $if(it.affiliations)$
      affiliations: (
        $for(it.affiliations)$
        (ref: "$it.ref$"),
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
      $if(it.id)$id: "$it.id$",$endif$
      $if(it.name)$name: "$it.name$",$endif$
      $if(it.department)$department: "$it.department$",$endif$
    ),
    $endfor$
  ),
  $endif$
  $if(abstract)$
  abstract: [$abstract$],
  $endif$
  $if(typstR)$
  $if(typstR.keywords)$
  keywords: ($for(typstR.keywords)$
"$it$"$sep$, $endfor$),
  $endif$
  $if(typstR.jel)$
  jel: ($for(typstR.jel)$
"$it$"$sep$, $endfor$),
  $endif$
  $if(typstR.acknowledgements)$
  acknowledgements: [$typstR.acknowledgements$],
  $endif$
  $if(typstR.report-number)$
  report-number: "$typstR.report-number$",
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
  logo: "$typstR.logo$",
  $endif$
  $if(typstR.primary-font)$
  primary-font: "$typstR.primary-font$",
  $endif$
  $if(typstR.title-font)$
  title-font: "$typstR.title-font$",
  $endif$
  $if(typstR.accent-color)$
  accent-color: rgb("$typstR.accent-color$"),
  $endif$
  $if(typstR.footer)$
  footer: "$typstR.footer$",
  $endif$
  $if(typstR.disclaimer-page)$
  disclaimer-page: true,
  $endif$
  $if(typstR.disclaimer-position)$
  disclaimer-position: "$typstR.disclaimer-position$",
  $endif$
  $if(typstR.disclaimer-text)$
  disclaimer-text: [$typstR.disclaimer-text$],
  $endif$
  $if(typstR.anonymized)$
  anonymized: true,
  $endif$
  $if(typstR.format-variant)$
  format-variant: "$typstR.format-variant$",
  $endif$
  $if(typstR.abstract-label)$
  abstract-label: "$typstR.abstract-label$",
  $endif$
  $if(typstR.margins)$
  margins: (x: $typstR.margin-x$, y: $typstR.margin-y$),
  $endif$
  $endif$
)
