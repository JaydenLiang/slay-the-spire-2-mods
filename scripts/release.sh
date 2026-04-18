#!/usr/bin/env bash
# Usage: ./scripts/release.sh <mod-name>
# Example: ./scripts/release.sh reload-run
#
# Builds the mod, packages artifacts into a zip, uploads to the GitHub prerelease,
# then promotes it to a full release.

set -euo pipefail

MOD="$1"
MOD_DIR="mods/$MOD"
MANIFEST="$MOD_DIR/$MOD.json"

if [[ -z "$MOD" ]]; then
  echo "Error: mod name required. Usage: $0 <mod-name>" >&2
  exit 1
fi

if [[ ! -f "$MANIFEST" ]]; then
  echo "Error: manifest not found at $MANIFEST" >&2
  exit 1
fi

# Read version from manifest
VERSION=$(python3 -c "import json; print(json.load(open('$MANIFEST'))['version'])")
TAG="$MOD/$VERSION"
ZIP="$MOD-$VERSION.zip"

echo "==> Mod:     $MOD"
echo "==> Version: $VERSION"
echo "==> Tag:     $TAG"
echo ""

# Build
echo "==> Building..."
dotnet build "$MOD_DIR/$MOD.csproj" --configuration Release

# Collect artifacts
echo "==> Collecting artifacts..."
DIST=$(mktemp -d)
trap 'rm -rf "$DIST"' EXIT

# Assembly name uses underscores (kebab → snake)
ASSEMBLY=$(echo "$MOD" | tr '-' '_')
DLL="$MOD_DIR/.godot/mono/temp/bin/Release/${ASSEMBLY}.dll"

if [[ ! -f "$DLL" ]]; then
  echo "Error: DLL not found at $DLL" >&2
  echo "Make sure the build succeeded and the assembly name matches." >&2
  exit 1
fi

cp "$DLL" "$DIST/"
cp "$MANIFEST" "$DIST/"

# Package
echo "==> Packaging $ZIP..."
(cd "$DIST" && zip -r - .) > "$ZIP"

# Upload to prerelease
echo "==> Uploading $ZIP to release $TAG..."
gh release upload "$TAG" "$ZIP"

# Promote to full release
echo "==> Promoting prerelease to release..."
gh release edit "$TAG" --prerelease=false

echo ""
echo "Done! Release published: https://github.com/$(gh repo view --json nameWithOwner -q .nameWithOwner)/releases/tag/$TAG"

# Clean up zip
rm -f "$ZIP"
