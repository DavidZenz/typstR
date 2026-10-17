# Performance evidence — 2026-10-17

R 4.6.1, arm64 macOS 26.6.2, bench-backed 60 iterations, shared workloads and
historical YAML baselines unchanged. `tools/benchmark.R artifacts/benchmark`
records session/toolchain, complete bench objects and CSV comparisons.

| Workload | p50 ms | p95 ms | Historical current baseline ms |
|---|---:|---:|---:|
| Mocked environment collection | 0.03969 | 0.04299 | 0.04592 |
| Mocked environment validation | 0.13936 | 0.28738 | 0.13694 |
| Real working-paper scaffolding | 34.963 | 95.734 | 10.588 |

The scaffold ratio (3.30) triggered investigation; no speed improvement is claimed.
Historical baseline 37bc2d3 has no recorded comparable hardware/toolchain. Comparing
that source snapshot and current scaffold functions/assets on this same host, with
40 interleaved iterations in three rounds, produced historical/current p50 ms:
26.960/30.832, 32.506/30.217, 31.209/31.894. All paired ratios were below the existing
1.45 tolerance. Runtime scaffold helper code is unchanged versus 37bc2d3 (only its
public documentation changed). The old 10.588 ms figure was not reproduced even
with historical code. This supports environmental/workload drift rather than a
reproduced current-code regression; it does not justify resetting the baseline.

Raw evidence: artifacts/benchmark/comparisons.csv, same-host-scaffold-comparison.csv,
toolchain.txt and per-workload RDS objects (local, ignored artifacts). Repeat on the
release CI host before using measurements to make release performance claims.
