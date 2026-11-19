# Tests

Maintainer-only test fixtures for the `devproc` plugin's reviewer agents and
the `/review-docs` skill. They live here, outside `devproc/`, because that
directory is the unit of distribution — the marketplace source, the tree `docker/Dockerfile` copies, and
what `docs/setup.md` installs — and a consumer of the plugin has no use for
test material.

Tests are namespaced by what they test: `tests/devproc/` holds the `devproc`
plugin's, leaving room for other areas (`bin/`, the container scripts) without
a later reorganisation.

## Start here

To run a regression pass over the two plan-file suites (`feature-spec-reviewer`
and `feature-design-reviewer`):

```
tests/devproc/harness/run.sh -n     # list the cases that would run
tests/devproc/harness/run.sh        # run them
```

Run from the repository root, or from anywhere using an absolute path — the
script resolves its own paths.

The other two suites are run by hand; see their own READMEs.

After changing the plugin, [refresh the installed copy](../CONTRIBUTING.md#refresh-the-installed-plugin-in-place)
and start a new session before running any suite: the suites run the installed
agents and skill, not this repository's copy.

Each suite's own `README.md` defines the pass rule — the harness runs cases and
captures output, it does not judge pass/fail.

## Contents

| Directory | What it holds |
|-----------|---------------|
| [tests/devproc/feature-spec-reviewer/](devproc/feature-spec-reviewer/README.md) | Fixtures for `feature-spec-reviewer`: deliberately flawed plan files paired with recorded `.expected.md` outputs |
| [tests/devproc/feature-design-reviewer/](devproc/feature-design-reviewer/README.md) | Fixtures for `feature-design-reviewer`, on the same terms |
| [tests/devproc/internal-docs-reviewer/](devproc/internal-docs-reviewer/README.md) | Fixtures for `internal-docs-reviewer`: each case a fixture directory reviewed as a stand-in repository |
| [tests/devproc/review-docs/](devproc/review-docs/README.md) | A stand-in git repository with planted documentation faults for `/review-docs`, run by hand |
| [tests/devproc/harness/](devproc/harness/README.md) | Regression harness (`run.sh`) for the two plan-file suites |

## Adding a suite

Give it a `README.md` stating its pass rule, add a row above, and check whether
`tests/devproc/harness/run.sh` can cover it.
