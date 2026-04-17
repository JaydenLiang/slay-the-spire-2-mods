# Changelog

<!-- AI: append a new entry after each work session. Do not edit previous entries. -->
<!-- Format: ## YYYY-MM-DD [Stage] — brief summary, then bullet points -->

## 2026-04-17 [CHORE] — add coding guide and AI sub-agent conventions

- Created `docs/coding_guide.md`: rules for using sub-agents to read decompiled source files and write code
- Updated `AI_INSTRUCTIONS.md`: added `docs/coding_guide.md` as always-available reference

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
