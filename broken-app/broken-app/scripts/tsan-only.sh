#!/usr/bin/env bash
set -uo pipefail

# TSan only — needs setarch -R when ASLR sysctl is unavailable (Docker Desktop).
export DEBIAN_FRONTEND=noninteractive

if ! command -v cargo >/dev/null; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y -q
  # shellcheck disable=SC1091
  source "$HOME/.cargo/env"
fi

rustup toolchain install nightly 2>/dev/null || true
rustup +nightly component add rust-src 2>/dev/null || true

HOST="$(rustc +nightly -vV | awk '/host:/ {print $2}')"

echo "=== TSan (setarch -R) ==="
set +e
setarch "$(uname -m)" -R env \
  CARGO_TARGET_DIR=target/tsan \
  RUSTFLAGS="-Zsanitizer=thread" \
  cargo +nightly test -Zbuild-std --target "$HOST" --test integration 2>&1 | tee artifacts/after/tsan.txt
code="${PIPESTATUS[0]}"
set -e
echo "tsan exit: ${code}"
exit "${code}"
