using HarmonyLib;
using MegaCrit.Sts2.Core.Multiplayer.Game;
using MegaCrit.Sts2.Core.Logging;
using MegaCrit.Sts2.Core.Nodes;
using MegaCrit.Sts2.Core.Nodes.Screens.MainMenu;
using MegaCrit.Sts2.Core.Platform;
using MegaCrit.Sts2.Core.Saves;

namespace reload_run.reload_runCode.Patches;

[HarmonyPatch(typeof(NMainMenu), "_Ready")]
public static class MainMenuPatch
{
    [HarmonyPostfix]
    public static void Postfix()
    {
        if (!ReloadRunManager.PendingMultiplayerReload)
            return;

        ReloadRunManager.PendingMultiplayerReload = false;
        var pendingType = ReloadRunManager.PendingReloadType;
        ReloadRunManager.PendingReloadType = default;

        var submenu = NGame.Instance?.MainMenu?.OpenMultiplayerSubmenu();
        if (submenu == null)
            return;

        if (pendingType == NetGameType.Host)
        {
            var localId = PlatformUtil.GetLocalPlayerId(PlatformUtil.PrimaryPlatform);
            var save = SaveManager.Instance.LoadAndCanonicalizeMultiplayerRunSave(localId);
            if (save.SaveData == null)
            {
                Log.Warn("reload-run: multiplayer save not found, cannot resume as host");
                return;
            }

            submenu.StartHost(save.SaveData);
        }
        else if (pendingType == NetGameType.Client)
        {
            submenu.OnJoinFriendsPressed();
        }
    }
}
