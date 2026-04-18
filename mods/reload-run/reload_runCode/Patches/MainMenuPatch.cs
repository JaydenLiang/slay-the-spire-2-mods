using HarmonyLib;
using MegaCrit.Sts2.Core.Multiplayer;
using MegaCrit.Sts2.Core.Nodes;
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

        var submenu = NGame.Instance.MainMenu?.OpenMultiplayerSubmenu();
        if (submenu == null)
            return;

        if (ReloadRunManager.PendingReloadType == NetGameType.Host)
        {
            var localId = PlatformUtil.GetLocalPlayerId(PlatformUtil.PrimaryPlatform);
            var save = SaveManager.Instance.LoadAndCanonicalizeMultiplayerRunSave(localId);
            if (save == null)
                return;

            submenu.StartHost(save);
        }
        else if (ReloadRunManager.PendingReloadType == NetGameType.Client)
        {
            submenu.OnJoinFriendsPressed();
        }
    }
}
