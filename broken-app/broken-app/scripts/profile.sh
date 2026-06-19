#!/usr/bin/env bash
set -euo pipefail

# perf + flamegraph on profile_workload (Linux, privileged Docker recommended).
# Usage: bash scripts/profile.sh

export DEBIAN_FRONTEND=noninteractive

if ! command -v perf >/dev/null; then
  apt-get update -qq
  apt-get install -y -qq linux-perf curl build-essential pkg-config libssl-dev 2>/dev/null || \
    apt-get install -y -qq perf 2>/dev/null || true
fi

if ! command -v cargo >/dev/null; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y -q
  # shellcheck disable=SC1091
  source "$HOME/.cargo/env"
fi

# Allow perf in containers
echo -1 > /proc/sys/kernel/perf_event_paranoid 2>/dev/null || true

cargo build --release --bin profile_workload

PERF_DATA="artifacts/plots/perf.data"
FLAME_SVG="artifacts/plots/flamegraph.svg"
FLAME_TXT="artifacts/after/perf_report.txt"

perf record -F 997 -g --call-graph dwarf -o "$PERF_DATA" \
  ./target/release/profile_workload 2>&1 | tee "$FLAME_TXT"

if command -v stackcollapse-perf.pl >/dev/null && command -v flamegraph.pl >/dev/null; then
  perf script -i "$PERF_DATA" | stackcollapse-perf.pl | flamegraph.pl > "$FLAME_SVG"
elif cargo flamegraph --version >/dev/null 2>&1; then
  cargo flamegraph --root --output "$FLAME_SVG" --bin profile_workload
else
  # Fallback: install FlameGraph tools
  if [ ! -d /tmp/FlameGraph ]; then
    git clone --depth 1 https://github.com/brendangregg/FlameGraph.git /tmp/FlameGraph
  fi
  perf script -i "$PERF_DATA" | /tmp/FlameGraph/stackcollapse-perf.pl | /tmp/FlameGraph/flamegraph.pl > "$FLAME_SVG"
fi

echo "Flamegraph: $FLAME_SVG"
perf report -i "$PERF_DATA" --stdio --no-children 2>&1 | head -80 >> "$FLAME_TXT"
