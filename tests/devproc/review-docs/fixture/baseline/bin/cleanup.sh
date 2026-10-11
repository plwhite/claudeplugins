#!/usr/bin/env bash
# Usage: cleanup.sh
# Removes cached greetings from the cache directory only.
set -euo pipefail

CACHE_DIR="${GREET_CACHE:-$HOME/.cache/greeter}"
rm -f "$CACHE_DIR"/*.txt
