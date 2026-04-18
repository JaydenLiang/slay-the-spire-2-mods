# modded-save-sync

[English](README.md) | [简体中文](README.zh-CN.md) | 繁體中文

由 **Jayden Liang** 開發的 [Slay the Spire 2](https://store.steampowered.com/app/2868840/Slay_the_Spire_2/) Mod。

## 功能

### 統一存檔路徑

STS2 預設根據是否啟用 Mod，將存檔儲存在不同目錄：

```text
%APPDATA%\SlayTheSpire2\steam\<STEAM_ID>\
    profile1\          ← 原版存檔
    modded\profile1\   ← Mod 版存檔
```

本 Mod 對遊戲進行修補，使其無論是否載入 Mod，始終讀寫原版存檔目錄，徹底消除存檔分裂問題。

### 滾動備份

*（即將推出）* 每次遊戲啟動時，Mod 將自動對完整存檔目錄進行快照，儲存至 10 個輪換備份槽之一，為存檔損毀或遺失提供安全保障。

## 致謝

統一存檔路徑的實作思路來源於 **luojiesi** 的 [UnifiedSavePath](https://github.com/luojiesi/SLS2Mods/tree/master/UnifiedSavePath)，感謝其開源分享！
