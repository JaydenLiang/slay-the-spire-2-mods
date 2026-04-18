# slay-the-spire-2-mods

English | [简体中文](README.zh-CN.md) | [繁體中文](README.zh-TW.md)

A collection of mods for [Slay the Spire 2](https://store.steampowered.com/app/2868840/Slay_the_Spire_2/) by **Jayden Liang**.

## Mods

| Mod | Version | Description |
| --- | --- | --- |
| [modded-save-sync](mods/modded-save-sync/README.md) | v1.0.0 | Unifies vanilla and modded save paths so progress is never split between two locations |
| [reload-run](mods/reload-run/README.md) | v1.1.0 | Press F5 to reload the current room from its room-entry save state; F6 to start a multiplayer run solo |

## Mod Installation Guide

1. Go to the [Releases](../../releases) page of this repository, find the version you need (latest recommended), and download the `<mod-name>-<version>.zip` file. Extract it — you should see a folder containing two or three files: `<mod-name>.json`, `<mod-name>.dll`, and optionally `<mod-name>.pck` (not all mods include this).
2. Copy the entire extracted folder into your game's `mods` directory. On Steam, right-click the game in your library → **Manage** → **Browse local files** to find the game folder. If the `mods` directory does not exist, create it manually.
3. Launch the game. The first time you run with mods enabled, a prompt will appear — confirm it. The game will restart automatically (this is normal). You won't see this prompt again on subsequent launches.
4. You're all set — enjoy the modded game.

## Save File Compatibility Notice

Modded and vanilla (unmodded) save files are stored in separate directories. A common concern when first installing mods is that your saves appear to have disappeared — they haven't, they're still there under the vanilla path.

There are two approaches depending on your preference:

1. **If you want modded and vanilla runs to share the same save files** — install [modded-save-sync](mods/modded-save-sync/README.md). It redirects the game to always read and write from the vanilla save location.

2. **If you're comfortable keeping modded and vanilla saves separate** — ❗ do **not** install [modded-save-sync](mods/modded-save-sync/README.md). Instead, follow these steps to migrate your existing vanilla saves into the modded directory:
   1. Launch the game and navigate to the save slot selection screen (top-left corner). Stay on this screen.
   2. Open File Explorer (on Windows, not MacOS) and navigate to `%APPDATA%\SlayTheSpire2\steam\` — this is your save root.
   3. Open your account folder (a numeric Steam ID).
   4. Confirm you see a `modded` folder alongside `profile1`, `profile2`, `profile3`, etc.
   5. Copy your `profile1` folder and paste it into the `modded` directory, overwriting everything (do this while the game is still running).
   6. Switch to save slot 2 in-game, then switch back to slot 1. Your save should now appear.
   7. Repeat for `profile2` and `profile3` if needed.

## Disclaimer

These mods are personal projects developed for my own enjoyment and shared freely. I take reasonable care to ensure they contain no harmful code. That said, **use mods at your own risk** — I am not responsible for any issues, data loss, or other consequences arising from the use of these mods or any third-party mods.
