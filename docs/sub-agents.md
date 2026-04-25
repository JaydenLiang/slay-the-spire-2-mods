# Sub-Agents

All sub-agents live in `.claude/agents/` as Markdown files with YAML frontmatter. The frontmatter configures the agent; the Markdown body is its system prompt.

## Agent Index

| Agent | File | Model | Tools | Purpose |
| --- | --- | --- | --- | --- |
| `code-writer` | `.claude/agents/code-writer.md` | sonnet | Read, Write, Edit, Glob, Grep, Bash | Implements code changes and new features |
| `code-reviewer` | `.claude/agents/code-reviewer.md` | sonnet | Read, Glob, Grep, Write | Reviews code for bugs and over-engineering |
| `lessons-collector` | `.claude/agents/lessons-collector.md` | sonnet | Read, Write, Bash | Extracts reusable lessons, merges with Gist remote, syncs back to Gist |
| `mod-release-notes-writer` | `.claude/agents/mod-release-notes-writer.md` | sonnet | Read, Glob, Grep, Bash | Distills commit logs into user-friendly release notes |
| `release-publisher` | `.claude/agents/release-publisher.md` | sonnet | Read, Write, Bash | Executes mechanical release steps: tag, build, upload, update notes |

## Agent File Format

```markdown
---
name: agent-name           # lowercase, hyphens only; matches filename
description: ...           # when Claude should delegate to this agent
tools: Read, Write, Bash   # comma-separated allowlist; omit to inherit all
model: sonnet              # sonnet | opus | haiku | inherit
---

System prompt goes here.
```

## Invocation

**Natural language** — Claude decides automatically:

```text
Use the code-reviewer agent to review my changes
```

**@-mention** — guaranteed invocation:

```text
@"code-reviewer (agent)" review MainFile.cs
```

## Data Transport — Files, Not Prompts

Before invoking any sub-agent, main agent writes a task file to `.claude/tmp/` containing all data the agent needs. The prompt tells the agent only where to find the file — nothing else.

Always run `mkdir -p .claude/tmp` before writing any input file.

**Never** embed task data (versions, notes, file lists, config values) directly in the prompt string — it bypasses the agent's own input format and produces unreliable results.

The table below defines the mandatory file naming convention for each agent. Main agent must use these exact patterns — do not invent alternative names.

| Agent | Input file | Prompt contains |
| --- | --- | --- |
| `code-writer` | `.claude/tmp/task-<description>-<YYYYMMDD>.md` | task file path |
| `code-reviewer` | `.claude/tmp/review-<mod>-<YYYYMMDD>.md` (findings) | code file paths + findings file path |
| `release-publisher` | `.claude/tmp/release-<mod>-<version>.json` (manifest) | `phase: execute, manifest: <path>` |
| `mod-release-notes-writer` | commits passed inline | notes output path |
| `lessons-collector` | `.claude/tmp/lessons-*.md` + `review-*.md` | all temp file paths |

If an agent defines a specific invocation format (e.g. `phase: execute, manifest: <path>`), use it exactly — do not paraphrase or add extra instructions in the prompt.

## Typical Workflow — Coding

The main agent orchestrates a write → review loop, then collects lessons:

```text
code-writer       →  reads task file, writes or edits code
                     writes impl lessons (if any) to:
                       .claude/tmp/lessons-<short-description>-<YYYYMMDD>.md

── review loop (repeats until APPROVED) ──────────────────────────────────────

code-reviewer     →  reviews code files + reads findings file
                     appends round results to:
                       .claude/tmp/review-<mod-name>-<YYYYMMDD>.md
                     appends review lessons (if any) to:
                       .claude/tmp/lessons-<short-description>-<YYYYMMDD>.md
                     returns: APPROVED or CHANGES REQUIRED

  if CHANGES REQUIRED:
main agent        →  writes a new task file with fixes needed
code-writer       →  fixes issues, appends impl lessons (if any)
                     (loop repeats from code-reviewer)

── after APPROVED ────────────────────────────────────────────────────────────

main agent        →  deletes task file

lessons-collector →  receives all temp file paths (lessons + review files)
                     syncs with Gist, merges, appends new lessons to:
                       docs/dev-lessons.md
                     uploads to Gist, deletes temp files
```

## Typical Workflow — Release

The main agent orchestrates analysis, confirmation, and publishing:

```text
── phase 1: analyze ──────────────────────────────────────────────────────────

release-publisher →  invoked with: phase: analyze, mods: [<mod>, ...]
                     collects commits, infers bump, reads game version
                     invokes mod-release-notes-writer, saves notes to:
                       .claude/tmp/release-notes-<mod>-<version>.md
                     writes analysis to:
                       .claude/tmp/release-analysis-<mod>.json
                     returns summary for each mod

── user confirmation ─────────────────────────────────────────────────────────

main agent        →  presents summary + notes preview to user
                     waits for explicit confirmation before proceeding

── phase 2: execute (per mod, after confirmation) ────────────────────────────

main agent        →  updates mods/<mod>/<mod>.json (version, build_on_game_version)
                     updates README.md, README.zh-CN.md, README.zh-TW.md
                     updates mods/<mod>/CHANGELOG.md
                     commits version bump
                     writes release manifest (see Data Transport above)

release-publisher →  invoked with: phase: execute, manifest: .claude/tmp/release-<mod>-<version>.json
                     creates and pushes tag
                     builds and packages mod (scripts/release.ps1)
                     updates GitHub release notes (What's New + Release Info + Installation)
                     verifies release (isDraft=false, isPrerelease=false, assets non-empty, body non-empty)
                     reports success or failure
```

## Adding a New Agent

1. Create `.claude/agents/<agent-name>.md` with frontmatter + system prompt.
2. Add a row to the Agent Index table above.
3. Copy the file to your boilerplate repo if it belongs there.
