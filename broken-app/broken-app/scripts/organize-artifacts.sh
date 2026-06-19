#!/usr/bin/env bash
set -euo pipefail

# Reorganize flat artifacts/ into before/ after/ plots/ (idempotent).
ROOT="artifacts"
mkdir -p "$ROOT/before" "$ROOT/after" "$ROOT/plots/criterion"

move_if() {
  local src="$1" dst="$2"
  if [ -f "$src" ] && [ "$src" != "$dst" ]; then
    mv -f "$src" "$dst"
  fi
}

move_if "$ROOT/test_before.txt"              "$ROOT/before/cargo_test.txt"
move_if "$ROOT/baseline_before.txt"          "$ROOT/before/baseline_bench.txt"
move_if "$ROOT/criterion_before.txt"           "$ROOT/before/criterion_bench.txt"

move_if "$ROOT/test_after.txt"               "$ROOT/after/cargo_test.txt"
move_if "$ROOT/baseline_after.txt"           "$ROOT/after/baseline_bench.txt"
move_if "$ROOT/criterion_after.txt"          "$ROOT/after/criterion_bench.txt"
move_if "$ROOT/miri_test.txt"                "$ROOT/after/miri.txt"
move_if "$ROOT/valgrind_test.txt"              "$ROOT/after/valgrind.txt"
move_if "$ROOT/asan_test.txt"                "$ROOT/after/asan.txt"
move_if "$ROOT/tsan_test.txt"                "$ROOT/after/tsan.txt"
move_if "$ROOT/clippy.txt"                    "$ROOT/after/clippy.txt"
move_if "$ROOT/perf_report.txt"              "$ROOT/after/perf_report.txt"
move_if "$ROOT/perf_run.log"                 "$ROOT/after/perf_run.log"

move_if "$ROOT/flamegraph.svg"               "$ROOT/plots/flamegraph.svg"
move_if "$ROOT/perf.data"                    "$ROOT/plots/perf.data"
move_if "$ROOT/criterion_plots/sum_even_typical.svg"    "$ROOT/plots/criterion/sum_even.svg"
move_if "$ROOT/criterion_plots/slow_fib_typical.svg"    "$ROOT/plots/criterion/slow_fib.svg"
move_if "$ROOT/criterion_plots/slow_dedup_typical.svg" "$ROOT/plots/criterion/slow_dedup.svg"
move_if "$ROOT/criterion_plots/index.html"              "$ROOT/plots/criterion/index.html"

move_if "$ROOT/miri_notes.txt"               "$ROOT/environment.txt"

rmdir "$ROOT/criterion_plots" 2>/dev/null || true

echo "Artifacts layout:"
find "$ROOT" -maxdepth 3 -type f | sort
