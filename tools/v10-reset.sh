#!/usr/bin/env bash
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

tar -xSjf "$ROOT/image/v10.tar.bz2" -C "$ROOT/images" || exit 1
tar -xSjf "$ROOT/image/v10-golden.tar.bz2" -C "$ROOT/images" || exit 1
