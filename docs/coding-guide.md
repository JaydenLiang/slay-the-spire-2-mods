# Coding Guide

## Commit Message Convention

When committing changes that affect a specific mod, always include the mod name as the conventional commit scope:

```text
feat(reload-run): add F6 solo mode
fix(modded-save-sync): correct save path on Linux
```

This is required for automated version bump inference during release. Commits without a mod scope are ignored by the release flow. See `docs/deployment.md` for details.

---

## Reading Decompiled Source Files

When you need to read decompiled game source files (from Rider's DecompilerCache):

- Spawn a **separate sub-agent** (`subagent_type=Explore`) for **each file**.
- Do not read multiple decompiled source files in the main conversation context.
- Each sub-agent reads one file independently and returns a summary.

**Why:** Keeps decompiled code out of the main context window, avoiding noise and token waste.

After reading a decompiled source file, the sub-agent **must** write its understanding into `docs/game-engine-knowledge.md` — classes, methods, fields, and any notable behavior. This way future sessions can consult the knowledge doc instead of re-reading the raw source.

## Writing Code with Sub-Agents

Delegate actual code writing to sub-agents to keep the main conversation context lean.

**When to use sub-agents for coding:**

- **Always** for non-trivial code changes (new features, patches, multi-line edits)
- **Skip** for trivial one-liners where spawning overhead outweighs the benefit

**How many sub-agents:**

- **Parallel:** spawn multiple agents when changes are independent (different files, no mutual dependency)
- **Serial:** spawn one at a time when changes depend on each other's output
- **Single:** use one agent for a tightly coupled set of changes that must be consistent

**Token cost trade-off:** Sub-agents are not free — each starts cold and reloads system prompt and memory. The real benefit is keeping the main conversation context lean, which matters most in long or complex sessions. For short one-off tasks, writing code directly in the main context is more economical.

### Task files

Before spawning `code-writer`, create a task file (see `docs/sub-agents.md` — Data Transport for file location and naming). Include enough information that code-writer can complete the task without asking for clarification: goal, relevant file paths, requirements, and any context links.

After the review loop returns `APPROVED`, delete the task file if one was created.

### After writing code

After completing a coding task, the sub-agent **must** write back any knowledge gained:

- **Game engine knowledge** — API usage, gotchas, or constraints discovered during implementation; append to `docs/game-engine-knowledge.md`
- **Mod architecture decisions** — why something was designed a certain way, which Harmony patch pattern was used; update `docs/designs/<mod-name>.md`

Do **not** update changelogs after each coding sub-agent. Changelogs are written once at commit time, based on the final result.

## Code Review

After completing a non-trivial coding task, run a code review loop before committing.

**When to use:**

- After any sub-agent writes new feature code or patches
- Before committing changes that touch multiple files
- Skip for trivial one-liners or config-only changes

### Review loop

Repeat until the reviewer approves:

1. Run `mkdir -p .claude/tmp` then create the findings file: `.claude/tmp/review-<mod-name>-<YYYYMMDD>.md`. Keep this path — it is passed to lessons-collector at the end.
2. Spawn the `code-reviewer` sub-agent with: the list of code file paths + the findings file path. Do not paste file contents — the reviewer reads files itself.
3. The reviewer appends round results to the findings file and returns a verdict (`APPROVED` or `CHANGES REQUIRED`) plus an optional lessons file path. Collect the lessons file path if returned.
4. If `CHANGES REQUIRED`: write a task file at `.claude/tmp/task-<short-description>-<YYYYMMDD>.md` with enough detail for code-writer to fix all issues without asking, then spawn `code-writer` with that task file path. Collect its lessons file path if returned.
5. Repeat from step 2 until the reviewer returns `APPROVED`.
6. Delete the task file if one was created.

Do not commit code that has not received `APPROVED`.

## Collecting Lessons

Both `code-writer` and `code-reviewer` write raw findings to a shared lessons temp file at `.claude/tmp/lessons-<short-description>-<YYYYMMDD>.md` (e.g. `lessons-reload-run-20260417.md`). Each agent appends to the file if it already exists, and returns the file path in its response. The main agent collects only paths that were returned.

After the review loop ends with `APPROVED`, spawn `lessons-collector` to extract and persist reusable lessons:

1. Pass all collected temp file paths — both `lessons-<...>.md` and `review-<...>.md` files.
2. The agent syncs with Gist, merges, appends new lessons to `docs/dev-lessons.md`, and deletes the temp files.
3. It returns `LESSONS SAVED` or `NOTHING NEW`.
4. If the Gist ID is missing, the collector stops and reports — provide the ID and call it again with the same file paths.

Skip this step only if no temp files were produced (trivial task, no sub-agents ran).

## Dev Lessons — Local-Only File

`docs/dev-lessons.md` is **never committed to git** (it's in `.gitignore`). It is maintained locally and backed up to a private GitHub Gist. The Gist ID is stored in `.claude/dev-lessons-gist-id` (also not committed).

All Gist setup, sync, and merge logic is handled by the `lessons-collector` agent. See `.claude/agents/lessons-collector.md` for details.

### Setup on a new machine

1. If you have an existing Gist ID, write it to `.claude/dev-lessons-gist-id`.
2. Spawn lessons-collector — it will fetch `docs/dev-lessons.md` from the Gist automatically.

If no Gist exists yet, create one first:

```bash
gh gist create --secret --filename dev-lessons.md /dev/null
```

Save the returned Gist ID to `.claude/dev-lessons-gist-id`, then run lessons-collector normally.
