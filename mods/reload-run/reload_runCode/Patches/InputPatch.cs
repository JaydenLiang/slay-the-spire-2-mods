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

        if (key.Keycode == Key.F5)
        {
            var isInProgress = RunManager.Instance?.IsInProgress;
            var isGameOver = RunManager.Instance?.IsGameOver;
            var netType = RunManager.Instance?.NetService?.Type;
            var inTransition = NGame.Instance?.Transition.InTransition;
            Log.Warn($"[reload-run] F5 pressed — IsInProgress={isInProgress}, IsGameOver={isGameOver}, NetType={netType}, InTransition={inTransition}, NGame={NGame.Instance != null}");

            if (isInProgress == true
                && isGameOver != true
                && netType != NetGameType.Replay
                && NGame.Instance != null
                && inTransition != true)
            {
                TaskHelper.RunSafely(ReloadRunManager.DoReload());
            }
        }

        if (key.Keycode == Key.F6)
        {
            var isInProgress = RunManager.Instance?.IsInProgress;
            Log.Warn($"[reload-run] F6 pressed — IsInProgress={isInProgress}");
            if (isInProgress != true)
            {
                SoloMultiplayerPatch.Enabled = !SoloMultiplayerPatch.Enabled;
                Log.Warn($"[reload-run] Solo multiplayer mode: {(SoloMultiplayerPatch.Enabled ? "ON" : "OFF")}");
            }
        }
    }
}
