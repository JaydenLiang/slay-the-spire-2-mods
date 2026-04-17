# Architecture

## Stack

- **Language:** C# (net9.0) + GDScript/scenes (Godot assets)
- **Runtime:** Godot 4.5.1 mono (MegaDot fork used by STS2)
- **Mod framework:** Alchyr.Sts2.BaseLib, HarmonyX (runtime patching), Krafs.Publicizer
- **Build system:** MSBuild via `Godot.NET.Sdk`
- **IDE:** JetBrains Rider (`.sln`) + VSCode (`.code-workspace`)

## Directory Structure

```text
/
├── slay-the-spire-2-mods.sln            # VS solution — one project entry per mod
├── slay-the-spire-2-mods.code-workspace # VSCode workspace — one folder entry per mod
├── mods/
│   └── <mod-name>/                      # One directory per mod (self-contained Godot project)
│       ├── <mod-name>.csproj            # MSBuild project (Godot.NET.Sdk)
│       ├── <mod-name>.json              # Mod manifest (id, version, dependencies…)
│       ├── project.godot                # Godot project file
│       ├── export_presets.cfg           # Godot export config (for .pck generation)
│       ├── Directory.Build.props        # Local overrides: GodotPath, Sts2Path (gitignored)
│       ├── Sts2PathDiscovery.props      # Cross-platform auto-detection of STS2 install
│       ├── <mod-name>/                  # Godot assets (scenes, images, localization…)
│       └── <mod-name>Code/              # C# source files
│           └── MainFile.cs              # Mod entry point ([ModInitializer])
└── docs/
```

## Adding a New Mod

1. In Rider, right-click the solution → **Add → New Project**, place it under `mods/<new-mod-name>/`. Rider updates `.sln` automatically.
2. Copy `Directory.Build.props` and `Sts2PathDiscovery.props` from an existing mod into the new project directory.
3. Create the mod manifest `mods/<new-mod-name>/<new-mod-name>.json` (see existing mod for schema).
4. Add the folder to `slay-the-spire-2-mods.code-workspace`:

   ```json
   { "path": "mods/<new-mod-name>" }
   ```

## Build Configurations

| Configuration | Purpose |
| --- | --- |
| `Debug` | Local development build |
| `ExportDebug` | Godot headless export — debug .pck |
| `ExportRelease` | Godot headless export — release .pck |

Post-build automatically copies `.dll` + `.json` manifest (and `.pck` if generated) into `$(ModsPath)<mod-name>/` inside the STS2 install directory.

## Git Workflow

- **All changes to `main` must go through a PR — no exceptions, including version bumps and chores**
- Every change must be developed on a dedicated branch — never commit directly to `main`
- Branch naming:
  - `feature/<short-description>` — new functionality
  - `fix/<short-description>` — bug fixes
  - `chore/<short-description>` — version bumps, dependency updates, config changes

### PR Flow

1. Create a branch and push to remote
2. Open a PR targeting `main` (e.g. `gh pr create`)
3. Check CI status (`gh pr checks`)
4. Merge and delete branch after approval (`gh pr merge --squash --delete-branch`)

### Release Flow

1. Bump version in `<mod-name>.json`
2. Commit + tag (`vX.Y.Z`)
3. Push tag to remote
4. Create GitHub release

## Key Conventions

- Mod id: **snake_case** (e.g. `modded_save_sync`) — used in manifest `id`, `ModId` constant, Harmony id, Logger name.
- Directory/file names: **kebab-case** (e.g. `modded-save-sync`) — project folder, `.csproj`, `.json`.
- C# namespace: `<mod_id>.<mod_id>Code` (e.g. `modded_save_sync.modded_save_syncCode`).
- Godot assets go in `<mod-name>/` (kebab); C# source goes in `<mod-name>Code/` (kebab).
- `Directory.Build.props` holds machine-local path overrides — do not commit absolute paths; rely on `Sts2PathDiscovery.props` auto-detection.

## Path Resolution (MSBuild)

`Sts2PathDiscovery.props` auto-detects the STS2 Steam install and sets:

- `$(Sts2DataDir)` — game data dir (platform suffix: `_windows_x86_64` / `_linuxbsd_x86_64` / `_macos_x86_64`)
- `$(ModsPath)` — destination for post-build copy

Override via `Directory.Build.props` or `/p:Sts2Path=...` on the MSBuild CLI.

## Mod Entry Point Pattern

```csharp
[ModInitializer(nameof(Initialize))]
public partial class MainFile : Node
{
    public const string ModId = "<mod_id>";
    public static Logger Logger { get; } = new(ModId, LogType.Generic);

    public static void Initialize()
    {
        new Harmony(ModId).PatchAll();
    }
}
```

## Commands

```bash
# Build a single mod (Debug)
dotnet build mods/<mod-name>/<mod-name>.csproj

# Build all mods
dotnet build slay-the-spire-2-mods.sln

# Publish (triggers Godot headless .pck export)
dotnet publish mods/<mod-name>/<mod-name>.csproj
```

## Module Responsibilities

| File | Role |
| --- | --- |
| `<mod>.csproj` | MSBuild project: references, build targets, post-build copy |
| `<mod>.json` | Mod manifest consumed by STS2 mod loader |
| `project.godot` | Godot project config (required for .pck export) |
| `Sts2PathDiscovery.props` | Cross-platform MSBuild path resolution for STS2 install |
| `Directory.Build.props` | Machine-local overrides (GodotPath, Sts2Path) |
| `MainFile.cs` | Mod initializer — Harmony setup and mod bootstrap |

## Constraints & Off-Limits

- Godot version must stay at **4.5.1** — STS2 (MegaDot) rejects `.pck` files built with a newer version.
- Do not change `TargetFramework` away from `net9.0`.
- Do not commit machine-local absolute paths into `Directory.Build.props`.

## Next Step

When implementation is stable and ready for tests, update `.ai-stage` to `TESTING` on this branch.
