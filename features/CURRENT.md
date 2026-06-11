# Features in progress

Features currently being developed. Each feature has a level three (`###`)
heading with a name and slug (e.g. `[initial-development]`) so its plan file in
`features/plans/` can be found.

*There should normally be only one feature here, and it should have a plan
matching the slug in `features/plans/`. In some cases there may be no feature in
progress, or in very rare cases more than one at once.*

---

### Split FEATURES.md into separate files to save tokens [split-features-md]

Replace the single `FEATURES.md` with a `features/` directory holding `CURRENT.md`, `PENDING.md`, `DEFERRED.md` and `COMPLETED.md`, so the large completed list need not be read into context every session. Also move the `plans/` slug directory under `features/`, make feature creation always write a slug file containing the full issue content, and update `/feature-init` to migrate existing setups. Scope additionally covers renaming the `feature-create`/`feature-start` skills to `feature-spec`/`feature-design` to make the lifecycle (spec → design → implement → end) clearer. See #14. Sub-task detail in [features/plans/split-features-md.md](plans/split-features-md.md).
