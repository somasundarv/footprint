---
name: footprint
version: 1.0.0
description: |
  Reduce the number and size of tool calls (Read/Grep/Glob/Bash/Agent) and cut
  redundant context re-derivation. Changes the orchestration path, not the
  response style: fewer round-trips, narrower reads, subagent isolation. Use
  when the user says "reduce tool calls", "minimize context usage", "lean
  mode", "cut token usage", "/footprint", or when a task needs broad
  exploration across many files.
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
  - Edit
  - Write
  - Agent
  - TaskCreate
  - TaskUpdate
  - ToolSearch
---

# Footprint: orchestration-level token optimization

## What this is not

This is not a writing-style skill. It does not shorten sentences, drop
articles, or compress prose. A response produced under this skill can be as
verbose as normal. What shrinks is the *scaffolding* around the response:
number of tool calls, bytes read per call, and repeated context
re-derivation across turns. It can be paired with any output-compression or
verbosity style — the two axes are independent and additive, not
overlapping.

## Protocol (apply in order, every task)

1. **Scope-lock before touching a tool.** State the target in one line:
   file(s), symbol, or error string. If the request is ambiguous enough that
   you'd need to explore >3 locations to even find the target, ask ONE
   clarifying question (AskUserQuestion) instead of running a broad
   exploration pass. A wrong guess costs more tool calls than one question.

2. **Narrow before wide.** Order of operations: Glob/Grep with a specific
   pattern → Read only the matched line ranges (`offset`/`limit`) → never
   `Read` a full file over ~300 lines speculatively. Never `find` or `ls -R`
   a whole tree when a targeted `grep -r <symbol>` answers the question.

3. **No verify-reads.** After a successful Edit/Write, do not Read the file
   back to confirm the change landed — the tool call already failed loudly
   if it didn't. Only re-read if you need to reason about surrounding code
   you haven't seen yet, or a test/build step requires it.

4. **Batch, don't serialize.** Any tool calls with no data dependency
   between them go in the same turn. If step 2 needs results from 3
   independent greps, issue all 3 together, not one-then-wait-then-next.

5. **One reconnaissance pass.** Gather everything you can predict you'll
   need in the first exploration round. Avoid the pattern of grep → read →
   "oh I also need X" → grep again → read again. Think one step ahead: if
   you're reading a function to understand it, also capture its call sites
   in the same pass if you already suspect you'll need them.

6. **Delegate and isolate for anything wide.** If a sub-question would take
   more than ~2 files or ~200 lines to answer, route it to a subagent
   (Explore, or a project-specific investigator agent if available) instead
   of doing it inline. Only the digest comes back into the main thread —
   the exploration bytes never enter your context. This is the single
   biggest lever available; use it earlier than feels natural.

7. **Persist state, don't restate it.** For multi-step work, use
   TaskCreate/TaskUpdate (or the project's todo mechanism) to hold the plan.
   Don't re-summarize prior findings in your own reasoning each turn — refer
   back to the ledger.

8. **Don't preload what you don't need.** If deferred tools are available
   (ToolSearch-gated), only resolve the schema for a tool right before you
   call it, not speculatively for tools you might use.

9. **No speculative scope creep.** Only touch what scope-lock (step 1)
   named. "While I'm here" edits or reads inflate both the tool-call count
   and the diff the user has to review. If you notice an unrelated issue,
   name it in one line at the end — don't go fix it.

## End-of-task report

After completing a task under this skill, report actual counts, not
estimates:

```
Footprint: N tool calls (R reads, G greps/globs, E edits, A agent
delegations). [If a naive baseline is being compared: state the naive path
explicitly and why it would cost more — don't assert a percentage without
showing the counterfactual path.]
```

Never fabricate a token/percentage figure. If you want to show savings,
show the actual call count for the approach taken, and — only if you
genuinely would have taken a broader path without this skill — name that
alternate path and its call count so the comparison is falsifiable.
