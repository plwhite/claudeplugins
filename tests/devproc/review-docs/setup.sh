#!/usr/bin/env bash
# Build a scratch git repository for the review-docs suite in TARGET (must not
# exist or be empty): commit the baseline, with the canonical FEATUREMODEL.md
# installed as features/FEATUREMODEL.md, then apply the working-tree change
# (modified files, one renamed doc, two untracked new docs). Nothing is staged.
set -euo pipefail
[ $# -eq 1 ] || { echo "Usage: setup.sh TARGET_DIR" >&2; exit 2; }
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# The canonical feature model, three levels up in the repository's devproc/.
FM="$HERE/../../../devproc/skills/feature-init/FEATUREMODEL.md"
[ -f "$FM" ] || { echo "Canonical FEATUREMODEL.md not found at $FM" >&2; exit 1; }
TARGET="$1"
mkdir -p "$TARGET"
TARGET="$(cd "$TARGET" && pwd)"
[ -z "$(ls -A "$TARGET")" ] || { echo "$TARGET is not empty" >&2; exit 1; }

cp -a "$HERE/fixture/baseline/." "$TARGET/"
# The installed feature model, copied from the canonical file so it never goes stale.
mkdir -p "$TARGET/features"
cp "$FM" "$TARGET/features/FEATUREMODEL.md"
cd "$TARGET"
git init -q -b main
git -c user.name=fixture -c user.email=fixture@example.invalid add -A
git -c user.name=fixture -c user.email=fixture@example.invalid commit -q -m "Baseline"

# The change: overlay the changed and new files, remove the renamed doc.
cp -a "$HERE/fixture/change/." "$TARGET/"
rm docs/troubleshooting.md
# Same-size, same-second edits (e.g. --name to --user) look unmodified to git's
# stat cache, so bump the mtimes of the overlaid files.
(cd "$HERE/fixture/change" && find . -type f -print0) | (cd "$TARGET" && xargs -0 touch)
git update-index -q --refresh || true
echo "Scratch repository ready in $TARGET"
git status --short
