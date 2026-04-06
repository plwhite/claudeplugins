---
name: demo-skill
description: A minimal placeholder skill that returns a fixed response. Use when the user invokes demo-skill or asks to test skill wiring.
user-invocable: true
---

# demo-skill

A minimal, intentionally not-useful skill document.

## Purpose

Return a fixed, deterministic response ("hello") so it's easy to verify the skill wiring without doing real work.

## Contract

- Input: any text
- Output: the literal string `hello`

## Example

Input:
- `anything at all`

Output:
- `hello`
