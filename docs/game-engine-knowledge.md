# Game Engine Knowledge — sts2.dll

Decompiled via JetBrains Rider. Namespace root: `MegaCrit.Sts2.Core`.

---

## RunManager

**Namespace:** `MegaCrit.Sts2.Core.Runs`  
**Type:** Singleton (`RunManager.Instance`)

### Properties

| Property | Type | Description |
|---|---|---|
| `Instance` | `RunManager` | Global singleton |
| `IsInProgress` | `bool` | `State != null` — whether a run is active |
| `IsGameOver` | `bool` | Run is active and in game-over state |
| `IsCleaningUp` | `bool` | Currently tearing down a run |
| `IsAbandoned` | `bool` | Run was abandoned by player |
| `IsSinglePlayerOrFakeMultiplayer` | `bool` | `NetService.Type == NetGameType.Singleplayer` |
| `NetService` | `INetGameService` | Active network service; `.Type` gives `NetGameType` |
| `RunLobby` | `RunLobby?` | Non-null only in multiplayer; manages P2P lobby lifecycle |
| `ActionQueueSet` | `ActionQueueSet` | Game action queue; call `.Reset()` before teardown |
| `ShouldSave` | `bool` | Whether the run should be auto-saved |
| `MapDrawingsToLoad` | `SerializableMapDrawings?` | Map drawings pending load after `LoadRun` |
| `SavedMapsToLoad` | `Dictionary<int, SerializableActMap>?` | Act maps pending load after `LoadRun` |

### Run Setup Methods

| Method | Description |
|---|---|
| `SetUpNewSinglePlayer(RunState, bool, DateTimeOffset?)` | Initialize a brand-new singleplayer run |
| `SetUpNewMultiPlayer(RunState, StartRunLobby, bool, DateTimeOffset?)` | Initialize a brand-new multiplayer run; requires live `StartRunLobby` |
| `SetUpSavedSinglePlayer(RunState, SerializableRun)` | Initialize a singleplayer run from save data |
| `SetUpSavedMultiPlayer(RunState, LoadRunLobby)` | Initialize a multiplayer run from save; requires live `LoadRunLobby` with active P2P connection |
| `SetUpReplay(RunState, CombatReplay)` | Initialize a replay |
| `SetUpTest(RunState, INetGameService, bool, bool)` | Initialize a test run |

### Run Lifecycle Methods

| Method | Description |
|---|---|
| `Launch()` | Emit `RunStarted`, set `LocalContext.NetId`, update rich presence — call after `SetUp*` and before `LoadRun` |
| `CleanUp(bool graceful = true)` | Tear down current run: reset queues, dispose synchronizers, disconnect network, null out `State` |
| `Abandon()` | Player-initiated abandon: singleplayer calls `AbandonInternal()`; multiplayer calls `RunLobby.AbandonRun()` |
| `GenerateRooms()` | Generate all act room layouts (called once on new run) |
| `GenerateMap()` | Generate or restore the act map for the current act |
| `LoadIntoLatestMapCoord(AbstractRoom?)` | Re-enter the last visited map coord (used by `LoadRun` flow) |
| `EnterMapCoord(MapCoord)` | Enter a specific map coordinate |
| `EnterNextAct()` | Transition to the next act |
| `FinalizeStartingRelics()` | Apply `AfterObtained` on all starting relics (new runs only) |

### Save / Serialization

| Method | Description |
|---|---|
| `ToSave(AbstractRoom? preFinishedRoom)` | Serialize current run state to `SerializableRun` |
| `CanonicalizeSave(SerializableRun, ulong localPlayerId)` | Re-serialize a save through current `RunState` to normalize it (static) |
| `OnEnded(bool isVictory)` | Finalize run: upload stats, delete save file, update achievements |

### Multiplayer Helpers

| Method | Description |
|---|---|
| `InitializeRunLobby(INetGameService, RunState)` | Create `RunLobby` if multiplayer; create `CombatStateSynchronizer` |
| `GetRejoinMessage()` | Build `ClientRejoinResponseMessage` for a reconnecting client |
| `LocalPlayerDisconnected(NetErrorInfo)` | Handle local player disconnect; triggers `ReturnToMainMenuWithError` |

