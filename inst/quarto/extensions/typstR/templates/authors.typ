// authors.typ — Author block with affiliation superscripts, email unescaping
// Compatible with Typst version bundled in Quarto >= 1.4.11
// No @preview imports allowed

#let render-author-block(
  authors: (),
  affiliations: (),
  anonymized: false,
  show-orcid: true,
) = {
  if anonymized {
    return
  }

  if authors.len() == 0 {
    return
  }

  // Build affiliation ID-to-index mapping (1-based)
  let aff-map = (:)
  for (i, aff) in affiliations.enumerate() {
    let aff-id = aff.at("id", default: str(i))
    aff-map.insert(aff-id, i + 1)
  }

  // Render authors centered with superscript affiliation numbers
  align(center)[
    #authors.map(author => {
      let name = author.at("name", default: "")
      let author-affs = author.at("affiliations", default: ())

      // Collect affiliation indices for this author
      let sups = author-affs.map(aff-ref => {
        let aff-id = if type(aff-ref) == "dictionary" {
          aff-ref.at("ref", default: aff-ref.at("id", default: ""))
        } else {
          str(aff-ref)
        }
        let idx = aff-map.at(aff-id, default: none)
        if idx != none { str(idx) } else { "" }
      }).filter(s => s != "")

      let is-corresponding = author.at("corresponding", default: false)

      if sups.len() > 0 {
        [#name#super(sups.join(","))#if is-corresponding [*]]
      } else {
        [#name#if is-corresponding [*]]
      }
    }).join([, ])
  ]

  // Render affiliation list below authors
  if affiliations.len() > 0 {
    v(0.3em)
    align(center)[
      #affiliations.enumerate().map(((i, aff)) => {
        let aff-name = aff.at("name", default: "")
        [#super(str(i + 1))#aff-name]
      }).join([; ])
    ]
  }

  // Render corresponding author email
  let corresponding-author = authors.find(a => a.at("corresponding", default: false) == true)
  if corresponding-author != none {
    let raw-email = corresponding-author.at("email", default: "")
    if raw-email != "" {
      let email-display = raw-email.replace("\\@", "@")
      v(0.3em)
      align(center)[
        #text(size: 9pt)[Corresponding author: #email-display]
      ]
    }
  }

  // ORCID display for authors who have it (suppressed when show-orcid is false)
  let orcid-authors = if show-orcid { authors.filter(a => a.at("orcid", default: none) != none) } else { () }
  if orcid-authors.len() > 0 {
    v(0.3em)
    align(center)[
      #text(size: 9pt)[
        #orcid-authors.map(a => {
          let name = a.at("name", default: "")
          let orcid = a.at("orcid", default: "")
          [#name: ORCID #orcid]
        }).join([; ])
      ]
    ]
  }

  v(1em)
}
