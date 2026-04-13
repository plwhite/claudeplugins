# Code review agents and skills — Feature Plan

## Requirements

Four code review agents, each focused on a distinct level of scrutiny:

- **architectural** — checks that the architecture is valid, consistent with the design, and is the best approach. Uses `claude-opus-4-6`.
- **simplicity** — identifies where complex code could be simplified or unused code removed. Uses `claude-sonnet-4-6`.
- **general** — checks that the code does the right thing, is robust, and is suitably performant. Uses `claude-sonnet-4-6`.
- **nitty** — digs into low-level code quality: readability, comments, robustness. Uses `claude-sonnet-4-6`.

Skills that invoke these agents, incorporate their feedback, and apply it:

- A **full review** skill — runs all relevant agents over the whole codebase.
- A **feature review** skill — runs agents only over what has changed in the current feature (diff-scoped).
- The architectural review is expensive and is not always included; skills should make this opt-in or conditional.

## Design

*To be fleshed out when the feature starts.*

## Sub-tasks

*To be defined when the feature starts.*
