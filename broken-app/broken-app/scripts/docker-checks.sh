#!/usr/bin/env bash
set -euo pipefail

# Run sanitizers + perf/flamegraph inside Linux container (Docker Desktop).
# From broken-app root:
#   docker run --privileged --security-opt seccomp=unconfined --rm -v "$(pwd):/app" -w /app postgres:16 bash scripts/docker-checks.sh

export DEBIAN_FRONTEND=noninteractive

sed -i 's/\r$//' scripts/*.sh 2>/dev/null || true

apt-get update -qq
apt-get install -y -qq \
  curl build-essential pkg-config libssl-dev git \
  linux-perf perl 2>/dev/null || apt-get install -y -qq perf git perl

bash scripts/sanitizers.sh
bash scripts/profile.sh

echo "Done. See artifacts/asan_test.txt, tsan_test.txt, flamegraph.svg"
