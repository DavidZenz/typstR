# Phase 7: First-run Onboarding Reliability - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-04-01
**Phase:** 07-first-run-onboarding-reliability
**Areas discussed:** Starter template depth and defaults

---

## Starter template depth and defaults

| Option | Description | Selected |
|--------|-------------|----------|
| Lean skeleton only | title + minimal headings; users fill all content manually | |
| Guided rich starter | sample manuscript plus heavy instructional TODO text | |
| Hybrid runnable starter | compact realistic content that validates/renders cleanly with light guidance | ✓ |

**User's choice:** Hybrid runnable starter (compact realistic content with light guidance)
**Notes:** Prioritized first-run success without overloading users with verbose template noise.

---

## Starter metadata defaults

| Option | Description | Selected |
|--------|-------------|----------|
| Bare minimum fields only | keep YAML as minimal as possible | |
| Representative format-relevant defaults | include likely-needed `typstR` keys per format | ✓ |
| Extensive showcase metadata | include many optional fields for demonstration | |

**User's choice:** Representative defaults for format-relevant `typstR` keys
**Notes:** Supports ONB-01 first-run reliability while avoiding unnecessary optional complexity.

---

## Cross-format starter consistency

| Option | Description | Selected |
|--------|-------------|----------|
| Shared baseline with format-specific deltas | common structure + required differences only | ✓ |
| Fully independent per-format structures | each starter tuned separately | |
| Identical across all three formats | no format-specific default differences | |

**User's choice:** Shared baseline with format-specific deltas
**Notes:** Aligns with existing helper duplication patterns and reduces future drift risk.

---

## Guidance placement

| Option | Description | Selected |
|--------|-------------|----------|
| Inline in `template.qmd` | short notes near editable fields | ✓ |
| CLI output only | no template guidance comments | |
| Both inline + CLI | duplicate guidance surfaces | |

**User's choice:** Inline in `template.qmd`
**Notes:** Guidance should be discoverable at edit points rather than only in command output.

---

## the agent's Discretion

- Exact wording and placement of inline starter comments.
- Exact representative metadata values per format.
- Internal helper refactoring approach across `create_*` functions.

## Deferred Ideas

None.