---

## NetGameType (enum)

**Namespace:** `MegaCrit.Sts2.Core.Multiplayer`

| Value | Description |
|---|---|
| `Singleplayer` | Solo run |
| `Host` | Multiplayer — room host |
| `Client` | Multiplayer — connected client |
| `Replay` | Replay mode |

**Extension:** `NetGameType.IsMultiplayer()` — returns `true` for `Host` and `Client`.

---

## INetGameService

**Namespace:** `MegaCrit.Sts2.Core.Multiplayer.Game`

Interface used by `RunManager.NetService`.

| Property / Method | Description |
|---|---|
| `Type` | `NetGameType` — current game mode |
| `NetId` | `ulong` — local player network id |
| `Platform` | `PlatformType` — Steam, ENet, None, etc. |
| `Disconnect(NetError, bool)` | Disconnect from the session |
| `GetRawLobbyIdentifier()` | String identifier for rich presence |

### Known Implementations

| Class | Description |
|---|---|
| `NetSingleplayerGameService` | Singleplayer — used in `SetUpSavedSinglePlayer` and `OnContinueButtonPressedAsync` |
| `NetHostGameService` | Multiplayer host — created in `NMultiplayerSubmenu.StartHostAsync`; call `StartSteamHost(4)` or `StartENetHost(port, 4)` |
| `NetReplayGameService` | Replay — created in `SetUpReplay` |

---

## NGame

**Namespace:** `MegaCrit.Sts2.Core.Nodes`  
**Type:** Godot Node singleton (`NGame.Instance`)

### Properties

| Property | Type | Description |
|---|---|---|
| `Instance` | `NGame` | Global singleton |
| `MainMenu` | `NMainMenu?` | Current scene cast to `NMainMenu`; `null` if not on main menu |
| `CurrentRunNode` | `NRun?` | Current scene cast to `NRun`; `null` if not in a run |
| `Transition` | `NTransition` | Fade in/out controller |
| `ReactionContainer` | `NReactionContainer` | Networking reaction container; call `InitializeNetworking(INetGameService)` before `LoadRun` |

### Navigation Methods

| Method | Description |
|---|---|
| `ReturnToMainMenu()` | `FadeOut → CleanUp → LoadMainMenu` — universal "back to menu" |
| `ReturnToMainMenuAfterRun()` | Alias for `ReturnToMainMenu()` |
| `GoToTimeline()` | `FadeOut → CleanUp → LoadMainMenu(openTimeline: true)` |
| `GoToTimelineAfterRun()` | Alias for `GoToTimeline()` |
| `ReloadMainMenu()` | Reload main menu scene in-place (only valid when already on main menu) |

### Run Methods

| Method | Description |
|---|---|
| `LoadRun(RunState, SerializableRoom?)` | Load assets → `Launch()` → set scene to `NRun` → `GenerateMap` → `LoadIntoLatestMapCoord`. Shared by singleplayer and multiplayer. |
| `StartNewSingleplayerRun(CharacterModel, bool, acts, modifiers, seed, ascension, dailyTime?)` | Full new singleplayer run setup + `StartRun` |
| `StartNewMultiplayerRun(StartRunLobby, bool, acts, modifiers, seed, ascension, dailyTime?)` | Full new multiplayer run setup + `StartRun` |

### Typical Singleplayer Reload Sequence

```csharp
// 1. Tear down
runManager.ActionQueueSet.Reset();
NRunMusicController.Instance?.StopMusic();
await NGame.Instance.Transition.FadeOut();
runManager.CleanUp();

// 2. Rebuild
var runState = RunState.FromSerializable(save);
runManager.SetUpSavedSinglePlayer(runState, save);
NGame.Instance.ReactionContainer.InitializeNetworking(new NetSingleplayerGameService());

// 3. Load
await NGame.Instance.LoadRun(runState, preFinishedRoom);
await NGame.Instance.Transition.FadeIn();
```

