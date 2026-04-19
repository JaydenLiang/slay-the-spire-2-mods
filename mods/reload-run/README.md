# reload-run

English | [简体中文](README.zh-CN.md) | [繁體中文](README.zh-TW.md)

A [Slay the Spire 2](https://store.steampowered.com/app/2868840/Slay_the_Spire_2/) mod by **Jayden Liang**.

## Features

### F5 — Reload Current Room

Press **F5** during a run to instantly restart from the beginning of the current room, using the room-entry save state.

- **Singleplayer** — reloads in-place without returning to the main menu
- **Multiplayer Host** — returns to main menu and auto-resumes the saved multiplayer run as Host
- **Multiplayer Client** — returns to main menu and auto-opens the join-friends screen

Backup save detection ensures that if you've already completed a room, F5 still restarts from room entry rather than from after room completion.

### F6 — Solo Multiplayer Toggle

Press **F6** on the main menu to toggle **solo multiplayer mode**, allowing a Host to start a multiplayer run without waiting for other players to join. Useful for testing multiplayer-specific content alone.

## Multiplayer Status

| Feature | Status |
| --- | --- |
| Singleplayer F5 reload | Done, tested |
| F6 solo multiplayer toggle | Done, tested |
| Multiplayer Host F5 reload | Done, tested |
| Multiplayer Client F5 reload | Done, tested |
