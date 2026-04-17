# Changelog

<!-- AI: append a new entry after each work session. Do not edit previous entries. -->
<!-- Format: ## YYYY-MM-DD [Stage] — brief summary, then bullet points -->

## 2026-04-16 [PLANNING] — restructure mods directory and document architecture

- Moved mod projects under `mods/` directory
- Fixed `mods/modded-save-sync/modded-save-sync.csproj`: corrected 5 path references from `modded_save_sync` (underscore) to `modded-save-sync` (kebab-case) to match actual directory names
- Added `slay-the-spire-2-mods.code-workspace` for VSCode multi-root workspace
- Filled in `docs/architecture.md`: stack, directory structure, add-new-mod flow (Rider right-click), build configs, MSBuild path resolution, naming conventions, entry point pattern, commands, constraints
