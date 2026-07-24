# Payments module guide

This file covers instructions specific to the `payments/` module only.
Project-wide feature status lives in the root `CLAUDE.md`; do not duplicate it
here.

## Module notes

Use `PaymentGateway.charge()` for all card charges; never call the provider
SDK directly, so retries and idempotency keys stay centralised.

## Recent project status

`csv-export` completed 2026-05-02 — added CSV export to the reports page (#47).
See `features/COMPLETED.md` for detail.
