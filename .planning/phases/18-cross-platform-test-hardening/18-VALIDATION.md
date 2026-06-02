# Phase 18 Validation

**Phase:** 18-cross-platform-test-hardening
**Status:** Ready for execution

## Validation Strategy
Phase 18 validation relies on the execution of the GitHub Actions CI pipeline across multiple operating systems. We ensure the workflow is correctly scaffolded without Quarto, and then we rely on human verification of the GitHub Actions logs to confirm that tests either pass or gracefully skip.

## Requirement Coverage

| Requirement | Validation approach | Command / check |
|-------------|---------------------|-----------------|
| CRAN-04 | CI Workflow Check | `grep "setup-quarto" .github/workflows/R-CMD-check.yaml` (Must FAIL) |
| CRAN-HYGIENE | CI Log Audit | Human Verification of GitHub Actions run |

## Execution Order
1. Scaffold the `R-CMD-check` workflow and verify Quarto is omitted (Plan 18-01).
2. Push the workflow to GitHub and trigger the CI pipeline (Plan 18-02).
3. Human Checkpoint: Verify the Actions logs for macOS, Windows, and Ubuntu (Plan 18-02).
4. Patch any failing tests with `.skip_if_no_quarto()` and iterate if necessary (Plan 18-02).

## Phase Gate
Phase 18 is complete only when:
- The `.github/workflows/R-CMD-check.yaml` exists and does not install Quarto.
- The GitHub Actions workflow completes successfully (green checkmark) on all configured operating systems.
- A human audit confirms that any skipped tests were correctly bypassed due to missing system requirements (Quarto/Typst).
