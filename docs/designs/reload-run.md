# Design — reload-run

## Goal

Press F5 during a run to instantly reload the current room from its room-entry save state. Supports singleplayer and multiplayer (Host/Client). Also provides F6 to start a multiplayer run solo (for testing).

## Requirements

- F5 during singleplayer run → reload current room without returning to main menu
- F5 during multiplayer Host run → return to main menu → auto-resume saved multiplayer run as Host
- F5 during multiplayer Client run → return to main menu → auto-open join screen
- F5 during Replay → do nothing
- F6 on main menu → toggle solo multiplayer mode (Host can start a run without waiting for other players)

## Key Design Decisions

### Singleplayer reload (direct, no menu)
Mirror `NMainMenu.OnContinueButtonPressedAsync` flow: teardown → load save → `SetUpSavedSinglePlayer` → `LoadRun`. Done in-place without returning to the main menu.

### Backup save detection
The game overwrites `current_run.save` on room completion (post-combat, Neow, etc.). When `PreFinishedRoom != null`, load `.backup` instead so F5 restarts from room entry, not after room completion. Then copy backup → main save so subsequent F5s still work.

### Multiplayer reload (via main menu)
Host/Client cannot reload in-place — multiplayer requires a live network session. Strategy: `ReturnToMainMenu()` → set `PendingMultiplayerReload` flag → patch `NMainMenu._Ready` postfix → auto-trigger Host resume or Client join.

- Host: calls `NMultiplayerSubmenu.StartHost(SerializableRun)` after loading multiplayer save
- Client: calls `NMultiplayerSubmenu.OnJoinFriendsPressed()`

### Solo multiplayer (F6)
`StartRunLobby.IsAboutToBeginGame()` blocks solo host with `Players.Count != 1`. Patch this method to remove the restriction when `SoloMultiplayerPatch.Enabled = true`. Toggled via F6 on main menu.

## Implementation Files

| File | Purpose |
| --- | --- |
| `reload_runCode/MainFile.cs` | Mod entry point, Harmony patch bootstrap |
| `reload_runCode/ReloadRunManager.cs` | Core reload logic (singleplayer path + backup handling) |
| `reload_runCode/Patches/InputPatch.cs` | F5/F6 key detection via `NGame._Input` postfix |
| `reload_runCode/Patches/MainMenuPatch.cs` | `NMainMenu._Ready` postfix — triggers multiplayer reload |
| `reload_runCode/Patches/SoloMultiplayerPatch.cs` | `StartRunLobby.IsAboutToBeginGame` postfix — solo host |

## Status

| Feature | Status |
| --- | --- |
| Singleplayer F5 reload | Done, tested |
| F6 solo multiplayer toggle | Done, tested |
| Multiplayer Host F5 reload | Done, **untested** |
| Multiplayer Client F5 reload | Done, **untested** |

## Remaining Tasks

1. Test multiplayer Host F5: start a run with F6, enter a room, press F5 — verify room reloads correctly
2. Test multiplayer Client F5: join a friend's game, press F5 — verify join screen opens
3. Fix any bugs found during testing
4. Bump version and cut release
