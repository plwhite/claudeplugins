#!/usr/bin/env bash
# Usage: greet.sh --name NAME
# Prints a greeting in the language set by GREET_LANG (default: en).
set -euo pipefail

name=""
while [ $# -gt 0 ]; do
  case "$1" in
    --name) name="$2"; shift 2 ;;
    *) echo "unknown option: $1" >&2; exit 2 ;;
  esac
done

case "${GREET_LANG:-en}" in
  fr) echo "Bonjour, $name" ;;
  *) echo "Hello, $name" ;;
esac
