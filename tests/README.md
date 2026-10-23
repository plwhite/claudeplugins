# Tests

Maintainer-only test fixtures for the `devproc` plugin's reviewer agents and
the `/review-docs` skill. They
live here, outside `devproc/`, because that directory is the unit of
distribution — the marketplace source, the tree `docker/Dockerfile` copies, and
what `docs/setup.md` installs — and a consumer of the plugin has no use for
test material.

Tests are namespaced by what they test: `tests/devproc/` holds the `devproc`
plugin's, leaving room for other areas (`bin/`, the container scripts) without
a later reorganisation.

## Start here

To run a regression pass over the two suites whose cases are single plan files
(`feature-spec-reviewer` and `feature-design-reviewer` — `internal-docs-reviewer`
and `review-docs` are run by hand, see their READMEs):

```
tests/devproc/harness/run.sh -n     # list the cases that would run
tests/devproc/harness/run.sh        # run them
```

Run from the repository root, or from anywhere using an absolute path — the
script resolves its own paths.

Each suite's own `README.md` defines the pass rule — the harness runs cases and
captures output, it does not judge pass/fail.

## Contents

| Directory | What it holds |
|-----------|---------------|
| [tests/devproc/feature-spec-reviewer/](devproc/feature-spec-reviewer/README.md) | Fixtures for `feature-spec-reviewer`: deliberately flawed plan files, one per check (including the requirement-heading format), plus two controls (the baseline, and requirements as headings), each paired with a recorded `.expected.md` |
| [tests/devproc/feature-design-reviewer/](devproc/feature-design-reviewer/README.md) | Fixtures for `feature-design-reviewer`, on the same terms, with three controls (the baseline; the older list format for both `## Sub-tasks` and `## Spec`; and `## Spec` requirements as headings) and several cases for the delivery-criteria check |
| [tests/devproc/internal-docs-reviewer/](devproc/internal-docs-reviewer/README.md) | Fixtures for `internal-docs-reviewer`. Shaped differently: each case is a fixture *directory* reviewed as a stand-in repository root, not a single file |
| [tests/devproc/review-docs/](devproc/review-docs/README.md) | A stand-in git repository for `/review-docs`: a script builds a scratch copy with a committed baseline, a working-tree change and planted documentation faults; run by hand, with a pass rule over the skill's report and the scratch copy |
| [tests/devproc/harness/](devproc/harness/README.md) | Regression harness (`run.sh`) for the two plan-file suites. Does **not** cover `internal-docs-reviewer` or `review-docs`, whose fixture shapes need different invocations |

## Adding a suite

Give it a `README.md` stating its pass rule, add a row above, add a bullet to
the `## tests directory` section of the root `CLAUDE.md`, and check whether
`tests/devproc/harness/run.sh` can cover it.
