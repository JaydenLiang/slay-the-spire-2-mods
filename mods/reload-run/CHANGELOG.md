# Changelog — reload-run

## [Unreleased]

- Added F6 toggle for solo multiplayer mode: allows Host to start a new multiplayer run alone without waiting for other players to join (`SoloMultiplayerPatch` on `StartRunLobby.IsAboutToBeginGame`).

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
