#!/usr/bin/env bash
# Usage: cleanup.sh [PATH]
# Removes PATH, or the cache directory when no PATH is given.
set -euo pipefail

CACHE_DIR="${GREET_CACHE:-$HOME/.cache/greeter}"
TARGET="${1:-$CACHE_DIR}"
rm -rf "$TARGET"
