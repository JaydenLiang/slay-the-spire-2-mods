using HarmonyLib;
using MegaCrit.Sts2.Core.Saves;

namespace modded_save_sync.modded_save_syncCode.Patches;

[HarmonyPatch(typeof(UserDataPathProvider), "get_IsRunningModded")]
internal static class PatchGetIsRunningModded
{
    [HarmonyPrefix]
    static bool Prefix(ref bool __result)
    {
        __result = false;
        return false;
    }
}

[HarmonyPatch(typeof(UserDataPathProvider), "set_IsRunningModded")]
internal static class PatchSetIsRunningModded
{
    [HarmonyPrefix]
    static bool Prefix(ref bool value)
    {
        value = false;
        return true;
    }
}

[HarmonyPatch(typeof(UserDataPathProvider), "GetProfileDir")]
internal static class PatchGetProfileDir
{
    [HarmonyPrefix]
    static bool Prefix(int profileId, ref string __result)
    {
        __result = $"profile{profileId}";
        return false;
    }
}