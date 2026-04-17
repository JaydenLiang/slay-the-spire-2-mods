using Godot;
using HarmonyLib;
using MegaCrit.Sts2.Core.Modding;

namespace modded_save_sync.modded_save_syncCode;

//You're recommended but not required to keep all your code in this package and all your assets in the modded_save_sync folder.
[ModInitializer(nameof(Initialize))]
public partial class MainFile : Node
{
    public const string ModId = "modded_save_sync"; //At the moment, this is used only for the Logger and harmony names.

    public static MegaCrit.Sts2.Core.Logging.Logger Logger { get; } =
        new(ModId, MegaCrit.Sts2.Core.Logging.LogType.Generic);

    public static void Initialize()
    {
        Harmony harmony = new(ModId);

        harmony.PatchAll();
    }
}