---

## NMainMenu

**Namespace:** `MegaCrit.Sts2.Core.Nodes.Screens.MainMenu`  
**Type:** Godot Control node; current scene when on main menu.

### Properties

| Property | Type | Description |
|---|---|---|
| `SubmenuStack` | `NMainMenuSubmenuStack` | Manages the layered submenu system |
| `ContinueRunInfo` | `NContinueRunInfo` | UI widget showing current save info |

### Key Methods

| Method | Description |
|---|---|
| `Create(bool openTimeline)` | Static factory — instantiate main menu scene |
| `RefreshButtons()` | Read `SaveManager.HasRunSave`; show/hide Continue/Singleplayer/Abandon buttons |
| `OpenMultiplayerSubmenu()` | Push `NMultiplayerSubmenu` onto the submenu stack; returns the submenu instance |
| `OpenSingleplayerSubmenu()` | Push `NSingleplayerSubmenu` onto the submenu stack |

### Continue Button Flow (Singleplayer)

`OnContinueButtonPressed` → `OnContinueButtonPressedAsync`:
```csharp
RunManager.Instance.SetUpSavedSinglePlayer(runState, save);
NGame.Instance.ReactionContainer.InitializeNetworking(new NetSingleplayerGameService());
await NGame.Instance.LoadRun(runState, save.PreFinishedRoom);
```

### `_Ready` Sequence (relevant for patching)

```
_Ready()
  → RefreshButtons()       // reads save, shows correct buttons
  → CheckCommandLineArgs() // fastmp shortcuts
  → Transition.FadeIn(3f)  // fade in
```

---

## NMultiplayerSubmenu

**Namespace:** `MegaCrit.Sts2.Core.Nodes.Multiplayer`  
**Type:** Godot submenu node, pushed by `NMainMenu.OpenMultiplayerSubmenu()`

### Buttons & Visibility

`_Ready` wires up four buttons; `UpdateButtons()` controls visibility:

| Button | Visible when | Action |
|---|---|---|
| Host | No multiplayer save | Open `NMultiplayerHostSubmenu` |
| Load (继续) | Has multiplayer save | `StartLoad()` → `StartHostAsync(save)` |
| Join | Always | `OnJoinFriendsPressed()` → push `NJoinFriendScreen` |
| Abandon | Has multiplayer save | Confirm popup → delete save |

```csharp
// SaveManager.HasMultiplayerRunSave controls Load/Abandon visibility
this._hostButton.Visible = !SaveManager.Instance.HasMultiplayerRunSave;
this._loadButton.Visible = SaveManager.Instance.HasMultiplayerRunSave;
this._abandonButton.Visible = SaveManager.Instance.HasMultiplayerRunSave;
```

### Key Methods

| Method | Visibility | Description |
|---|---|---|
| `StartHost(SerializableRun)` | **public** | Sync wrapper → `TaskHelper.RunSafely(StartHostAsync(run))` |
| `StartHostAsync(SerializableRun)` | **private** | Create `NetHostGameService` → start network → push load screen |
| `StartLoad(NButton)` | **private** | Read multiplayer save → call `StartHost(save)`; safe to invoke via reflection but parameter is ignored (`_`) |
| `FastHost(GameMode)` | **public** | Push `NMultiplayerHostSubmenu` and start host for given mode |
| `OnJoinFriendsPressed()` | **public** | Push `NJoinFriendScreen` onto submenu stack; returns the screen instance |
| `OpenJoinFriendsScreen(NButton)` | **private** | Wrapper → `OnJoinFriendsPressed()` |
| `UpdateButtons()` | **private** | Refresh button visibility based on `SaveManager.HasMultiplayerRunSave` |

### `StartHostAsync` Flow

```csharp
var netService = new NetHostGameService();
await netService.StartSteamHost(4);           // or StartENetHost(33771, 4)
// pushes screen based on run.GameMode:
//   Standard → NMultiplayerLoadGameScreen
//   Daily    → NDailyRunLoadScreen
//   Custom   → NCustomRunLoadScreen
screen.InitializeAsHost(netService, run);
stack.Push(screen);
```

