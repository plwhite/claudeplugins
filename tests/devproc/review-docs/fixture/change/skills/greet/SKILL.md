---
name: greet
description: Greet a person by name using the greeter tool
---

Run `bin/greet.sh --name <name>` and show the output to the user.
Keep any extra commentary to one sentence.

Rules:

- If the user gives no name, ask for one before running anything.
- Pass the name exactly as given; never shorten or change its spelling.
- If `bin/greet.sh` fails, show its error text unchanged and stop.
- Never run `bin/cleanup.sh` as part of a greeting.
