# footprint

An orchestration skill for AI coding agents. It reduces how many actions and
how much context an agent burns to complete a task — not by writing shorter
sentences, but by changing the order and shape of the work itself: search
narrow before reading wide, avoid re-checking things that already succeeded,
batch independent steps together, and hand off broad exploration to an
isolated sub-task instead of dragging it all into the main conversation.

## Why

Agents given a vague task tend to explore broadly before narrowing in —
listing whole directories, reading full files "just in case," re-reading
files they already changed to double check, and repeating searches one at a
time instead of together. Each of those habits costs real time and context,
independent of how verbose the agent's final answer is.

`footprint` is a set of orchestration rules that front-load precision
instead: lock the target first, search narrow, read only what's needed,
trust successful actions instead of re-verifying them, and isolate large
exploratory sub-tasks so their bulk never enters the main thread.

## Example scenarios

**Tracking down a bug report**
Given "users report a crash on checkout," a broad approach reads the entire
checkout module end to end. `footprint` first searches for the exact error
string or stack trace line, reads only the surrounding function, and checks
its immediate callers — not the whole module.

**Reviewing a multi-file change**
Given a change touching a dozen files, a broad approach opens every file in
full. `footprint` diffs first, reads only the changed hunks plus enough
surrounding context to judge correctness, and only opens a full file when a
change can't be understood without seeing the whole thing.

**Tracing a config value across a system**
Given "where does this setting actually get used," a broad approach walks
every directory by hand. `footprint` searches for the setting's name once,
reads only the matching lines, and — if the trail crosses many unrelated
files — delegates the rest of the trace to a separate exploration pass so
only the answer comes back, not every file it touched.

## What it changes

- Search before reading: narrow lookups first, full reads only when the
  narrow lookup isn't enough.
- No redundant re-checking: a successful change is trusted, not re-read to
  confirm it landed.
- Batched, not serial: independent lookups run together instead of one
  after another.
- One reconnaissance pass: gather what's foreseeably needed up front rather
  than repeatedly circling back for "one more thing."
- Isolated exploration: wide searches that would pull a lot of material
  into the main task are handed off, with only the relevant result
  returned.
- Locked scope: only what was actually asked for gets touched — no
  unrelated "while I'm here" changes.

## What it doesn't change

Response length and tone are untouched. This skill governs how an agent
gets to an answer, not how the answer reads once it gets there.

## Install

Drop the `footprint` directory into your agent's skills folder. It's picked
up automatically on tasks that call for reduced tool usage or leaner
context, or can be invoked directly by name.

## License

MIT
