using HarmonyLib;
using MegaCrit.Sts2.Core.Helpers;
using MegaCrit.Sts2.Core.Logging;
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

    private static bool _reloadInProgress;

    public static async Task DoReload()
    {
        var runManager = RunManager.Instance;

        if (NGame.Instance == null)
            return;

        var netType = runManager.NetService?.Type;

        if (netType == NetGameType.Singleplayer)
        {
            if (_reloadInProgress)
                return;

            _reloadInProgress = true;

            try
            {
                var saveResult = SaveManager.Instance.LoadRunSave();
                if (!saveResult.Success || saveResult.SaveData == null)
                    return;

                var save = saveResult.SaveData;

                if (save.PreFinishedRoom != null)
                    TryLoadBackupSave(save, out save);

                runManager.ActionQueueSet.Reset();
                NRunMusicController.Instance?.StopMusic();
                await NGame.Instance.Transition.FadeOut();

                try
                {
                    runManager.CleanUp();
                    var runState = RunState.FromSerializable(save);
                    runManager.SetUpSavedSinglePlayer(runState, save);
                    NGame.Instance.ReactionContainer.InitializeNetworking(new NetSingleplayerGameService());
                    await NGame.Instance.LoadRun(runState, null);
                    await NGame.Instance.Transition.FadeIn();
                }
                catch (Exception ex)
                {
                    Log.Warn($"reload-run: failed to reload run after CleanUp, returning to main menu: {ex.Message}");
                    await NGame.Instance.Transition.FadeIn();
                    await NGame.Instance.ReturnToMainMenu();
                }
            }
            finally
            {
                _reloadInProgress = false;
            }
        }
        else if (netType == NetGameType.Host || netType == NetGameType.Client)
        {
            PendingMultiplayerReload = true;
            PendingReloadType = netType.Value;
            await NGame.Instance.ReturnToMainMenu();
        }
    }

    private static bool TryLoadBackupSave(SerializableRun mainSave, out SerializableRun result)
    {
        result = mainSave;
        try
        {
            var runSaveManagerField = AccessTools.Field(typeof(SaveManager), "_runSaveManager");
            if (runSaveManagerField == null)
                return false;

            var runSaveManager = runSaveManagerField.GetValue(SaveManager.Instance);
            if (runSaveManager == null)
                return false;

            var migrationManagerField = AccessTools.Field(runSaveManager.GetType(), "_migrationManager");
            if (migrationManagerField == null)
                return false;

            var migrationManager = migrationManagerField.GetValue(runSaveManager);
            if (migrationManager == null)
                return false;

            var loadSaveMethod = migrationManager.GetType().GetMethod("LoadSave")?.MakeGenericMethod(typeof(SerializableRun));
            if (loadSaveMethod == null)
                return false;

            var currentPathProp = AccessTools.Property(runSaveManager.GetType(), "CurrentRunSavePath");
            if (currentPathProp == null)
                return false;

            var currentPath = currentPathProp.GetValue(runSaveManager) as string;
            if (currentPath == null)
                return false;

            var backupPath = currentPath + ".backup";
            var backupResult = loadSaveMethod.Invoke(migrationManager, new object[] { backupPath });
            if (backupResult == null)
                return false;

            var isSuccessProperty = AccessTools.Property(backupResult.GetType(), "IsSuccess");
            if (isSuccessProperty == null)
            {
                Log.Warn("reload-run: backup save result has no IsSuccess property, using main save");
                return false;
            }

            if (isSuccessProperty.GetValue(backupResult) is not true)
                return false;

            var valueProperty = AccessTools.Property(backupResult.GetType(), "Value");
            if (valueProperty == null)
            {
                Log.Warn("reload-run: backup save result has no Value property, using main save");
                return false;
            }

            var backupValue = valueProperty.GetValue(backupResult) as SerializableRun;
            if (backupValue != null)
                result = backupValue;

            return true;
        }
        catch (Exception ex)
        {
            Log.Warn($"Failed to load backup save, using main save: {ex.Message}");
            return false;
        }
    }
}
