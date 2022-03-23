#!/usr/bin/env bash
set -e
echo "---> Initializing Build Elexeum"

echo '[+] Build Elexeum'
cargo build --release

echo '[+] Build Elexeum chainspec'
./target/release/elexeum build-spec --chain=staging --disable-default-bootnode --raw > node/service/res/elexeum.json