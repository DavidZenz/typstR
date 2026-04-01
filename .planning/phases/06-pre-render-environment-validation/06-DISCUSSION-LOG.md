# Phase 6: Pre-render Environment Validation - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-04-01
**Phase:** 06-pre-render-environment-validation
**Areas discussed:** Validation entrypoint contract, Check coverage/aggregation, Render integration, Version-floor and extension checks

---

## Validation entrypoint contract

| Option | Description | Selected |
|--------|-------------|----------|
| Dedicated user-facing validator function | User runs explicit pre-render validation command/function and receives pass/fail report | ✓ |
| Implicit-only validation inside render | Validation only happens when calling render wrappers | |
| Hybrid opt-in flag on render only | Validation exposed only as render argument toggle | |

**Auto choice:** Dedicated user-facing validator function (recommended default)
**Notes:** Aligns with VAL-01 requirement wording: users can run pre-render validation before any render attempt.

---

## Check coverage and aggregation behavior

| Option | Description | Selected |
|--------|-------------|----------|
| Collect-all blockers in one run | Emit all detectable environment blockers in one pass, deterministic order | ✓ |
| Fail-fast on first blocker | Stop immediately when the first failing check is found | |
| Mixed mode (fail-fast in render, collect-all in validator) | Different semantics by callsite | |

**Auto choice:** Collect-all blockers in one run (recommended default)
**Notes:** Consistent with Phase 5 deterministic aggregate diagnostics behavior and better operator feedback.

---

## Render integration path

| Option | Description | Selected |
|--------|-------------|----------|
| Shared preflight primitive | Render wrappers and standalone validator call the same preflight checks | ✓ |
| Separate render-only guards | Keep existing render guards and build separate validator logic | |
| Temporary adapter shim | Build new validation but keep old render guards in parallel for now | |

**Auto choice:** Shared preflight primitive (recommended default)
**Notes:** Prevents contract drift and duplicate logic; enforces one concept/one representation.

---

## Version-floor and extension checks

| Option | Description | Selected |
|--------|-------------|----------|
| Explicit diagnostics for each check class | Independent codes for Quarto missing, Typst missing, version-floor mismatch, extension missing | ✓ |
| Single generic environment failure code | One code for any pre-render environment failure | |
| Human-readable messages only | No stable machine-readable check-class coding | |

**Auto choice:** Explicit diagnostics for each check class (recommended default)
**Notes:** Supports stable automation and aligns with Phase 5 codebook principles.

---

## the agent's Discretion

- Exact public function names and helper decomposition.
- Exact Quarto version floor constant and comparison strategy.
- Exact success-report class shape and print formatting.

## Deferred Ideas

None.
