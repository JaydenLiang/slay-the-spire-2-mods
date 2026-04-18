# modded-save-sync

[English](README.md) | 简体中文 | [繁體中文](README.zh-TW.md)

由 **Jayden Liang** 开发的 [Slay the Spire 2](https://store.steampowered.com/app/2868840/Slay_the_Spire_2/) mod。

## 功能

### 统一存档路径

STS2 默认根据是否启用 mod，将存档保存在不同目录：

```text
%APPDATA%\SlayTheSpire2\steam\<STEAM_ID>\
    profile1\          ← 原版存档
    modded\profile1\   ← mod 版存档
```

本 mod 对游戏进行补丁，使其无论是否加载 mod，始终读写原版存档目录，彻底消除存档分裂问题。

### 滚动备份

*（即将推出）* 每次游戏启动时，mod 将自动对完整存档目录进行快照，保存至 10 个轮换备份槽之一，为存档损坏或丢失提供安全保障。

## 致谢

统一存档路径的实现思路来源于 **luojiesi** 的 [UnifiedSavePath](https://github.com/luojiesi/SLS2Mods/tree/master/UnifiedSavePath)，感谢其开源分享！
