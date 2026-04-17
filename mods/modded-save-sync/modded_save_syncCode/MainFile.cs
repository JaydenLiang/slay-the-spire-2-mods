using Godot;
using HarmonyLib;
using MegaCrit.Sts2.Core.Modding;
using MegaCrit.Sts2.Core.Saves;

namespace modded_save_sync.modded_save_syncCode;

[ModInitializer(nameof(Initialize))]
public partial class MainFile : Node
{
    public const string ModId = "modded_save_sync";

    public static void Initialize()
    {
        new Harmony(ModId).PatchAll();

        // Force the backing field to false in case it was already set before patches applied
        UserDataPathProvider.IsRunningModded = false;
    }
}
