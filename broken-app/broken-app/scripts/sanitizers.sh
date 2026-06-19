#!/usr/bin/env bash
set -uo pipefail

# ASan + TSan on integration tests (Linux + nightly only).
# Usage: bash scripts/sanitizers.sh

export DEBIAN_FRONTEND=noninteractive

if ! command -v cargo >/dev/null; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y -q
  # shellcheck disable=SC1091
  source "$HOME/.cargo/env"
fi

rustup toolchain install nightly 2>/dev/null || true
rustup +nightly component add rust-src 2>/dev/null || true

HOST="$(rustc +nightly -vV | awk '/host:/ {print $2}')"

run_sanitizer() {
  local name="$1"
  local flag="$2"
  local out="artifacts/after/${name}.txt"
  echo "=== ${name} ==="
  set +e
  CARGO_TARGET_DIR="target/${name}" \
    RUSTFLAGS="-Zsanitizer=${flag}" \
    cargo +nightly test -Zbuild-std --target "$HOST" --test integration 2>&1 | tee "$out"
  local code="${PIPESTATUS[0]}"
  set -e
  echo "${name} exit: ${code}"
  return "${code}"
}

run_sanitizer "asan" "address" || true
echo ""
echo "=== tsan (setarch -R for Docker Desktop ASLR) ==="
set +e
setarch "$(uname -m)" -R env \
  CARGO_TARGET_DIR="target/tsan" \
  RUSTFLAGS="-Zsanitizer=thread" \
  cargo +nightly test -Zbuild-std --target "$HOST" --test integration 2>&1 | tee artifacts/after/tsan.txt
tsan_code="${PIPESTATUS[0]}"
set -e
echo "tsan exit: ${tsan_code}"
