# Phase 11: Documentation Content Foundation - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-06-01
**Phase:** 11-documentation-content-foundation
**Areas discussed:** Canonical onboarding split, First-screen README message, Vignette roles and order, Reference/example style

---

## Canonical onboarding split

### Surface division

| Option | Description | Selected |
|--------|-------------|----------|
| 1 | README = quick proof + install, site home = polished overview + links, getting-started = full walkthrough | ✓ |
| 2 | README and site home both show the full walkthrough; getting-started adds extra detail | |
| 3 | README stays minimal, site home owns the main onboarding story, getting-started becomes a technical appendix | |

**User's choice:** README = quick proof + install, site home = polished overview + links, getting-started = full walkthrough
**Notes:** The goal is one ladder, not three competing intros.

### Default scaffold path

| Option | Description | Selected |
|--------|-------------|----------|
| 1 | Working paper only as the main example; mention article and policy brief as follow-on options | ✓ |
| 2 | Show all three scaffolders side by side from the start | |
| 3 | Use article as the default example instead | |

**User's choice:** Working paper only as the main example; mention article and policy brief as follow-on options
**Notes:** Adjacent formats should appear as next steps rather than early branches.

### Edit-step detail

| Option | Description | Selected |
|--------|-------------|----------|
| 1 | Name `template.qmd`, `_quarto.yml`, and `references.bib` in getting-started; keep README/home lighter | ✓ |
| 2 | Keep the edit step high-level everywhere and avoid naming specific files | |
| 3 | Include detailed file-by-file explanation in README, site home, and getting-started | |

**User's choice:** Name the exact files and explain their role in getting-started; keep README/home lighter
**Notes:** Specific file names belong in the walkthrough, not in every intro surface.

---

## First-screen README message

### Above-the-fold contents

| Option | Description | Selected |
|--------|-------------|----------|
| 1 | Value proposition, install command, Quarto/system requirement note, and a very short scaffold -> render preview | ✓ |
| 2 | Value proposition, install command, and format overview only | |
| 3 | A fuller narrative introduction with package capabilities before showing commands | |

**User's choice:** Value proposition, install command, Quarto/system requirement note, and a very short scaffold -> render preview
**Notes:** README should optimize for instant adoption.

### Quarto requirement framing

| Option | Description | Selected |
|--------|-------------|----------|
| 1 | Short explicit callout: install typstR in R now, but Quarto is required when you render | ✓ |
| 2 | Treat Quarto as a general prerequisite and describe it in a fuller setup section below | |
| 3 | Mention Quarto only later in the walkthrough | |

**User's choice:** Short, explicit callout: install typstR in R now, but Quarto is required when you render
**Notes:** The warning should appear early enough to prevent false starts without overwhelming the landing section.

### Opening tone

| Option | Description | Selected |
|--------|-------------|----------|
| 1 | Direct and adoption-focused: emphasize the fast path to a polished paper, not the internals | ✓ |
| 2 | Balanced: equal emphasis on user outcome and package capabilities | |
| 3 | Reference-style: lead with capabilities and technical scope | |

**User's choice:** Direct and adoption-focused: emphasize the fast path to a polished paper, not the internals
**Notes:** README should sound like an invitation to try the package, not a manual.

---

## Vignette roles and order

### Article journey

| Option | Description | Selected |
|--------|-------------|----------|
| 1 | Getting Started first, Working Papers second, Customizing Branding third | ✓ |
| 2 | Getting Started first, Customizing Branding second, Working Papers third | |
| 3 | Treat all three as peers with no implied order | |

**User's choice:** Getting Started first for the full walkthrough, Working Papers second for metadata/title-page depth, Customizing Branding third for visual customization
**Notes:** The docs should suggest a progression instead of presenting three flat alternatives.

### Overlap policy

| Option | Description | Selected |
|--------|-------------|----------|
| 1 | Very little overlap; briefly link back to Getting Started, then focus on domain-specific tasks | ✓ |
| 2 | Moderate overlap; repeat the full flow in compressed form before adding specifics | |
| 3 | High overlap; each article stands fully alone even if repetition increases | |

**User's choice:** Very little: briefly link back to Getting Started, then focus on their own domain-specific tasks
**Notes:** Repetition should be minimized once the base flow is taught.

### Branding article focus

| Option | Description | Selected |
|--------|-------------|----------|
| 1 | Practical guide to the YAML/front-matter knobs users are most likely to change first | ✓ |
| 2 | Broader visual design guide with many styling variants | |
| 3 | Catalog of branding fields with little workflow guidance | |

**User's choice:** A practical guide to the YAML/front-matter knobs users are most likely to change first
**Notes:** Phase 11 should stay pragmatic, not become a full design manual.

---

## Reference/example style

### Help-page example shape

| Option | Description | Selected |
|--------|-------------|----------|
| 1 | Minimal runnable snippets that reinforce the main workflow without becoming mini-vignettes | ✓ |
| 2 | Longer workflow examples embedded directly in help pages | |
| 3 | Mostly API-style examples that show arguments in isolation | |

**User's choice:** Minimal runnable snippets that reinforce the main workflow without becoming mini-vignettes
**Notes:** Narrative learning belongs in the vignettes.

### Workflow versus helper emphasis

| Option | Description | Selected |
|--------|-------------|----------|
| 1 | Prefer examples tied to real scaffolding and rendering actions, with helper-only examples when necessary | ✓ |
| 2 | Split evenly between workflow actions and isolated helpers | |
| 3 | Mostly isolated helper calls for complete API coverage | |

**User's choice:** Prefer examples tied to real user actions around scaffolding and rendering, with helper-only examples when necessary
**Notes:** Examples should reflect what users do right after the walkthrough.

### Scope of example refresh

| Option | Description | Selected |
|--------|-------------|----------|
| 1 | Prioritize the high-traffic user-facing functions first; lower-level helpers can stay lighter if needed | ✓ |
| 2 | Refresh examples for every exported function to the same depth | |
| 3 | Focus only on vignette-linked functions and leave the rest unchanged | |

**User's choice:** Prioritize the high-traffic user-facing functions first; lower-level helpers can stay lighter if needed
**Notes:** Phase 11 should use effort where it most changes first-run success.

---

## the agent's Discretion

- Exact copy, section labels, and visual ordering inside README and vignette prose
- Which lower-level helper pages receive deeper example refresh beyond the highest-traffic scaffold/render functions
- Final editorial wording for `NEWS.md` milestone summaries

## Deferred Ideas

None.
