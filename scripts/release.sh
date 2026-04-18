#!/usr/bin/env bash
# Usage: ./scripts/release.sh <mod-name>
# Example: ./scripts/release.sh reload-run
#
# Builds the mod, packages artifacts into a zip, uploads to the GitHub prerelease,
# then promotes it to a full release.

set -euo pipefail

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

# --- Locate STS2 installation ---
find_sts2_path() {
  # 1. Check Directory.Build.props in the mod directory (highest priority)
  local props="$MOD_DIR/Directory.Build.props"
  if [[ -f "$props" ]]; then
    local from_props
    from_props=$(grep -oP '(?<=<Sts2Path>)[^<]+' "$props" 2>/dev/null || true)
    if [[ -n "$from_props" && -d "$from_props" ]]; then
      echo "$from_props"
      return
    fi
  fi

  # 2. Auto-detect by OS
  local steam_path
  case "$(uname -s)" in
    Linux)
      steam_path="$HOME/.local/share/Steam/steamapps"
      ;;
    Darwin)
      steam_path="$HOME/Library/Application Support/Steam/steamapps"
      ;;
    *)
      # Windows (Git Bash / MSYS2) — try common locations
      for candidate in \
        "D:/SteamLibrary/steamapps" \
        "C:/Program Files (x86)/Steam/steamapps" \
        "C:/Program Files/Steam/steamapps"; do
        if [[ -d "$candidate/common/Slay the Spire 2" ]]; then
          echo "$candidate/common/Slay the Spire 2"
          return
        fi
      done
      ;;
  esac

  local sts2="$steam_path/common/Slay the Spire 2"
  if [[ -d "$sts2" ]]; then
    echo "$sts2"
    return
  fi

  echo ""
}

STS2_PATH=$(find_sts2_path)
if [[ -z "$STS2_PATH" ]]; then
  echo "Error: could not locate Slay the Spire 2 installation." >&2
  echo "Set Sts2Path in $MOD_DIR/Directory.Build.props to override." >&2
  exit 1
fi

RELEASE_INFO="$STS2_PATH/release_info.json"
if [[ ! -f "$RELEASE_INFO" ]]; then
  echo "Error: release_info.json not found at $RELEASE_INFO" >&2
  exit 1
fi

GAME_VERSION=$(python3 -c "import json; print(json.load(open('$RELEASE_INFO'))['version'])")

# --- Read mod version ---
VERSION=$(python3 -c "import json; print(json.load(open('$MANIFEST'))['version'])")
TAG="$MOD/$VERSION"
ZIP="$MOD-$VERSION.zip"

echo "==> Mod:              $MOD"
echo "==> Mod version:      $VERSION"
echo "==> Game version:     $GAME_VERSION"
echo "==> Tag:              $TAG"
echo ""

# --- Update build_on_game_version in manifest ---
echo "==> Updating build_on_game_version in manifest..."
python3 - <<PYEOF
import json, sys
path = '$MANIFEST'
with open(path) as f:
    data = json.load(f)
data['build_on_game_version'] = '$GAME_VERSION'
with open(path, 'w') as f:
    json.dump(data, f, indent=2)
    f.write('\n')
PYEOF

# --- Build ---
echo "==> Building..."
dotnet build "$MOD_DIR/$MOD.csproj" --configuration Release

# --- Collect artifacts ---
echo "==> Collecting artifacts..."
DIST=$(mktemp -d)
trap 'rm -rf "$DIST"' EXIT

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
(cd "$DIST" && zip -r - .) > "$ZIP"

# --- Upload to prerelease ---
echo "==> Uploading $ZIP to release $TAG..."
gh release upload "$TAG" "$ZIP"

# --- Promote to full release ---
echo "==> Promoting prerelease to release..."
gh release edit "$TAG" --prerelease=false

echo ""
echo "Done! Release published: https://github.com/$(gh repo view --json nameWithOwner -q .nameWithOwner)/releases/tag/$TAG"

rm -f "$ZIP"
