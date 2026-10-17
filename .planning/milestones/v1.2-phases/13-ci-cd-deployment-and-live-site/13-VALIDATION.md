# Phase 13 Validation

**Phase:** 13-ci-cd-deployment-and-live-site
**Status:** Ready for execution

## Validation Strategy
Phase 13 validation ensures that the documentation site is successfully deployed and reachable. Since deployment depends on GitHub Actions and GitHub Pages settings, validation includes both local configuration checks and live URL verification.

## Requirement Coverage

| Requirement | Validation approach | Command / check |
|-------------|---------------------|-----------------|
| SITE-01 | GHA workflow exists with correct permissions | `grep "contents: write" .github/workflows/pkgdown.yaml` |
| SHIP-03 | Live site URL smoke test | `curl -s -I https://davidzenz.github.io/typstR/ | grep "HTTP/1.1 200 OK"` |

## Execution Order
1. Scaffold the GHA workflow and verify local config (Plan 13-01).
2. Human Checkpoint: Push to GitHub and wait for Actions to complete.
3. Human Checkpoint: Activate GitHub Pages in repo settings if not already active.
4. Verify the live site links and article rendering (Plan 13-02).

## Phase Gate
Phase 13 is complete only when:
- The `pkgdown.yaml` workflow completes successfully on GitHub Actions.
- `https://davidzenz.github.io/typstR/` loads correctly.
- All primary navigation links (Home, Get Started, Reference, Articles, Changelog) resolve on the live site.
- Articles display content as expected on the live site.
