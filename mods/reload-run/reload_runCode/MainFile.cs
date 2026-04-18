using Alchyr.Logging;
using Godot;
using HarmonyLib;
using MegaCrit.Sts2.Core.Modding;

namespace reload_run.reload_runCode;

[ModInitializer(nameof(Initialize))]
public partial class MainFile : Node
{
    public const string ModId = "reload_run";

    public static Logger Logger = LogManager.GetLogger(ModId);

    public static void Initialize()
    {
        new Harmony(ModId).PatchAll();
    }
}
