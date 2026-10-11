# Design

This page records rules the code is deliberately built to follow.

## Cleanup stays inside the cache

`cleanup.sh` never deletes anything outside the cache directory, and accepts no
path argument. This is deliberate: users have lost data to cleanup scripts that
accept arbitrary paths.
