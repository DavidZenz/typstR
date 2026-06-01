# Phase 16 Research: Format Comparison and Milestone Audit

## Overview
Phase 16 provides the final piece of documentation depth for v1.3 by comparing the structural and feature-level differences between the three core formats.

## Key Research Findings

### 1. Format Feature Matrix Data

| Feature | Working Paper | Article | Policy Brief |
|---------|---------------|---------|--------------|
| **Core Intent** | Research pre-print | Journal submission | Executive summary |
| **Report Number** | Yes | No | Yes |
| **Anonymization** | Supported | Optimized (Review mode) | Supported |
| **JEL Codes** | Yes | Yes | Optional/Hidden |
| **Abstract Label** | "Abstract" | "Abstract" | "Summary" (default) |
| **ORCID** | Visible | Visible | Hidden (default) |
| **Branding Hooks** | Full | Full | Full |
| **Disclaimer Page** | Supported | Supported | Supported |

### 2. Implementation Strategy
- **Article Location:** `vignettes/format-comparison.Rmd`.
- **Wiring:** Add to `_pkgdown.yml` articles section.
- **Audit:** Use the standard `/gsd-audit v1.3` process (mapped to a manual/autonomous task in the plan).

### 3. Verification Gaps
- v1.3 Audit needs to check:
    - BRAND-01 (Logo/Favicon)
    - BRAND-02 (CSS accents)
    - EXT-01 (Advanced Examples)
    - EXT-02 (Format Comparison)
