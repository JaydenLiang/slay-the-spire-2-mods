using Godot;
using HarmonyLib;
using MegaCrit.Sts2.Core.Helpers;
using MegaCrit.Sts2.Core.Multiplayer.Game;
using MegaCrit.Sts2.Core.Logging;
using MegaCrit.Sts2.Core.Nodes;
using MegaCrit.Sts2.Core.Runs;

namespace reload_run.reload_runCode.Patches;

[HarmonyPatch(typeof(NGame), "_Input")]
public static class InputPatch
{
    [HarmonyPrefix]
    public static void Prefix(InputEvent inputEvent)
    {
        if (inputEvent is not InputEventKey { Pressed: true } key || key.Echo)
            return;

        if (key.Keycode == Key.F5
            && RunManager.Instance?.IsInProgress == true
            && RunManager.Instance?.IsGameOver != true
            && RunManager.Instance?.NetService?.Type != NetGameType.Replay
            && NGame.Instance != null
            && !NGame.Instance.Transition.InTransition)
        {
            TaskHelper.RunSafely(ReloadRunManager.DoReload());
        }

        if (key.Keycode == Key.F6 && RunManager.Instance?.IsInProgress != true)
        {
            SoloMultiplayerPatch.Enabled = !SoloMultiplayerPatch.Enabled;
            Log.Warn($"Solo multiplayer mode: {(SoloMultiplayerPatch.Enabled ? "ON" : "OFF")}");
        }
    }
}
