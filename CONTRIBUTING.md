# Contributing

Thanks for your interest in contributing!

## Pull requests

Pull requests are welcome. However, this is a personal project and maintainership time is limited, so please don’t assume a PR will be reviewed or merged.

If you’d like to propose a change, it helps to:

- Keep PRs small and focused.
- Explain the motivation and any trade-offs.
- Update documentation when behavior changes.
- If you change `feature-spec-reviewer`, `feature-design-reviewer`, `internal-docs-reviewer` or one of the four `docs-review-*` agents under `devproc/agents/`, or the `review-docs` skill, re-run its fixture suite — see [tests/README.md](tests/README.md). The code-review agents and `dev-process-manager` have no fixture suite.

## Changing the feature model

The feature-model text has one canonical copy, `devproc/skills/feature-init/FEATUREMODEL.md`, which `/feature-init` copies into every workspace that uses the plugin. This repository uses the plugin on itself, so it also has an installed copy at `features/FEATUREMODEL.md`. To change the model, edit the canonical file and re-run `/feature-init` here, which refreshes the installed copy to match. Never edit `features/FEATUREMODEL.md` by hand; it is overwritten on the next run.

## Issues

Issues are welcome for bug reports and feature suggestions. Including reproduction steps (and expected vs actual behavior) makes it much easier to triage.
