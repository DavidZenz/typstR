#import "typst-template.typ": working-paper

#show: working-paper.with(
  $if(title)$
  title: "$title$",
  $endif$
  $if(author)$
  authors: (
    $for(author)$
    (
      $if(it.name.literal)$name: "$it.name.literal$",$else$$if(it.name)$name: "$it.name$",$endif$$endif$
      $if(it.email)$email: "$it.email$",$endif$
      $if(it.orcid)$orcid: "$it.orcid$",$endif$
      $if(it.corresponding)$corresponding: true,$endif$
    ),
    $endfor$
  ),
  $endif$
  $if(affiliations)$
  affiliations: (
    $for(affiliations)$
    (
      id: "$it.id$",
      name: "$it.name$",
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
  keywords: ($for(typstR.keywords)"$it$",$endfor$),
  $endif$
  $if(typstR.jel)$
  jel: ($for(typstR.jel)"$it$",$endfor$),
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
  $endif$
)
