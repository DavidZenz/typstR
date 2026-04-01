# Phase 5: Structured Diagnostics Foundation - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-03-31
**Phase:** 05-structured-diagnostics-foundation
**Areas discussed:** Diagnostics schema shape, Severity semantics, Diagnostic code system, Aggregation behavior

---

## Diagnostics schema shape

| Option | Description | Selected |
|--------|-------------|----------|
| Minimal required-only shape | Include only `code`, `severity`, `location`, `hint` | |
| Required + human message + optional details | Keep required fields plus `message`, optional `details` for context | ✓ |
| Free-form issue objects | Allow variable fields per check without strict schema | |

**User's choice:** Delegated to agent; agent selected recommended default (required fields + message + optional details).
**Notes:** User response: "you decide, I don't have a clue what's necessary here".

---

## Severity semantics

| Option | Description | Selected |
|--------|-------------|----------|
| Two-level severity | `error` and `warning` only | ✓ |
| Three-level severity | `error`, `warning`, `info` | |
| Numeric severity | Integer levels interpreted by callers | |

**User's choice:** Delegated to agent; agent selected recommended default (two-level severity).
**Notes:** Keep semantics explicit for downstream gating in later phases.

---

## Diagnostic code system

| Option | Description | Selected |
|--------|-------------|----------|
| Namespaced stable IDs | `DIAG-<AREA>-<NNN>` with no code reuse | ✓ |
| Free-text codes | Human-readable strings without numeric IDs | |
| Per-module local IDs | Independent local code spaces per file/module | |

**User's choice:** Delegated to agent; agent selected recommended default (stable namespaced IDs).
**Notes:** Contract prioritizes repeatability and test stability.

---

## Aggregation behavior

| Option | Description | Selected |
|--------|-------------|----------|
| Collect-all deterministic | Report all discovered issues in stable order | ✓ |
| Fail-fast | Stop on first error | |
| Hybrid opportunistic | Fail-fast for some checks, aggregate others | |

**User's choice:** Delegated to agent; agent selected recommended default (collect-all deterministic).
**Notes:** Deterministic ordering set as severity -> location -> code.

---

## the agent's Discretion

- User delegated all gray-area decisions for this phase.
- Agent chose recommended defaults and then requested confirmation.
- User confirmed: "Proceed with these defaults".

## Deferred Ideas

None.
