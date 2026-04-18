using HarmonyLib;
using MegaCrit.Sts2.Core.Helpers;
using MegaCrit.Sts2.Core.Multiplayer;
using MegaCrit.Sts2.Core.Multiplayer.Game;
using MegaCrit.Sts2.Core.Nodes;
using MegaCrit.Sts2.Core.Nodes.Audio;
using MegaCrit.Sts2.Core.Runs;
using MegaCrit.Sts2.Core.Saves;

namespace reload_run.reload_runCode;

public static class ReloadRunManager
{
    public static bool PendingMultiplayerReload { get; set; }
    public static NetGameType PendingReloadType { get; set; }

    public static async Task DoReload()
    {
        var runManager = RunManager.Instance;
        if (runManager == null)
            return;

        var netType = runManager.NetService?.Type;

        if (netType == NetGameType.Singleplayer)
        {
            var saveResult = SaveManager.Instance.LoadRunSave();
            if (!saveResult.IsSuccess)
                return;

            var save = saveResult.Value;

            if (save.PreFinishedRoom != null)
            {
                try
                {
                    var runSaveManager = AccessTools.Field(typeof(SaveManager), "_runSaveManager").GetValue(SaveManager.Instance);
                    var migrationManager = AccessTools.Field(runSaveManager.GetType(), "_migrationManager").GetValue(runSaveManager);
                    var loadSaveMethod = migrationManager.GetType().GetMethod("LoadSave")!.MakeGenericMethod(typeof(SerializableRun));
                    var currentPath = (string)AccessTools.Property(runSaveManager.GetType(), "CurrentRunSavePath").GetValue(runSaveManager)!;
                    var backupPath = currentPath + ".backup";
                    var backupResult = loadSaveMethod.Invoke(migrationManager, new object[] { backupPath });
                    var backupValue = backupResult?.GetType().GetProperty("Value")?.GetValue(backupResult) as SerializableRun;
                    if (backupValue != null)
                        save = backupValue;
                }
                catch (Exception ex)
                {
                    MainFile.Logger.Info($"Failed to load backup save, using main save: {ex.Message}");
                }
            }

            runManager.ActionQueueSet.Reset();
            NRunMusicController.Instance?.StopMusic();
            await NGame.Instance.Transition.FadeOut();
            runManager.CleanUp();

            var runState = RunState.FromSerializable(save);
            runManager.SetUpSavedSinglePlayer(runState, save);
            NGame.Instance.ReactionContainer.InitializeNetworking(new NetSingleplayerGameService());
            await NGame.Instance.LoadRun(runState, null);
            await NGame.Instance.Transition.FadeIn();
        }
        else if (netType == NetGameType.Host || netType == NetGameType.Client)
        {
            PendingMultiplayerReload = true;
            PendingReloadType = netType.Value;
            await NGame.Instance.ReturnToMainMenu();
        }
    }
}