### Patching Notes

- `_Ready` initializes all fields (`_loadingOverlay`, `_loadButton`, etc.) — must await node ready before calling any methods
- `StartHost(SerializableRun)` is the cleanest public entry for "continue as host"
- `OnJoinFriendsPressed()` is the public entry for "join game" (Client reload)
- For Host reload via reflection: prefer `StartHostAsync(SerializableRun)` over `StartLoad(NButton)` to avoid null button parameter issues

### Multiplayer Save Loading

```csharp
// Used by StartLoad and fastmp "load" arg — pass local player's platform ID
var localId = PlatformUtil.GetLocalPlayerId(PlatformUtil.PrimaryPlatform);
SaveManager.Instance.LoadAndCanonicalizeMultiplayerRunSave(localId);
```

---

## NCharacterSelectScreen

**Namespace:** `MegaCrit.Sts2.Core.Nodes.Screens.CharacterSelect`  
**Type:** `NSubmenu` subclass; implements `IStartRunLobbyListener`, `ICharacterSelectButtonDelegate`

Shown when starting a new run. Used for both singleplayer and multiplayer.

### Init Methods

| Method | Description |
| --- | --- |
| `InitializeSingleplayer()` | Creates `StartRunLobby(GameMode.Standard, NetSingleplayerGameService, maxPlayers=1)`, adds local host player, ascension 0 |
| `InitializeMultiplayerAsHost(INetGameService, int maxPlayers)` | Creates `StartRunLobby(GameMode.Standard, ..., maxPlayers)`, adds local host player with unlock state and max ascension |
| `InitializeMultiplayerAsClient(INetGameService, ClientLobbyJoinResponseMessage)` | Creates `StartRunLobby`, calls `InitializeFromMessage` |

### Embark Flow

```text
OnEmbarkPressed
  → checks SeenFtue("accept_tutorials_ftue") — if false, shows tutorial FTUE popup first
  → _lobby.SetReady(true)
  → if (!IsMultiplayer || IsAboutToBeginGame()) return  // solo or all-ready: proceed
  → else show ReadyAndWaiting panel (wait for others)
```

`BeginRun(seed, acts, modifiers)` is called by lobby when all players ready:

- Singleplayer → `StartNewSingleplayerRun`
- Multiplayer → `StartNewMultiplayerRun` → `NGame.StartNewMultiplayerRun(lobby, ...)`

### Solo-Start Blocker

`OnEmbarkPressed` blocks on FTUE check (`SeenFtue("accept_tutorials_ftue")`). If the user hasn't seen this tutorial, a popup appears.

`StartRunLobby.IsAboutToBeginGame()` (line 622) logic:

```csharp
return _connectingPlayers.Count <= 0
    && (!NetService.Type.IsMultiplayer() || Players.Count != 1)
    && Players.All(p => p.isReady);
```

**`Players.Count != 1` deliberately blocks a solo multiplayer host from starting.** To allow solo host start, patch `IsAboutToBeginGame` to remove this condition (guarded by a static flag).

---

## NMultiplayerLoadGameScreen

**Namespace:** `MegaCrit.Sts2.Core.Nodes.Screens.CharacterSelect`  
**Type:** `NSubmenu` subclass; implements `ILoadRunLobbyListener`  
**Scene path:** `res://src/Core/Nodes/Screens/CharacterSelect/NMultiplayerLoadGameScreen.cs`

Shown after Host starts a multiplayer load (`StartHostAsync` → `InitializeAsHost`). Displays save info, remote player slots, and Embark/Unready/Back buttons.

### Methods

