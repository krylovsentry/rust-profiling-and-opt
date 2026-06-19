#!/usr/bin/env bash
set -euo pipefail

# Пример сравнения бенчмарков (до/после).
cargo bench --bench baseline > artifacts/before/baseline_bench.txt
# После оптимизаций:
cargo bench --bench baseline > artifacts/after/baseline_bench.txt
