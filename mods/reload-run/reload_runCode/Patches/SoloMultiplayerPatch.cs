using HarmonyLib;
using MegaCrit.Sts2.Core.Multiplayer.Game.Lobby;

namespace reload_run.reload_runCode.Patches;

/// <summary>
/// Allows a multiplayer Host to start a run alone (without waiting for other players).
/// Set <see cref="Enabled"/> to true before embarking, false afterwards.
/// </summary>
[HarmonyPatch(typeof(StartRunLobby), nameof(StartRunLobby.IsAboutToBeginGame))]
public static class SoloMultiplayerPatch
{
    public static bool Enabled { get; set; }

    [HarmonyPostfix]
    public static void Postfix(StartRunLobby __instance, ref bool __result)
    {
        if (!Enabled || __result)
            return;

        var connectingPlayers = AccessTools.Field(typeof(StartRunLobby), "_connectingPlayers")
            ?.GetValue(__instance) as System.Collections.ICollection;
        if (connectingPlayers == null || connectingPlayers.Count > 0)
            return;

        if (__instance.Players.All(p => p.isReady))
            __result = true;
    }
}
