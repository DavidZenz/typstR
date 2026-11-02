#!/usr/bin/env bash
set -euo pipefail
out="${1:-artifacts/render}"
mkdir -p "$out"
if Rscript --vanilla tools/render-assurance.R "$out" >"$out/render.log" 2>&1; then
  cat "$out/render.log"
else
  cat "$out/render.log"
  exit 1
fi
if grep -Ei 'warning:|\[WARNING\]|citation.*not found|unknown font family' "$out/render.log"; then
  echo "Render warnings require investigation."
  exit 1
fi
