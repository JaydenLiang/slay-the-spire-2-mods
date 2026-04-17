# modded-save-sync

A [Slay the Spire 2](https://store.steampowered.com/app/2868840/Slay_the_Spire_2/) mod by **Jayden Liang**.

## Features

### Unified Save Path

STS2 normally stores saves in separate directories depending on whether mods are active:

```
%APPDATA%\SlayTheSpire2\steam\<STEAM_ID>\
    profile1\          ← vanilla saves
    modded\profile1\   ← modded saves
```

This mod patches the game so it always reads and writes to the vanilla save directory, regardless of whether mods are loaded. Your progress is never split between two locations.

### Rolling Backups

*(Coming soon)* On each game launch, the mod snapshots your full save directory into one of 10 rotating backup slots, giving you a safety net against corrupted or lost saves.

## Credits

The unified save path approach was learned from [UnifiedSavePath](https://github.com/luojiesi/SLS2Mods/tree/master/UnifiedSavePath) by **luojiesi**. Thanks for sharing the implementation!
