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

#### 2e. Update version in manifest

After user confirms, edit `mods/<mod>/<mod>.json` — update the `version` field to the new version (keep the `v` prefix, e.g. `v1.0.1`).

#### 2f. Commit and tag

```bash
git add mods/<mod>/<mod>.json
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

Pushing the tag triggers GitHub Actions to build and publish the GitHub Release automatically.

---

## GitHub Actions (triggered by tag push)

Each mod has its own workflow file:

- `.github/workflows/release-modded-save-sync.yml`
- `.github/workflows/release-reload-run.yml`

The workflow:

1. Builds the mod with `dotnet build --configuration Release`
2. Packages `<assembly>.dll` + `<mod>.json` into `<mod>-<version>.zip`
3. Creates a GitHub Release with the zip attached

No manual action needed after pushing the tag.

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

# Delete the GitHub Release manually via:
gh release delete <mod>/<version> --yes

# Then fix and re-release with a new version
```

---

## Known Risks

- If two mods are released in the same session and the push fails midway, only some tags may be on remote. Check `git tag` vs `git ls-remote --tags origin` to reconcile.
- The `CI=true` env var suppresses the STS2 path check in the build. If the CI build fails, check the GitHub Actions log — it is likely a .NET or Godot SDK version mismatch.

## Troubleshooting

### CI fails with "403 Resource not accessible by integration" on `gh release create`

**Symptom:** Build succeeds but the release creation step fails with a 403 error.

**Cause:** The workflow is missing `permissions: contents: write`. GitHub Actions' default `GITHUB_TOKEN` does not have write access to releases unless explicitly granted.

**Fix:** Add this to the workflow file (`.github/workflows/release-<mod>.yml`):

```yaml
permissions:
  contents: write
```
