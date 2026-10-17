# Phase 16 Context: Format Comparison and Milestone Audit

## Goal
Create a "Format Comparison" matrix to help users choose the right publication format and perform the final audit for Milestone v1.3.

## Requirements
- EXT-02: Users can consult a "Format Comparison" matrix that explicitly compares features (anonymization, report numbers, disclaimers) across the three supported publication types.

## Success Criteria
1. "Format Comparison" article exists at `vignettes/format-comparison.Rmd` (or similar).
2. The article is reachable via the pkgdown navbar under "Articles".
3. Matrix correctly compares all three formats:
    - Working Paper (`workingpaper`)
    - Article (`article`)
    - Policy Brief (`brief`)
4. Comparison dimensions include: Metadata support, Anonymization, Report numbers, Branding hooks, and typical use cases.
5. Milestone v1.3 audit passes with 100% requirement coverage.

## Constraints
- Keep the matrix clean and easy to read (standard Markdown table).
- Follow the established tone and backlinking patterns.
- Ensure `v1.3-MILESTONE-AUDIT.md` is complete.
