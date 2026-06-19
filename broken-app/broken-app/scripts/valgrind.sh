#!/usr/bin/env bash
set -euo pipefail

# Valgrind on integration tests (Linux only).
# Usage: from broken-app root on Linux/WSL/Docker:
#   bash scripts/valgrind.sh

export DEBIAN_FRONTEND=noninteractive

if ! command -v valgrind >/dev/null; then
  apt-get update -qq
  apt-get install -y -qq valgrind
fi

if ! command -v cargo >/dev/null; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y -q
  # shellcheck disable=SC1091
  source "$HOME/.cargo/env"
fi

cargo build --tests
TEST_BIN=$(find target/debug/deps -maxdepth 1 -type f -name 'integration-*' ! -name '*.d' | head -1)

echo "Running valgrind on: $TEST_BIN"
valgrind --leak-check=full --show-leak-kinds=all --error-exitcode=1 "$TEST_BIN" 2>&1 | tee artifacts/after/valgrind.txt
