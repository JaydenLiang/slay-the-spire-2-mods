# AI Instructions — AI Router

## Current Stage

Read `.ai-stage` for the current stage value.

## Stage → Document Map

| Stage | Read This File | Purpose |
| --- | --- | --- |
| PLANNING | `docs/designs/<mod-name>.md` | Goals, requirements, decisions for that mod |
| CODING | `docs/architecture.md` | Structure, conventions, commands |
| TESTING | `docs/testing.md` | Test strategy, commands, coverage rules |
| DEPLOY | `docs/deployment.md` | Env vars, deploy steps, rollback |

### Mod Design Documents

- Each mod has its own design file at `docs/designs/<mod-name>.md`
- `<mod-name>` matches the mod's directory name under `mods/` (kebab-case)
- When in PLANNING stage, read `docs/designs/<mod-name>.md` for the mod currently being worked on
- Create the file if it does not exist yet

## Always-Available

- `CHANGELOG.md` — solution-level changelog; only major/cross-cutting changes go here
- `mods/<mod-name>/CHANGELOG.md` — per-mod changelog; all mod-specific changes go here
- `docs/coding-guide.md` — coding conventions and AI behavior rules; always follow these
- `docs/dev-lessons.md` — hard-won build/toolchain/API lessons; check before starting new work
- `docs/sub-agents.md` — sub-agent rules and workflows; **read this before invoking any sub-agent**

### Changelog Convention

- **Solution-level** `CHANGELOG.md`: record only broad changes (new mod added, solution restructure, shared tooling updates). For mod work, add a single reference line, e.g.:
  - `- modded-save-sync has new updates, see details in: mods/modded-save-sync/CHANGELOG.md`
- **Per-mod** `mods/<mod-name>/CHANGELOG.md`: record all detailed mod changes here.

## Workflow

`.ai-workflow` lists the active workflows for this project, one per line. Each entry maps to `docs/workflows/<name>.md`.

Example `.ai-workflow`:

```text
github
npm-publish
```

**If `.ai-workflow` is missing or every line is `unknown`:**

- Ask the user: *"Which workflows does this project use? (e.g. github, npm-publish, gitlab)"*
- Write the answers to `.ai-workflow`, one per line
- Do not proceed with any code management action until this is resolved

**When to read workflow files:**

- Do NOT read workflow files on session start or during normal coding
- ONLY read when you are about to perform a code management action
- Read only the workflow(s) relevant to the current action:

| Action | Read this workflow |
| --- | --- |
| commit / push / PR / branch | the VCS workflow (e.g. `github`, `gitlab`) |
| publish to a package registry | the publish workflow (e.g. `npm-publish`) |
| release (tag + publish) | both VCS and publish workflows |

If multiple workflows apply to the current action, read all of them.

## Instructions

1. Read ONLY the file for the current stage above.
2. Do not read other stage files unless explicitly asked.
3. After completing work, append a summary to `CHANGELOG.md`.
4. When the stage changes, update `.ai-stage` on the current branch.
5. Before any code management action:
   a. Update `CHANGELOG.md` first — include it in the same commit.
   b. Check `.ai-workflow`, read the relevant `docs/workflows/*.md`, and follow it exactly.
6. Before invoking any sub-agent, read `docs/sub-agents.md` and follow the rules there exactly.

## First-Time Setup (AI tools other than Claude Code)

If your tool uses a dedicated instructions file (e.g. `.cursorrules` for Cursor,
`.github/copilot-instructions.md` for Copilot, `.windsurfrules` for Windsurf),
add the following line to that file so it points here:

```text
@AI_INSTRUCTIONS.md
```

or if `@import` is not supported, add:

```text
See AI_INSTRUCTIONS.md for all instructions.
```
