#!/usr/bin/env bash
set -euo pipefail

# GDB-сессия на логическом баге average_positive (broken version).
# Сохраняет лог в artifacts/before/gdb_session.txt

OUT="artifacts/before/gdb_session.txt"
mkdir -p artifacts/before

if ! command -v gdb >/dev/null; then
  export DEBIAN_FRONTEND=noninteractive
  apt-get update -qq
  apt-get install -y -qq gdb 2>/dev/null || true
fi

if ! command -v cargo >/dev/null; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y -q
  # shellcheck disable=SC1091
  source "$HOME/.cargo/env"
fi

{
  echo "=== GDB session: logical bug in average_positive ==="
  echo "Date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "Binary: examples/gdb_average_bug (debug)"
  echo ""
} >"$OUT"

cargo build --example gdb_average_bug 2>&1 | tee -a "$OUT"

BIN="./target/debug/examples/gdb_average_bug"

gdb -batch \
  -ex "set pagination off" \
  -ex "file ${BIN}" \
  -ex "break gdb_average_bug.rs:6" \
  -ex "run" \
  -ex "info locals" \
  -ex "print values" \
  -ex "print values.len()" \
  -ex "print sum" \
  -ex "print sum as f64 / values.len() as f64" \
  -ex "echo Expected average of positives only: (5+15)/2 = 10.0\\n" \
  -ex "echo Buggy code divides by all elements: 15/3 = 5.0\\n" \
  -ex "next" \
  -ex "next" \
  -ex "continue" \
  -ex "quit" 2>&1 | tee -a "$OUT"

echo "GDB log written to $OUT"