| Method | Visibility | Description |
| --- | --- | --- |
| `InitializeAsHost(INetGameService, SerializableRun)` | public | Creates `LoadRunLobby`, adds local host player, calls `AfterMultiplayerStarted()` |
| `InitializeAsClient(INetGameService, ClientLoadJoinResponseMessage)` | public | Creates `LoadRunLobby` for client side |
| `OnEmbarkPressed(NButton)` | private | Calls `_runLobby.SetReady(true)`; if `IsAboutToBeginGame()` returns true, run begins immediately |
| `BeginRun()` | public | Called by lobby when all players ready — stops music and calls `StartRun()` |
| `ShouldAllowRunToBegin()` | public async | Returns `true` if all original players connected; otherwise shows popup asking host to confirm starting with missing players |

### "Solo Start" Flow (skipping player wait)

`ShouldAllowRunToBegin` already supports starting with fewer players — it shows a confirmation popup if `ConnectedPlayerIds.Count < Run.Players.Count`. To skip this popup automatically in mod code, **Harmony-patch `ShouldAllowRunToBegin` to return `true`** (guarded by a flag so it only fires during reload).

To also auto-click Embark after `InitializeAsHost`: call `OnEmbarkPressed(null)` via reflection on the screen instance after one frame delay (screen must be fully ready).

### Embark → BeginRun Sequence

```text
OnEmbarkPressed → _runLobby.SetReady(true) → lobby checks all ready
  → ShouldAllowRunToBegin() → true
  → ILoadRunLobbyListener.BeginRun() → StartRun()
    → SetUpSavedMultiPlayer → NGame.LoadRun
```

---

## SaveManager

**Namespace:** `MegaCrit.Sts2.Core.Saves`  
**Type:** Singleton (`SaveManager.Instance`)

### Relevant Methods

| Method | Description |
|---|---|
| `LoadRunSave()` | Load `current_run.save` → `ReadSaveResult<SerializableRun>` |
| `LoadAndCanonicalizeMultiplayerRunSave(ulong localPlayerId)` | Load multiplayer save and canonicalize for local player |
| `HasRunSave` | `bool` — whether a singleplayer run save exists |
| `DeleteCurrentRun()` | Delete singleplayer run save after run ends |
| `DeleteCurrentMultiplayerRun()` | Delete multiplayer run save after run ends |
| `SaveRun(AbstractRoom?)` | Async — write current run state to disk |
| `GetLatestSchemaVersion<T>()` | Get current schema version for a save type |

### Internal Structure (accessed via reflection in mods)

| Field | Description |
|---|---|
| `_runSaveManager` | Internal manager for run saves |
| `_runSaveManager._migrationManager` | Handles save migration; has `LoadSave<T>(path)` generic method |
| `_runSaveManager._saveStore` | Raw file I/O; has `ReadFile(path)` and `WriteFile(path, content)` |
| `_runSaveManager.CurrentRunSavePath` | Full Godot path to `current_run.save` |

### Backup Save Pattern

The game calls `CopyBackup()` before every write, creating `current_run.save.backup`.  
- Main save = room-entry state (or post-completion state when `PreFinishedRoom != null`)  
- Backup save = previous state before the last write  
- Use `_migrationManager.LoadSave<SerializableRun>(path + ".backup")` to load backup  

---

## RunState / SerializableRun

| Class | Description |
|---|---|
| `RunState` | Live in-memory run state |
| `SerializableRun` | JSON-serializable snapshot of `RunState` |
| `RunState.FromSerializable(SerializableRun)` | Deserialize save into live state |
| `SerializableRun.PreFinishedRoom` | Non-null when save was written after room completion (post-combat, post-Neow) |
| `SerializableRun.Players` | List of `SerializablePlayer` |
| `SerializableRun.GameMode` | `GameMode` enum: `Standard`, `Daily`, `Custom` |

---

## NRunMusicController

**Namespace:** `MegaCrit.Sts2.Core.Nodes.Audio`  
**Type:** Godot singleton

| Method | Description |
|---|---|
| `Instance` | Singleton; may be null outside of a run |
| `StopMusic()` | Stop the current music track — call before run teardown |
| `UpdateTrack()` | Update music for current room |
| `UpdateAmbience()` | Update ambient audio for current room |