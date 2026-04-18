# modded-save-sync — Design

## Mod Goal

Unify the modded and vanilla save directories so all progress is always stored in one place, and automatically keep 10 rolling backups of the full save directory on each game launch.

## Problem Statement

STS2 separates save files into two directories based on whether any mod is loaded:

```text
%APPDATA%\SlayTheSpire2\steam\<STEAM_ID>\
    profile1\          ← vanilla saves
    modded\profile1\   ← modded saves
```

Players who switch between modded and vanilla play lose access to progress from the other mode. Additionally, there is no built-in backup mechanism — a bad patch or crash can silently corrupt or lose save data.

## Approach

Two independent features:

1. **Unified save path** — patch `UserDataPathProvider` so `IsRunningModded` is always `false` and `GetProfileDir` always returns the vanilla path. Modeled after [UnifiedSavePath](https://github.com/luojiesi/SLS2Mods/tree/master/UnifiedSavePath).
2. **Rolling backups** — on each game launch, snapshot the full save root into a numbered backup slot (0–9), cycling back to 0 after 9. Store the index of the last written slot in a metadata file.

## Non-Goals

- No bidirectional sync between directories (unified path makes this unnecessary)
- No per-run mod metadata tracking
- No multi-device / cloud sync beyond what Steam Cloud already does
- No in-game UI

## Requirements

### Must Have

- Patch `UserDataPathProvider.IsRunningModded` getter to always return `false`
- Patch `UserDataPathProvider.IsRunningModded` setter to always set `false`
- Patch `UserDataPathProvider.GetProfileDir` as JIT-inlining safeguard
- On mod initialization, snapshot the full save root directory to a backup slot before the game reads any saves
- 10 backup slots (0–9), written in order, wrapping back to 0 after 9
- Persist the last-written slot index across sessions (metadata file alongside backups)

### Nice to Have

- Log backup activity via BaseLib logger
- Configurable backup count (default 10)

## Key Decisions

| Decision | Chosen | Reason |
| --- | --- | --- |
| Sync strategy | Unified path (patch `IsRunningModded` to always `false`) | Simpler and more robust than bidirectional sync; single source of truth |
| Backup timing | On mod initialization, before game reads saves | Captures state at the safest point |
| Backup rotation | Circular 0–9, index persisted in metadata file | Bounded storage, simple to implement |
| Platform save path | `GetCurrentPlatformSaveLocation()` returns root save dir; `currentPlatformSaveLocation` holds the result | Isolates platform differences; add new platforms inside that function only |
| Directory structure | `profile1/` and `modded/profile1/` layout is platform-agnostic — only the root differs per platform | Sync/backup logic uses relative paths; no platform branching outside `GetCurrentPlatformSaveLocation()` |

### Save paths per platform

| Platform | Save root |
| --- | --- |
| Windows | `%APPDATA%\SlayTheSpire2\steam\<STEAM_ID>\` |
| Linux | `~/.local/share/SlayTheSpire2/steam/<STEAM_ID>\` |
| macOS | `~/Library/Application Support/SlayTheSpire2/steam/<STEAM_ID>\` (unconfirmed) |
| Steam Deck | Proton prefix — same Windows path inside `compatdata/` |

### Backup layout

```text
<save root>\
    profile1\                   ← active saves (unified)
    modded-save-sync\
        last_backup_index.txt   ← integer 0–9, last written slot
        backup_0\               ← full snapshot of save root
        backup_1\
        ...
        backup_9\
```

## Open Questions

- Does the game hold file locks on save files at the point `[ModInitializer]` runs? (verify during coding/testing)

## Next Step

When requirements are finalized, update `.ai-stage` to `CODING` on this branch.
