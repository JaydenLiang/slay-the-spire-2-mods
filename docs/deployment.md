# Deployment

This document is read by Claude when the user says "run the release flow" (or similar). Follow every step exactly.

## Commit Scope Convention

For bump inference to work, commits affecting a specific mod **must** include the mod name as the conventional commit scope:

| Example                                    | Mod affected       |
| ------------------------------------------ | ------------------ |
| `feat(reload-run): add F6 solo mode`       | reload-run         |
| `fix(modded-save-sync): correct save path` | modded-save-sync   |
| `chore: update README`                     | ignored (no scope) |

Commits without a matching scope are excluded from bump inference.

---

## Release Flow

### Step 1 — Select mods to release

Run `ls mods/` to list available mods. Ask the user which mod(s) to release. Multiple mods can be released in one session — process each sequentially.

### Step 2 — For each selected mod

#### 2a. Find last release tag

```bash
git tag --list '<mod>/v*' --sort=-version:refname | head -1
```

If no tag exists yet, treat all commits touching `mods/<mod>/` as in scope.

#### 2b. Collect commits since last tag

```bash
git log <last-tag>..HEAD --format="%s %b"
```

Filter to lines where the scope matches the mod name (kebab-case):

- Pattern: `^\w+\(<mod>\)(!)?:`

#### 2c. Infer bump level

Take the **highest** level found across all matching commits:

| Commit pattern                                     | Bump                |
| -------------------------------------------------- | ------------------- |
| `feat!(<mod>):` or body contains `BREAKING CHANGE` | **major**           |
| `feat(<mod>):`                                     | **minor**           |
| `fix/chore/refactor/docs/perf(<mod>):`             | **patch**           |
| No matching commits                                | **patch** (default) |

#### 2d. Present recommendation to user

Show:

- Current version (from `mods/<mod>/<mod>.json` → `version`)
- Recommended bump level and **why** (list the commits that drove the decision)
- Proposed new version

Wait for user to confirm or override before proceeding.

#### 2e. Update version and game version in manifest

After user confirms:

1. Read the current game version from the local installation:

   ```bash
   cat "<Sts2Path>/release_info.json"   # Sts2Path is in mods/<mod>/Directory.Build.props
   ```

2. Edit `mods/<mod>/<mod>.json` — update **both** fields:
   - `version` → new version (keep the `v` prefix, e.g. `v1.0.1`)
   - `build_on_game_version` → value from `release_info.json` → `version`

Show the user both values before proceeding so they can confirm the game version is correct.

#### 2f. Update root README version

Edit `README.md`, `README.zh-CN.md`, and `README.zh-TW.md` — update the `Version` column for this mod in the Mods table to `<new-version>`.

#### 2g. Commit, tag, and push

```bash
git add mods/<mod>/<mod>.json README.md README.zh-CN.md README.zh-TW.md
git commit -m "chore(<mod>): bump version to <new-version>"
git tag <mod>/<new-version>
```

### Step 3 — Summary and push

After processing all selected mods, show a summary:

- Each mod: old version → new version, commit hash, tag

Ask: **"Push now? [y/N]"**

If yes:

```bash
git push && git push --tags
```

Pushing the tag triggers GitHub Actions to create a **prerelease** on GitHub automatically.

### Step 4 — Local build and publish

After pushing, instruct the user to run the release script for each mod:

```bash
./scripts/release.sh <mod-name>
```

The script will:

1. Build the mod locally with `dotnet build --configuration Release`
2. Collect the DLL from `.godot/mono/temp/bin/Release/` and the JSON manifest
3. Package them into `<mod>-<version>.zip`
4. Upload the zip to the GitHub prerelease
5. Promote the prerelease to a full release

Run this script immediately after pushing — the script will wait (up to 60s) for GitHub Actions to finish creating the prerelease before uploading.

---

## GitHub Actions (triggered by tag push)

Each mod has its own workflow file:

- `.github/workflows/release-modded-save-sync.yml`
- `.github/workflows/release-reload-run.yml`

The workflow only creates the prerelease with auto-generated notes. It does **not** build or package — that is handled locally by `scripts/release.sh`.

---

## Rollback

To undo a release before push (no remote impact):

```bash
git tag -d <mod>/<version>        # delete local tag
git reset --hard HEAD~1           # undo version bump commit
```

To undo after push:

```bash
# Delete the remote tag (stops CI from re-triggering)
git push origin --delete <mod>/<version>

# Delete the local tag
git tag -d <mod>/<version>

# Delete the GitHub Release
gh release delete <mod>/<version> --yes
```

---

## Known Risks

- If two mods are released in the same session and the push fails midway, only some tags may be on remote. Check `git tag` vs `git ls-remote --tags origin` to reconcile.
- The release script assumes the assembly name is the mod name with hyphens replaced by underscores (e.g. `reload-run` → `reload_run.dll`). If the `AssemblyName` in the csproj differs, update the script accordingly.

## Troubleshooting

### GitHub Actions fails with "403 Resource not accessible by integration"

**Symptom:** The prerelease creation step fails with a 403 error.

**Cause:** The workflow is missing `permissions: contents: write`.

**Fix:** Add this to the workflow file (`.github/workflows/release-<mod>.yml`):

```yaml
permissions:
  contents: write
```

### Script exits with "prerelease not found after 60s"

**Symptom:** Script polls for 60s but the prerelease never appears.

**Cause:** GitHub Actions workflow failed or was not triggered (e.g. tag was not pushed, or workflow has a 403 error).

**Fix:** Check GitHub Actions status and fix the workflow, then re-push the tag or manually create the prerelease:

```bash
gh release create "<mod>/<version>" --prerelease --generate-notes --title "<mod> <version>"
```

Then re-run the script.
