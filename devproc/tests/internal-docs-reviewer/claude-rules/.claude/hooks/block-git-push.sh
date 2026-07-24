#!/usr/bin/env bash
# Denies `git push` to the protected branches only; feature branches are
# allowed so a teammate agent can push its own branch for review.
case "$1" in
  *"git push"*main*|*"git push"*master*) echo "blocked" >&2; exit 1 ;;
  *) exit 0 ;;
esac
