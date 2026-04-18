# slay-the-spire-2-mods

[English](README.md) | [简体中文](README.zh-CN.md) | 繁體中文

由 **Jayden Liang** 開發的 [Slay the Spire 2](https://store.steampowered.com/app/2868840/Slay_the_Spire_2/) Mod 合集。

## Mod 清單

| Mod | 版本 | 說明 |
| --- | --- | --- |
| [modded-save-sync](mods/modded-save-sync/README.md) | v1.1.0 | 統一原版與 Mod 版存檔路徑，存檔不再分裂成兩份 |
| [reload-run](mods/reload-run/README.md) | v1.1.0 | 按 F5 從房間入口存檔重新載入當前房間；按 F6 以單人模式開啟多人對戰 |

## 安裝指南

1. 前往本儲存庫的 [Releases](../../releases) 頁面，找到需要的 Mod 版本（建議下載最新版），下載對應的 `<mod名>-<版本號>.zip` 檔案並解壓縮。解壓縮後是一個資料夾，內含兩到三個檔案：`<mod名>.json`、`<mod名>.dll`，以及可選的 `<mod名>.pck`（部分 Mod 不含此檔案）。
2. 將整個資料夾複製到遊戲的 `mods` 目錄。在 Steam 中，右鍵遊戲庫裡的遊戲 → **管理** → **瀏覽本機檔案** 即可找到遊戲目錄。若 `mods` 目錄不存在，請手動建立。
3. 啟動遊戲。首次啟用 Mod 時會出現提示，點擊確認後遊戲會自動重新啟動（屬正常現象），之後不會再出現。
4. 完成！現在可以享受 Mod 版遊戲了。

## 存檔相容性說明

Mod 版與原版（未安裝 Mod）的存檔分別儲存在不同目錄。首次安裝 Mod 後，原版存檔看起來會「消失」——實際上它們仍然存在，只是路徑不同。

根據你的偏好，有以下兩種處理方式：

1. **希望 Mod 版與原版共用同一套存檔** — 安裝 [modded-save-sync](mods/modded-save-sync/README.md)，它會讓遊戲始終讀寫原版存檔路徑，徹底解決存檔分裂問題。

2. **接受 Mod 版與原版存檔各自獨立** — ❗ 請**不要**安裝 [modded-save-sync](mods/modded-save-sync/README.md)。如需將原版存檔遷移至 Mod 版目錄，請按以下步驟操作：
   1. 啟動遊戲，進入左上角的存檔選擇介面（顯示 3 個存檔槽），停留在此介面。
   2. 開啟檔案總管（Windows），在網址列輸入 `%APPDATA%\SlayTheSpire2\steam\` 進入存檔根目錄。
   3. 開啟你的帳號資料夾（一串數字，即 Steam ID）。
   4. 確認目錄內有 `modded` 資料夾以及 `profile1`、`profile2`、`profile3` 等目錄。
   5. 複製 `profile1` 資料夾，貼上到 `modded` 目錄內並全部覆蓋（在遊戲執行時操作）。
   6. 切換至遊戲，切換至存檔槽 2，再切回存檔槽 1，存檔即可正常顯示。
   7. `profile2`、`profile3` 如有需要，照此步驟操作即可。

## 免責聲明

本合集中的 Mod 均為個人興趣專案，供個人使用，現免費分享。本人已盡力確保 Mod 不含任何有害程式碼。但**使用 Mod 風險自負** — 對於因使用本 Mod 或任何第三方 Mod 而造成的任何問題、資料遺失或其他損失，本人概不負責。
