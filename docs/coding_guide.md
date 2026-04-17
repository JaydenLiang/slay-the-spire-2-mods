# Coding Guide

## Reading Decompiled Source Files

When you need to read decompiled game source files (from Rider's DecompilerCache):

- Spawn a **separate sub-agent** (`subagent_type=Explore`) for **each file**.
- Do not read multiple decompiled source files in the main conversation context.
- Each sub-agent reads one file independently and returns a summary.

**Why:** Keeps decompiled code out of the main context window, avoiding noise and token waste.

### After reading a decompiled file

After reading a decompiled source file, the sub-agent **must** write its understanding of that file into `docs/game-engine-knowledge.md` — classes, methods, fields, and any notable behavior. This way future sessions can consult the knowledge doc instead of re-reading the raw source.

## Writing Code with Sub-Agents

Delegate actual code writing to sub-agents to keep the main conversation context lean.

### When to use sub-agents for coding

- **Always** for non-trivial code changes (new features, patches, multi-line edits)
- **Skip** for trivial one-liners where spawning overhead outweighs the benefit

### How many sub-agents

- **Parallel:** spawn multiple agents when changes are independent (different files, no mutual dependency)
- **Serial:** spawn one at a time when changes depend on each other's output
- **Single:** use one agent for a tightly coupled set of changes that must be consistent

### Token cost trade-off

Sub-agents are **not free** — each starts cold and reloads system prompt and memory. The real benefit is keeping the **main conversation context lean**, which matters most in long or complex sessions. For short one-off tasks, writing code directly in the main context is more economical.

### After writing code

After completing a coding task, the sub-agent **must** write back any knowledge gained:

1. **Game engine knowledge** — any API usage, gotchas, or constraints discovered during implementation; append to `docs/game-engine-knowledge.md`
2. **Mod architecture decisions** — why something was designed a certain way, which Harmony patch pattern was used, etc.; update `docs/designs/<mod-name>.md`

**Do NOT update changelogs** after each coding sub-agent. Changelogs are written once at commit time, based on the final result — not intermediate steps.
