#!/usr/bin/env bash
# Usage: ./scripts/release.sh <mod-name>
# Example: ./scripts/release.sh reload-run
#
# Builds the mod, packages artifacts into a zip, uploads to the GitHub prerelease,
# then promotes it to a full release.
#
# Prerequisites: dotnet, gh (GitHub CLI), zip, python3
# Must be run from the repository root.

set -euo pipefail

# --- Ensure running from repo root ---
if [[ ! -f "README.md" || ! -d "mods" ]]; then
  echo "Error: must be run from the repository root." >&2
  exit 1
fi

# --- Check prerequisites ---
for cmd in dotnet gh zip python3; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Error: required command not found: $cmd" >&2
    exit 1
  fi
done

MOD="${1:-}"
if [[ -z "$MOD" ]]; then
  echo "Error: mod name required. Usage: $0 <mod-name>" >&2
  exit 1
fi

MOD_DIR="mods/$MOD"
MANIFEST="$MOD_DIR/$MOD.json"

if [[ ! -f "$MANIFEST" ]]; then
  echo "Error: manifest not found at $MANIFEST" >&2
  exit 1
fi

# --- Locate STS2 installation via Directory.Build.props ---
PROPS="$MOD_DIR/Directory.Build.props"
STS2_PATH=""
if [[ -f "$PROPS" ]]; then
  STS2_PATH=$(python3 -c "
import re, sys
content = open('$PROPS').read()
m = re.search(r'<Sts2Path>([^<]+)</Sts2Path>', content)
print(m.group(1).strip()) if m else print('')
" 2>/dev/null || true)
fi
if [[ -z "$STS2_PATH" || ! -d "$STS2_PATH" ]]; then
  echo "Error: could not read a valid Sts2Path from $PROPS" >&2
  echo "Make sure Sts2Path is set and the directory exists." >&2
  exit 1
fi

RELEASE_INFO="$STS2_PATH/release_info.json"
if [[ ! -f "$RELEASE_INFO" ]]; then
  echo "Error: release_info.json not found at $RELEASE_INFO" >&2
  exit 1
fi

GAME_VERSION=$(python3 -c "import json; print(json.load(open('$RELEASE_INFO'))['version'])")
MANIFEST_GAME_VERSION=$(python3 -c "import json; print(json.load(open('$MANIFEST')).get('build_on_game_version', ''))")

if [[ "$GAME_VERSION" != "$MANIFEST_GAME_VERSION" ]]; then
  echo "Error: game version mismatch!" >&2
  echo "  Installed game:   $GAME_VERSION" >&2
  echo "  Manifest expects: $MANIFEST_GAME_VERSION" >&2
  echo "Run the release flow again to update build_on_game_version, then retry." >&2
  exit 1
fi

# --- Read mod version ---
VERSION=$(python3 -c "import json; print(json.load(open('$MANIFEST'))['version'])")
TAG="$MOD/$VERSION"
ZIP="$MOD-$VERSION.zip"

echo "==> Mod:              $MOD"
echo "==> Mod version:      $VERSION"
echo "==> Game version:     $GAME_VERSION (verified)"
echo "==> Tag:              $TAG"
echo ""

# --- Build ---
echo "==> Building..."
dotnet build "$MOD_DIR/$MOD.csproj" --configuration Release

# --- Collect artifacts ---
echo "==> Collecting artifacts..."
DIST=$(mktemp -d)
trap 'rm -rf "$DIST"; rm -f "$ZIPPATH"' EXIT

ASSEMBLY=$(echo "$MOD" | tr '-' '_')
DLL="$MOD_DIR/.godot/mono/temp/bin/Release/${ASSEMBLY}.dll"

if [[ ! -f "$DLL" ]]; then
  echo "Error: DLL not found at $DLL" >&2
  echo "Make sure the build succeeded and the assembly name matches." >&2
  exit 1
fi

cp "$DLL" "$DIST/"
cp "$MANIFEST" "$DIST/"

# --- Package ---
echo "==> Packaging $ZIP..."
ZIPPATH="$(pwd)/$ZIP"
(cd "$DIST" && zip -r "$ZIPPATH" .)

# --- Wait for prerelease to be created by GitHub Actions ---
echo "==> Waiting for prerelease $TAG to be available..."
for i in $(seq 1 12); do
  if gh release view "$TAG" &>/dev/null; then
    echo "    Prerelease found."
    break
  fi
  if [[ $i -eq 12 ]]; then
    echo "Error: prerelease $TAG not found after 60s. Check GitHub Actions." >&2
    exit 1
  fi
  echo "    Not ready yet, retrying in 5s... ($i/12)"
  sleep 5
done

# --- Upload to prerelease ---
echo "==> Uploading $ZIP to release $TAG..."
gh release upload "$TAG" "$ZIPPATH"

# --- Promote to full release ---
echo "==> Promoting prerelease to release..."
gh release edit "$TAG" --prerelease=false

echo ""
echo "Done! Release published: https://github.com/$(gh repo view --json nameWithOwner -q .nameWithOwner)/releases/tag/$TAG"
