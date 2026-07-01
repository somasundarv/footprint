# Changelog

## v1.0.0 — 2026-06-30

Initial release.

- Core protocol: scope-lock, narrow-before-wide search, no verify-reads,
  batched calls, single reconnaissance pass, delegate-and-isolate for wide
  sub-tasks, persisted task state, deferred-schema discipline, no
  speculative scope creep.
- End-of-task footprint report (actual tool-call counts, no fabricated
  percentages).
- `install.sh` for scripted install with a local, gitignored install log
  recording version and install date.
