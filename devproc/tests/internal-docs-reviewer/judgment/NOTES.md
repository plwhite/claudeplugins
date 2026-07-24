# Notes

Non-obvious findings only. Do not record things derivable from reading the
code.

---

## CSV export test flaked twice this week (2026-06-02)

`test_export_large_tenant` failed twice in CI with a timeout around 50
seconds; bumped the local test timeout to 90 seconds as a stopgap. If it
keeps happening, worth profiling the CSV writer rather than raising the
timeout again.
