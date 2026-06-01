# Choosing a Format

## Introduction

`typstR` provides several pre-configured formats tailored to different
stages of the research and policy lifecycle. Whether you are drafting an
initial working paper, preparing a manuscript for journal submission, or
distilling findings into a policy brief, there is a format designed for
your needs.

## Comparison Matrix

The following table summarizes the key feature differences between the
three core formats:

| Feature | Working Paper | Article | Policy Brief |
|----|----|----|----|
| **Core Intent** | Research pre-print | Journal submission | Executive summary |
| **Report Number** | Yes | No | Yes |
| **Anonymization** | Supported | Optimized (Review mode) | Supported |
| **JEL Codes** | Yes | Yes | Optional/Hidden |
| **Abstract Label** | “Abstract” | “Abstract” | “Summary” (default) |
| **ORCID** | Visible | Visible | Hidden (default) |
| **Branding Hooks** | Full | Full | Full |
| **Disclaimer Page** | Supported | Supported | Supported |

## Use Cases

### Working Paper (`workingpaper`)

Best for institutional research series, pre-prints, and internal
technical reports. It includes prominent report numbers and JEL codes,
making it ideal for economic and social science research repositories.

- **Primary use:** SSRN, ArXiv, institutional series.
- **Key functions:**
  [`create_working_paper()`](https://davidzenz.github.io/typstR/reference/create_working_paper.md).

### Article (`article`)

Designed for submission to peer-reviewed journals. It features a
specialized “Review Mode” for double-blind peer review and omits
institutional metadata like report numbers that are typically not
included in journal manuscripts.

- **Primary use:** Journal submissions, conference papers.
- **Key functions:**
  [`create_article()`](https://davidzenz.github.io/typstR/reference/create_article.md).

### Policy Brief (`brief`)

A condensed format optimized for readability and impact. It changes the
“Abstract” label to “Summary” and is designed for executive summaries
and policy memos where brevity and clarity are paramount.

- **Primary use:** Executive summaries, policy memos, briefing notes.
- **Key functions:**
  [`create_policy_brief()`](https://davidzenz.github.io/typstR/reference/create_policy_brief.md).

## Next Steps

To learn how to use these formats, visit the [Getting
Started](https://davidzenz.github.io/typstR/articles/getting-started.md)
guide. For more complex layouts and customization, see the [Advanced
Examples](https://davidzenz.github.io/typstR/articles/advanced-examples.md)
article.
