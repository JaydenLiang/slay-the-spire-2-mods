# GitHub Workflow

## Branch Naming

- **All changes to `main` must go through a PR — no exceptions**
- Never commit directly to `main`
- `feature/<short-description>` — new functionality
- `fix/<short-description>` — bug fixes
- `chore/<short-description>` — version bumps, config changes, dependency updates

---

## Commit Message Format

Use [Conventional Commits](https://www.conventionalcommits.org/):

```text
<type>(<scope>): <description>
```

**Types:** `feat`, `fix`, `chore`, `docs`, `refactor`, `perf`

**Scope:** use the mod's kebab-case name when the commit affects a specific mod — this is required for release bump inference:

| Example                                    | When to use                          |
| ------------------------------------------ | ------------------------------------ |
| `feat(reload-run): add F6 solo mode`       | change affects reload-run only       |
| `fix(modded-save-sync): correct save path` | change affects modded-save-sync only |
| `chore: update README`                     | cross-cutting, no specific mod       |

Commits without a mod scope are excluded from automated version bump inference during release. See `docs/deployment.md` for details.

**Breaking changes:** add `!` after the type/scope, e.g. `feat(reload-run)!: redesign reload API`

---

## PR Flow

```bash
# 1. Create and switch to a branch
git checkout -b feature/<short-description>

# 2. Make changes, commit, and push
git add <files>
git commit -m "feat(<mod>): describe the change"
git push -u origin feature/<short-description>

# 3. Create a pull request
gh pr create \
  --title "feat(<mod>): describe the change" \
  --body "$(cat <<'EOF'
## Summary
- <bullet points>

## Test plan
- [ ] <manual test steps>
EOF
)"

# 4. Check CI status
gh pr checks

# 5. Merge with no-ff locally (preserves full commit history)
git checkout main
git pull origin main
git merge --no-ff <branch> -m "Merge branch '<branch>'"
git push origin main
```

---

## Release Flow

Releases are AI-driven. Tell Claude "run the release flow" and it will:

1. Analyze commits since the last tag to infer the version bump
2. Present a recommendation with reasoning
3. Update the mod's `.json` manifest, commit, and create a tag after your confirmation
4. Push on your approval — GitHub Actions then builds and publishes the GitHub Release automatically

See `docs/deployment.md` for the full release procedure.

---

## Quick Reference

```bash
# List open PRs
gh pr list

# View PR status and checks
gh pr view
gh pr checks

# List releases
gh release list

# View a release
gh release view <mod>/v<version>

# Delete a release (e.g. to redo)
gh release delete <mod>/v<version>
```
