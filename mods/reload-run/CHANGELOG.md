# Changelog — reload-run

## [Unreleased]

- Added F6 toggle for solo multiplayer mode: allows Host to start a new multiplayer run alone without waiting for other players to join (`SoloMultiplayerPatch` on `StartRunLobby.IsAboutToBeginGame`).
- Fixed: `_reloadInProgress` guard to prevent re-entrant F5 presses during an in-flight reload.
- Fixed: FadeIn now runs on the error path in `DoReload` so the screen is never left faded out.
- Fixed: `CleanUp()` now runs inside the try block so partial teardown is followed by `ReturnToMainMenu` on failure.
- Fixed: `ReadSaveResult` API corrected to `.Success` / `.SaveData` (not `.IsSuccess` / `.Value`).
- Fixed: reflection null checks added for `_runSaveManager`, `_migrationManager`, and `CurrentRunSavePath` in `TryLoadBackupSave`.
- Fixed: `PendingReloadType` reset before dispatch in `MainMenuPatch` so it is cleared on all paths.
- Fixed: null guard on `NGame.Instance?.MainMenu` in `MainMenuPatch` before calling `OpenMultiplayerSubmenu`.

## v1.1.0

- Added multiplayer branch: Host F5 → returns to main menu → auto-opens multiplayer submenu → resumes saved run as host.
- Added multiplayer branch: Client F5 → returns to main menu → auto-opens multiplayer submenu → opens join game screen.
- Replay mode: F5 now does nothing (blocked in InputPatch).
- Fixed Logger/LogType namespace to `MegaCrit.Sts2.Core.Logging`.
- Fixed NetGameType namespace to `MegaCrit.Sts2.Core.Multiplayer.Game`.

## v1.0.0

- Initial release: press F5 during a run to instantly reload the current room from its entry save state, without returning to the main menu.
- Supports backup-save detection (post-combat / Neow selection) to correctly restart from room entry.
- Preserves ? room type across reloads to prevent RNG re-roll.
- Restores enemy positions and map marker after reload.
