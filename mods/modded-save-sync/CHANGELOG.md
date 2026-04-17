# Changelog — modded-save-sync

<!-- AI: append a new entry after each work session. Do not edit previous entries. -->

## 2026-04-17 [CODING] — implement UnifiedSavePath feature

- Added `modded_save_syncCode/Patches/UnifiedSavePathPatch.cs`: three Harmony patches on `UserDataPathProvider` — getter always returns `false`, setter forces value to `false`, `GetProfileDir` returns vanilla `profile{id}` path
- Simplified `MainFile.cs`: removed temporary `TestSaveFileLock` probe; now just calls `PatchAll()` and forces `IsRunningModded = false` at init
