# Notes

Non-obvious findings only. Do not record things derivable from reading the
code.

---

## Webhook retries are capped at 3 attempts

The payment webhook handler gives up after 3 delivery attempts
(`webhooks/config.yaml`, `max_attempts: 3`), not the provider's default of 5 —
this service explicitly overrides the default because the downstream queue
times out requests after 90 seconds and a 5th retry would arrive after that
window closes.
