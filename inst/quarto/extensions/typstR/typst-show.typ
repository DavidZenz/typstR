#import "typst-template.typ": working-paper

#show: working-paper.with(
  $if(title)$
  title: "$title$",
  $endif$
  $if(author)$
  authors: (
    $for(author)$
    (name: "$it.name.literal$"),
    $endfor$
  ),
  $endif$
  $if(abstract)$
  abstract: [$abstract$],
  $endif$
)
