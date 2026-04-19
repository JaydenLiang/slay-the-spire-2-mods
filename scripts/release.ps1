# Usage: ./scripts/release.ps1 <mod-name>
# Example: ./scripts/release.ps1 reload-run
#
# Builds the mod, packages artifacts into a zip, uploads to the GitHub prerelease,
# then promotes it to a full release.
#
# Prerequisites: dotnet, gh (GitHub CLI)
# Must be run from the repository root.

param(
  [Parameter(Mandatory=$true)]
  [string]$Mod
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# --- Ensure running from repo root ---
if (-not (Test-Path "README.md") -or -not (Test-Path "mods")) {
  Write-Error "Error: must be run from the repository root."
  exit 1
}

# --- Check prerequisites ---
foreach ($cmd in @("dotnet", "gh")) {
  if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
    Write-Error "Error: required command not found: $cmd"
    exit 1
  }
}

$ModDir  = "mods/$Mod"
$Manifest = "$ModDir/$Mod.json"

if (-not (Test-Path $Manifest)) {
  Write-Error "Error: manifest not found at $Manifest"
  exit 1
}

# --- Locate STS2 installation via Directory.Build.props ---
$Props = "$ModDir/Directory.Build.props"
$Sts2Path = ""
if (Test-Path $Props) {
  $xml = [xml](Get-Content $Props -Raw)
  $Sts2Path = $xml.SelectSingleNode("//*[local-name()='Sts2Path']").'#text'.Trim()
}
if (-not $Sts2Path -or -not (Test-Path $Sts2Path)) {
  Write-Error "Error: could not read a valid Sts2Path from $Props`nMake sure Sts2Path is set and the directory exists."
  exit 1
}

$ReleaseInfo = "$Sts2Path/release_info.json"
if (-not (Test-Path $ReleaseInfo)) {
  Write-Error "Error: release_info.json not found at $ReleaseInfo"
  exit 1
}

$GameVersion         = (Get-Content $ReleaseInfo | ConvertFrom-Json).version
$ManifestGameVersion = (Get-Content $Manifest    | ConvertFrom-Json).build_on_game_version

if ($GameVersion -ne $ManifestGameVersion) {
  Write-Error "Error: game version mismatch!`n  Installed game:   $GameVersion`n  Manifest expects: $ManifestGameVersion`nRun the release flow again to update build_on_game_version, then retry."
  exit 1
}

# --- Read mod version ---
$Version  = (Get-Content $Manifest | ConvertFrom-Json).version
$Tag      = "$Mod/$Version"
$ZipName  = "$Mod-$Version.zip"
$ZipPath  = Join-Path (Get-Location) $ZipName

Write-Host "==> Mod:              $Mod"
Write-Host "==> Mod version:      $Version"
Write-Host "==> Game version:     $GameVersion (verified)"
Write-Host "==> Tag:              $Tag"
Write-Host ""

# --- Build ---
Write-Host "==> Building..."
dotnet build "$ModDir/$Mod.csproj" --configuration Release
if ($LASTEXITCODE -ne 0) { exit 1 }

# --- Collect artifacts ---
Write-Host "==> Collecting artifacts..."
$Dist = New-Item -ItemType Directory -Path (Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())) -Force

try {
  $Assembly = $Mod -replace '-', '_'
  $Dll = "$ModDir/.godot/mono/temp/bin/Release/$Assembly.dll"

  if (-not (Test-Path $Dll)) {
    Write-Error "Error: DLL not found at $Dll`nMake sure the build succeeded and the assembly name matches."
    exit 1
  }

  Copy-Item $Dll $Dist
  Copy-Item $Manifest $Dist

  # --- Package ---
  Write-Host "==> Packaging $ZipName..."
  Compress-Archive -Path "$Dist/*" -DestinationPath $ZipPath -Force

  # --- Wait for prerelease ---
  Write-Host "==> Waiting for prerelease $Tag to be available..."
  $found = $false
  for ($i = 1; $i -le 12; $i++) {
    $null = gh release view $Tag 2>&1
    if ($LASTEXITCODE -eq 0) {
      Write-Host "    Prerelease found."
      $found = $true
      break
    }
    if ($i -eq 12) {
      Write-Error "Error: prerelease $Tag not found after 60s. Check GitHub Actions."
      exit 1
    }
    Write-Host "    Not ready yet, retrying in 5s... ($i/12)"
    Start-Sleep 5
  }

  # --- Upload ---
  Write-Host "==> Uploading $ZipPath to release $Tag..."
  gh release upload $Tag $ZipPath
  if ($LASTEXITCODE -ne 0) { exit 1 }

  # --- Promote ---
  Write-Host "==> Promoting prerelease to release..."
  gh release edit $Tag --prerelease=false
  if ($LASTEXITCODE -ne 0) { exit 1 }

  $RepoName = (gh repo view --json nameWithOwner | ConvertFrom-Json).nameWithOwner
  Write-Host ""
  Write-Host "Done! Release published: https://github.com/$RepoName/releases/tag/$Tag"

} finally {
  Remove-Item -Recurse -Force $Dist -ErrorAction SilentlyContinue
  if (Test-Path $ZipPath) { Remove-Item -Force $ZipPath -ErrorAction SilentlyContinue }
}
