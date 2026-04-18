# Changelog

<!-- AI: append a new entry after each work session. Do not edit previous entries. -->
<!-- Format: ## YYYY-MM-DD [Stage] — brief summary, then bullet points -->

## 2026-04-18 [CHORE] — update github workflow merge strategy to no-ff

- Updated `docs/workflows/github.md`: replaced `gh pr merge --squash` with local no-ff merge to preserve full commit history

## 2026-04-17 [CHORE] — rewrite sub-agent docs and coding guide for clarity

- Rewrote `.claude/agents/code-writer.md`, `code-reviewer.md`, `lessons-collector.md`: unified Step N structure, removed conflicting/append-only patches, consistent lessons file convention
- Rewrote `docs/coding-guide.md`: reorganized into linear flow (read → write → review → collect lessons → maintain dev-lessons), moved knowledge write-back rules next to code-writer section
- Rewrote `docs/sub-agents.md`: expanded Typical Workflow diagram to show review loop and CHANGES REQUIRED branch explicitly

## 2026-04-17 [CHORE] — migrate sub-agents to official .claude/agents/ format

- Migrated `code-reviewer` and `lessons-collector` from `docs/sub-agents-prompts/` to `.claude/agents/`
- Added new `code-writer` sub-agent
- Added `docs/sub-agents.md`: agent index, file format reference, typical workflow
- Updated `docs/coding-guide.md`: all agent references point to `.claude/agents/`, added task file convention, lifecycle rules for task/lessons/review temp files
- Updated `.gitignore`: replaced `.claude/` blanket ignore with `.claude/tmp/` and `.claude/dev-lessons-gist-id`

## 2026-04-17 [CODING] — reload-run mod initial implementation

- reload-run has new updates, see details in: mods/reload-run/CHANGELOG.md

## 2026-04-17 [CHORE] — add coding guide and AI sub-agent conventions

- Created `docs/coding-guide.md`: rules for using sub-agents to read decompiled source files and write code
- Updated `AI_INSTRUCTIONS.md`: added `docs/coding-guide.md` as always-available reference
- Updated memory: decompile workflow now includes sub-agent per-file pattern

## 2026-04-17 [CODING] — modded-save-sync UnifiedSavePath implemented

- modded-save-sync has new updates, see details in: mods/modded-save-sync/CHANGELOG.md

## 2026-04-17 [CODING] — modded-save-sync UnifiedSavePath implemented

- modded-save-sync has new updates, see details in: mods/modded-save-sync/CHANGELOG.md

## 2026-04-16 [PLANNING] — update AI instructions and architecture docs

- Added per-mod design document convention to `AI_INSTRUCTIONS.md`: each mod gets `docs/designs/<mod-name>.md`
- Added changelog convention: solution-level CHANGELOG references mod changelogs; detailed changes go in `mods/<mod-name>/CHANGELOG.md`
- Created `docs/designs/modded-save-sync.md` (TBD placeholder)
- Updated `docs/architecture.md`: added Alchyr/ModTemplate framework context, `Alchyr.Sts2.Templates` install flow, three template types, corrected new-mod steps to use `dotnet new` + Rider File → New Solution

## 2026-04-16 [PLANNING] — restructure mods directory and document architecture

- Moved mod projects under `mods/` directory
- Fixed `mods/modded-save-sync/modded-save-sync.csproj`: corrected 5 path references from `modded_save_sync` (underscore) to `modded-save-sync` (kebab-case) to match actual directory names
- Added `slay-the-spire-2-mods.code-workspace` for VSCode multi-root workspace
- Filled in `docs/architecture.md`: stack, directory structure, add-new-mod flow (Rider right-click), build configs, MSBuild path resolution, naming conventions, entry point pattern, commands, constraints
