#!/bin/bash -e

TOOLCHAIN_VERSION=1.0

COMPILER=rust-ubuntu-x86-64.tar.gz

stdbuf -oL printf "Fetching sel4-aware Rust compiler..."
(
    rm -rf rust &&
        curl -OL https://github.com/GaloisInc/sel4-rust/releases/download/$TOOLCHAIN_VERSION/$COMPILER &&
        tar -xf $COMPILER &&
	mv stage2 rust
) >/dev/null 2>&1
echo " done."

stdbuf -oL printf "Setting up tree-local Cargo configuration..."
mkdir -p .cargo
cat >.cargo/config <<EOF
[build]
target = "x86_64-sel4-robigalia"
rustflags = ["--sysroot", "rust"]
rustc = "rust/bin/rustc"
EOF
echo " done."
