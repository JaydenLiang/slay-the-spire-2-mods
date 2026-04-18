# slay-the-spire-2-mods

[English](README.md) | 简体中文 | [繁體中文](README.zh-TW.md)

由 **Jayden Liang** 开发的 [Slay the Spire 2](https://store.steampowered.com/app/2868840/Slay_the_Spire_2/) mod 合集。

## Mod 列表

| Mod | 版本 | 说明 |
| --- | --- | --- |
| [modded-save-sync](mods/modded-save-sync/README.md) | v1.0.0 | 统一原版与 mod 版存档路径，存档不再分裂成两份 |
| [reload-run](mods/reload-run/README.md) | v1.1.0 | 按 F5 从房间入口存档重新载入当前房间；按 F6 以单人模式开启多人对局 |

## 安装指南

1. 前往本仓库的 [Releases](../../releases) 页面，找到需要的 mod 版本（推荐下载最新版），下载对应的 `<mod名>-<版本号>.zip` 文件并解压。解压后是一个文件夹，内含两到三个文件：`<mod名>.json`、`<mod名>.dll`，以及可选的 `<mod名>.pck`（部分 mod 不含此文件）。
2. 将整个文件夹复制到游戏的 `mods` 目录。在 Steam 中，右键游戏库中的游戏 → **管理** → **浏览本地文件** 即可找到游戏目录。若 `mods` 目录不存在，请手动创建。
3. 启动游戏。首次启用 mod 时会弹出提示，点击确认后游戏会自动重启（属正常现象），之后不会再弹出。
4. 完成！现在可以享受 mod 版游戏了。

## 存档兼容性说明

mod 版与原版（未安装 mod）的存档分别保存在不同目录。首次安装 mod 后，原版存档看起来会"消失"——实际上它们仍然存在，只是路径不同。

根据你的偏好，有以下两种处理方式：

1. **希望 mod 版与原版共用同一套存档** — 安装 [modded-save-sync](mods/modded-save-sync/README.md)，它会让游戏始终读写原版存档路径，彻底解决存档分裂问题。

2. **接受 mod 版与原版存档独立** — ❗ 请**不要**安装 [modded-save-sync](mods/modded-save-sync/README.md)。如需将原版存档迁移到 mod 版目录，请按以下步骤操作：
   1. 启动游戏，进入左上角的存档选择界面（显示 3 个存档槽），停留在此界面。
   2. 打开文件资源管理器（Windows），在地址栏输入 `%APPDATA%\SlayTheSpire2\steam\` 进入存档根目录。
   3. 打开你的账号目录（一串数字，即 Steam ID）。
   4. 确认目录内有 `modded` 文件夹以及 `profile1`、`profile2`、`profile3` 等目录。
   5. 复制 `profile1` 文件夹，粘贴到 `modded` 目录内并全部覆盖（在游戏运行时操作）。
   6. 切换到游戏，切换至存档槽 2，再切回存档槽 1，存档即可正常显示。
   7. `profile2`、`profile3` 如有需要，照此步骤操作即可。

## 免责声明

本合集中的 mod 均为个人兴趣项目，供个人使用，现免费分享。本人已尽力确保 mod 不含任何有害代码。但**使用 mod 风险自负** — 对于因使用本 mod 或任何第三方 mod 而造成的任何问题、数据丢失或其他损失，本人概不负责。
