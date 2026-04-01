# Phase 7: First-run Onboarding Reliability - Context

**Gathered:** 2026-04-01
**Status:** Ready for planning

<domain>
## Phase Boundary

Ensure users can scaffold working paper, article, and policy brief projects and succeed on their first validation+render run on supported setups without manual template repair. This phase focuses on starter content reliability and onboarding flow quality for existing formats; it does not add new formats or broaden publication feature scope.

</domain>

<decisions>
## Implementation Decisions

### Starter template depth and defaults
- **D-01:** Starter `.qmd` files should use a **hybrid runnable** approach: compact, realistic content that validates/renders cleanly on first run, with light guidance comments.
- **D-02:** Starter YAML should include **representative defaults** for `typstR` fields that are commonly needed on first run, limited to fields relevant for each format (for example JEL/report-number where appropriate).
- **D-03:** Keep a **shared baseline starter structure** across working paper/article/policy brief, then apply format-specific deltas only where required by format behavior.
- **D-04:** First-run guidance should live **inside `template.qmd`** as short inline comments/notes near editable fields (not CLI-only guidance).

### the agent's Discretion
- Exact phrasing/placement of inline guidance comments, as long as they remain concise and do not break render output.
- Exact representative metadata values used as defaults, as long as they are realistic and format-appropriate.
- Whether to extract shared scaffold logic helper(s) across `create_*` functions during implementation, provided behavior remains equivalent and tested.
- Exact test fixture organization for first-run validation/render checks under Quarto-available vs no-Quarto guard paths.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Milestone and requirement contract
- `.planning/ROADMAP.md` — Phase 7 goal and success criteria (first-run scaffold + validation + render success for all three formats).
- `.planning/REQUIREMENTS.md` — `ONB-01` scope and v1.1 onboarding constraints.
- `.planning/PROJECT.md` — v1.1 milestone priorities and prior validated capabilities.
- `.planning/STATE.md` — sequence context and carry-forward decisions.

### Carry-forward phase decisions
- `.planning/phases/04-tests-documentation-and-cran-hardening/04-CONTEXT.md` — CRAN-safe Quarto guard posture and working-paper-first onboarding tone decisions.
- `.planning/phases/05-structured-diagnostics-foundation/05-CONTEXT.md` — diagnostics contract expectations and deterministic payload principles.
- `.planning/phases/06-pre-render-environment-validation/06-CONTEXT.md` — shared preflight validator contract used before render.
- `.planning/phases/06-pre-render-environment-validation/06-VERIFICATION.md` — verified truths for standalone/render validation parity and no-Quarto-safe behavior.

### Existing implementation references
- `R/create_working_paper.R` — current scaffold behavior and file-copy flow.
- `R/create_article.R` — article scaffold path and title override pattern.
- `R/create_policy_brief.R` — policy brief scaffold path and title override pattern.
- `R/validation_environment.R` — current pre-render validation entrypoint/contract.
- `R/render.R` — render wrapper behavior and preflight integration point.
- `tests/testthat/test-scaffolding.R` — scaffold file/content assertions baseline.
- `tests/testthat/test-yaml-integration.R` — guarded integration render posture.
- `inst/templates/workingpaper/template.qmd` — current starter defaults and comment style baseline.
- `inst/templates/article/template.qmd` — article starter baseline.
- `inst/templates/policy-brief/template.qmd` — policy brief starter baseline.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- All `create_*` helpers already share near-identical structure (dir guard, template copy, extension copy, optional title patch, cli success bullets), making shared baseline onboarding updates straightforward.
- `validate_render_environment()` provides a stable pass/fail preflight contract that can be used to prove first-run readiness.
- Template files already include realistic manuscript skeletons and metadata blocks; they can be tuned rather than rebuilt.

### Established Patterns
- Scaffolding helpers are strict no-overwrite (`cli::cli_abort` if directory exists).
- Tests for scaffolding run in temp dirs and assert file presence + format marker strings.
- Quarto-dependent integration checks are guarded with explicit skip rules (`skip_if_not(.quarto_available())`) to remain safe in environments without Quarto.
- Diagnostics and preflight behavior are now payload-first and deterministic (Phase 5/6 carry-forward).

### Integration Points
- Starter improvements primarily land in `inst/templates/*/template.qmd` and may require aligned assertions in `tests/testthat/test-scaffolding.R`.
- Any first-run validation/render reliability checks should plug into existing `test-yaml-integration.R` guarded workflow.
- If helper refactoring is done for consistency, changes should be centralized across all three `create_*` functions to avoid drift.

</code_context>

<specifics>
## Specific Ideas

- Keep starter manuscripts realistic enough to render cleanly without edits while still signaling where users should customize key fields.
- Prefer inline guidance at the exact edit points over long external onboarding prose for this phase.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---

*Phase: 07-first-run-onboarding-reliability*
*Context gathered: 2026-04-01*