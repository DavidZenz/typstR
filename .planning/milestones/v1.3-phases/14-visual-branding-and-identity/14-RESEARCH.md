# Phase 14 Research: Visual Branding and Identity

## Overview
Phase 14 addresses the visual aesthetics of the `pkgdown` site. Research confirms that `pkgdown` has well-defined patterns for logos, favicons, and custom styling.

## Key Research Findings
- **Logo Canonical Path:** `man/figures/logo.svg` (preferred) or `logo.png`. `pkgdown` detects this automatically.
- **Favicon Generation:** `pkgdown::build_favicons()` generates a full set of icons from the package logo and places them in `pkgdown/favicon/`.
- **Theming with bslib:** For Bootstrap 5 sites, `bslib` variables in `_pkgdown.yml` are the preferred way to set primary colors and other theme constants.
  ```yaml
  template:
    bootstrap: 5
    bslib:
      primary: "#007bff" # Example typstR blue
  ```
- **Custom CSS:** `pkgdown/extra.css` is automatically detected and loaded after default styles. This is useful for more specific overrides not covered by `bslib`.
- **Rbuildignore:** The `pkgdown/` directory (containing `extra.css` and `favicon/`) must be listed in `.Rbuildignore`.

## Asset Strategy
- **Logo:** Since I am a text-based agent, I will generate a simple, clean SVG logo using code. It should be abstract and related to "typesetting" or "R".
- **Color Palette:** A professional "Deep Blue" or "Oxford Blue" (e.g., `#002147`) fits the academic target audience well.

## Implementation Path
1. Create `man/figures/` directory.
2. Generate and write `man/figures/logo.svg`.
3. Run `pkgdown::build_favicons()`.
4. Update `_pkgdown.yml` with `bslib` primary color and light-switch.
5. Create `pkgdown/extra.css` for minor adjustments (e.g., code block styling).
6. Verify local build.
