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

### Task files

The main agent creates a task file before spawning `code-writer`:

- **Location:** `.claude/tmp/`
- **Naming:** `task-<short-description>-<YYYYMMDD>.md` e.g. `task-reload-run-fix-20260417.md`
- **Responsibility:** the main agent must include enough information that code-writer can complete the task without asking for clarification — goal, relevant file paths, requirements, and any context links

The main agent deletes the task file after the review loop returns `APPROVED`.

### After writing code

After completing a coding task, the sub-agent **must** write back any knowledge gained:

1. **Game engine knowledge** — any API usage, gotchas, or constraints discovered during implementation; append to `docs/game-engine-knowledge.md`
2. **Mod architecture decisions** — why something was designed a certain way, which Harmony patch pattern was used, etc.; update `docs/designs/<mod-name>.md`

**Do NOT update changelogs** after each coding sub-agent. Changelogs are written once at commit time, based on the final result — not intermediate steps.

## Code Review Sub-Agent

After completing a non-trivial coding task, spawn a code review sub-agent to catch bugs and over-engineering before committing.

### How to invoke

Use the `code-reviewer` sub-agent (`.claude/agents/code-reviewer.md`). Pass:

- The list of **code file paths** to review
- The **findings file path** — `.claude/tmp/review-<mod-name>-<YYYYMMDD>.md` (same file reused across all rounds)

The reviewer reads the files itself. Do not paste file contents into the prompt.

### When to use

- After any sub-agent writes new feature code or patches
- Before committing a set of changes that touch multiple files
- Skip for trivial one-liners or config-only changes

### Review loop

Code review is a **multi-round loop** — repeat until the reviewer approves:

1. Create the review findings file: `.claude/tmp/review-<mod-name>-<YYYYMMDD>.md`
2. Use the `code-reviewer` sub-agent with: code file paths + review findings file path
3. Reviewer appends round results to review findings file, appends lessons to `lessons-<short-description>-<YYYYMMDD>.md`, returns verdict + lessons file path
4. If `CHANGES REQUIRED`: create `.claude/tmp/task-<short-description>-<YYYYMMDD>.md` with sufficient information for code-writer to fix all issues without asking, then use the `code-writer` sub-agent with the task file path
5. Repeat from step 2 until reviewer returns `APPROVED`
6. Delete the task file

The main agent only passes file paths each round — never file contents.

Do not commit code that has not received `APPROVED`.

## Lessons Collection

After the review loop ends with `APPROVED`, spawn a lessons-collector agent to extract reusable lessons from the session.

### How sub-agents report findings

Both `code-writer` and `code-reviewer` agents write raw findings to a lessons temp file:

- `code-writer` — lessons from implementation (unexpected API behavior, gotchas, constraints)
- `code-reviewer` — lessons from review (patterns that cause bugs or over-engineering)

**Location:** `.claude/tmp/`
**Naming:** `lessons-<short-description>-<YYYYMMDD>.md` e.g. `lessons-reload-run-20260417.md`
**Content:** raw bullet points — what went wrong, what was surprising, what the fix was
**Rule:** append to the file if it already exists; do not overwrite

Each agent returns the lessons file path in its response so the main agent can collect it.

### How to invoke the lessons-collector

Once the review loop is `APPROVED`, pass all collected temporary file paths to the lessons-collector:

1. Use the `lessons-collector` sub-agent (`.claude/agents/lessons-collector.md`)
2. Pass all collected temp file paths — both `lessons-<...>.md` and `review-<...>.md` files
3. The agent reads the files, writes new lessons to `docs/dev-lessons.md`, deletes the temp files
4. It returns `LESSONS SAVED` or `NOTHING NEW`

### When to skip

- Skip if no temp files were produced (trivial task, no findings)
- Skip if the only findings are already in `docs/dev-lessons.md`

## Dev Lessons — Local-Only File

`docs/dev-lessons.md` is **never committed to git** (it's in `.gitignore`). It is maintained locally and backed up to a private GitHub Gist.

### Gist setup

The Gist ID is stored in `.claude/dev-lessons-gist-id` (also not committed).

**Before writing to `docs/dev-lessons.md` for the first time in a session**, check if `.claude/dev-lessons-gist-id` exists:

- **File exists:** use the ID inside for all Gist sync operations
- **File missing:** ask the user — *"Do you have an existing Gist ID for dev-lessons? If not, I'll create one."*
  - If user provides an ID: write it to `.claude/dev-lessons-gist-id`
  - If user says no: run `gh gist create --secret docs/dev-lessons.md`, capture the Gist ID from the output, write it to `.claude/dev-lessons-gist-id`

### Syncing after each update

After lessons-collector writes new lessons to `docs/dev-lessons.md`, sync to Gist:

```bash
gh gist edit $(cat .claude/dev-lessons-gist-id) docs/dev-lessons.md
```

### Restoring on a new machine

If `docs/dev-lessons.md` is missing but `.claude/dev-lessons-gist-id` exists:

```bash
gh gist view $(cat .claude/dev-lessons-gist-id) --raw > docs/dev-lessons.md
```
