#!/usr/bin/env bash
set -euo pipefail

echo "======================================================"
echo " Building StellarClear SettlementRegistry Contract"
echo "======================================================"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

# Check required target
if ! rustup target list --installed | grep -q "wasm32v1-none"; then
    echo "Adding wasm32v1-none compilation target..."
    rustup target add wasm32v1-none
fi

VERSION="$(grep -m1 '^version = ' Cargo.toml | cut -d '"' -f 2 || echo "0.1.0")"
echo "Target Contract Version: $VERSION"

echo "Building reproducible contract..."

# Set reproducible build flags - ensure consistent output
export CARGO_BUILD_RUSTFLAGS="--remap-path-prefix=$(pwd)= -C opt-level=z -C link-arg=-s -C debuginfo=0"
export RUSTFLAGS="--remap-path-prefix=$(pwd)= -C opt-level=z -C link-arg=-s -C debuginfo=0"

# Always use cargo rustc for reproducibility (avoid stellar CLI)
cargo rustc \
    --manifest-path contracts/settlement-registry/Cargo.toml \
    --crate-type cdylib \
    --target wasm32v1-none \
    --release

WASM_FILE="target/wasm32v1-none/release/settlement_registry.wasm"
SHA_FILE="${WASM_FILE}.sha256"

if [ -f "$WASM_FILE" ]; then
    if command -v sha256sum &>/dev/null; then
        HASH="$(sha256sum "$WASM_FILE" | awk '{print $1}')"
    elif command -v shasum &>/dev/null; then
        HASH="$(shasum -a 256 "$WASM_FILE" | awk '{print $1}')"
    else
        echo "Error: sha256sum or shasum required" >&2
        exit 1
    fi

    echo "$HASH  settlement_registry.wasm" > "$SHA_FILE"

    echo ""
    echo "======================================================"
    echo " Contract Artifact Metadata"
    echo "======================================================"
    echo "Version:       $VERSION"
    echo "Artifact Path: $WASM_FILE"
    echo "Artifact Size: $(wc -c < "$WASM_FILE") bytes"
    echo "SHA-256 Hash:  $HASH"
    echo "Checksum File: $SHA_FILE"
    echo "======================================================"
    echo "Build succeeded."
else
    echo "Error: WASM artifact not found at $WASM_FILE" >&2
    exit 1
fi
