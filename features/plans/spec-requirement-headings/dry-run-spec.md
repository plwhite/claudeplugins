<!-- Dry-run output of /devproc:feature-spec --no-review on the throwaway backup-CLI description (sub-task 5). Whole plan file below. -->

# Add a `--dry-run` flag to the backup CLI — Feature Plan

## Requirements

The user supplied only this description (verbatim); nothing further was said:

> Add a `--dry-run` flag to a backup CLI. With it the CLI must: list every file it would copy; list every file it would delete at the destination; print the total bytes it would transfer; skip all writes; skip all deletes; still validate the config file and fail on errors; still check the destination is reachable; exit 0 if it would succeed and 2 if it would fail; and print a final line saying no changes were made.

## Spec

### Purpose

The backup CLI copies files from a source to a destination, driven by a config file, and may delete files at the destination. A user currently has no way to see what a run will do before it does it. This feature adds a `--dry-run` flag: a run with the flag performs every check a real run would perform and reports exactly what a real run would change, but changes nothing. Its output and exit code tell the user whether the real run would succeed.

In this spec, a **real run** is the same command invoked without `--dry-run`, against the same config, source and destination at the same moment. "Would" always means "what the real run would do".

### 1. The flag

The CLI accepts a `--dry-run` flag. Without the flag, the CLI's behaviour is unchanged.

Proposed: `--dry-run` combines with every other option the CLI accepts, and those options affect the dry-run report exactly as they would affect a real run (e.g. an option that filters files filters the listed files too).

### 2. List files that would be copied

The CLI prints every file the real run would copy to the destination — one file per line, each identified by its path. Files the real run would skip (e.g. already up to date) are not listed.

Proposed: paths are printed relative to the source root, under a heading that marks them as copies, so they cannot be confused with the delete list.

### 3. List files that would be deleted at the destination

The CLI prints every file the real run would delete at the destination, one per line. If the real run would delete nothing, the CLI says so rather than printing an empty list.

Proposed: paths are printed relative to the destination root, under a heading that marks them as deletions.

### 4. Total bytes to transfer

The CLI prints the total number of bytes the real run would transfer.

Proposed: this is the sum of the sizes of the files listed under requirement 2. Deletions contribute nothing. The figure is printed as an exact byte count (a human-readable form such as "1.2 GiB" may follow it, but does not replace it).

### 5. No writes

A dry run writes nothing at the destination: no files are created or modified, no directories are created, and no file metadata (timestamps, permissions) is changed.

Proposed: the dry run also writes no persistent state anywhere else the real run would — no state or index files, caches, lock files or run logs on the local machine. Its only outputs are standard output, standard error and the exit code.

### 6. No deletes

A dry run deletes nothing at the destination or anywhere else.

### 7. Config validation still happens

The dry run loads and validates the config file exactly as a real run does. If validation fails, the CLI reports the errors as a real run would and the dry run fails (see requirement 9).

### 8. Destination reachability is still checked

The dry run checks that the destination is reachable, as a real run does. If it is not reachable, the CLI reports this and the dry run fails (see requirement 9). The check must not write to the destination (requirement 5) — for example, it must not test reachability by creating a probe file.

### 9. Exit code

The CLI exits with status 0 if the real run would succeed, and 2 if it would fail.

"Would fail" includes at least: the config file fails validation (requirement 7), and the destination is unreachable (requirement 8).

Proposed: "would fail" also covers every other failure the dry run can detect without writing — for example, a source file the real run would need to copy that cannot be read. Failures that can only be discovered by writing (e.g. the destination running out of space mid-copy) are out of scope: the dry run cannot detect them, and may exit 0 in cases where the real run later fails.

Proposed: if the run fails before the file lists can be computed (e.g. invalid config), the CLI prints the error and the final line (requirement 10) and exits 2 without printing the lists or total.

### 10. Final "no changes" line

The last line the CLI prints in a dry run states that no changes were made (e.g. `Dry run: no changes were made.`).

Proposed: this line is printed on every dry run, whether it would succeed or fail, since in both cases nothing was changed. It goes to standard output.

### Out of scope

- Any change to the CLI's behaviour without `--dry-run`.
- A machine-readable (e.g. JSON) output format for the dry-run report.

## Sign-off strategy

- **Testing** — Automated tests covering every numbered requirement in `## Spec`, including both exit codes (0 and 2) and each named failure cause (invalid config, unreachable destination). Requirements 5 and 6 (no writes, no deletes) are tested by asserting that the destination's contents and metadata are identical before and after a dry run.
- **Documentation** — The CLI's user docs (its `--help` text and `README.md`, or wherever the CLI's options are documented) describe `--dry-run`: what it reports, that it changes nothing, and its exit codes.
- **Code review** — One agent `/review-branch` before `/feature-end`.
- **Docs review** — One agent `/review-docs` over the change before `/feature-end`, all kinds: accuracy, architectural and style because user docs gain new prose describing a new option; agent docs because `NOTES.md`/`CLAUDE.md` may need to record findings about the CLI.
- **User review** — Final user review: the user runs `--dry-run` against a real config and confirms the report and exit codes are as expected before `/feature-end`.

End-of-feature gates: one `/review-branch`, one `/review-docs` over the change (all kinds), and the final user review.

## Design

*To be fleshed out by `/feature-design`.*

## Review record

- 2026-10-23 — Spec review: N/A — skipped on the user's instruction. Presented to the user for sign-off, unreviewed.
