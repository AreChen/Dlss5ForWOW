# Package a Release build without NVIDIA runtime binaries, user configuration or logs.
param(
  [Parameter(Mandatory=$true)][string]$BuildDir,
  [Parameter(Mandatory=$true)][string]$ComponentDirectory,
  [Parameter(Mandatory=$true)][string]$OutputDirectory,
  [Parameter(Mandatory=$true)][ValidatePattern('^[0-9a-fA-F]{40}$')][string]$SourceCommit
)
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$version = (Select-String -LiteralPath (Join-Path $root 'CMakeLists.txt') -Pattern 'project\(.*VERSION\s+([0-9]+\.[0-9]+\.[0-9]+)').Matches[0].Groups[1].Value
$cache = Get-Content -LiteralPath (Join-Path $BuildDir 'CMakeCache.txt') -Raw
if ($cache -notmatch '(?m)^SIDECAR_REQUIRE_SDKS:BOOL=ON\s*$') {
  throw 'Configure the Release build with SIDECAR_REQUIRE_SDKS=ON before packaging.'
}
$stage = Join-Path $OutputDirectory "stage-v$version"
$bundle = Join-Path $stage 'Dlss5ForWOW'
$zip = Join-Path $OutputDirectory "Dlss5ForWOW-v$version-win-x64.zip"
if ((Test-Path -LiteralPath $stage) -or (Test-Path -LiteralPath $zip)) {
  throw 'The staging directory or archive already exists. Choose a fresh output directory.'
}
New-Item -ItemType Directory -Path $bundle -Force | Out-Null
foreach ($name in @('wowsidecar.exe', 'wowsidecar-manager.exe')) {
  Copy-Item -LiteralPath (Join-Path $BuildDir "Release\$name") -Destination $bundle
}
# Binaries from the upstream 0.6.0 release; verify provenance before packing.
$components = @{
  'dxgi.dll' = '0cee63f9c9f13f3ac909c5b4903f4dbb4b719a7ab3b4f13b0deaf83c814b94f7'
  'renodx-dlss5.addon64' = 'e1c28fde0922b12fc10734e58c3d24a36808e575247f4fd4f36226540d7ee023'
}
foreach ($name in $components.Keys) {
  $file = Join-Path $ComponentDirectory $name
  if ((Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash.ToLowerInvariant() -ne $components[$name]) {
    throw "Unexpected component hash: $name"
  }
  Copy-Item -LiteralPath $file -Destination $bundle
}
foreach ($name in @('LICENSE', 'THIRD-PARTY-NOTICES.md', 'README.md', 'README.ru.md', 'CHANGELOG.md')) {
  Copy-Item -LiteralPath (Join-Path $root $name) -Destination $bundle
}
Copy-Item -LiteralPath (Join-Path $root 'licenses') -Destination $bundle -Recurse
New-Item -ItemType Directory -Path (Join-Path $bundle 'assets\art'), (Join-Path $bundle 'assets\fonts') -Force | Out-Null
Copy-Item -LiteralPath (Join-Path $root 'assets\art\PROVENANCE.md') -Destination (Join-Path $bundle 'assets\art')
Get-ChildItem -LiteralPath (Join-Path $root 'assets\fonts') -Filter 'OFL-*.txt' -File | Copy-Item -Destination (Join-Path $bundle 'assets\fonts')
$bundlePath = (Resolve-Path -LiteralPath $bundle).Path
$entries = Get-ChildItem -LiteralPath $bundle -File -Recurse | Sort-Object FullName | ForEach-Object {
  [ordered]@{
    name = $_.FullName.Substring($bundlePath.Length + 1).Replace('\','/')
    bytes = $_.Length
    sha256 = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
  }
}
[ordered]@{
  version = $version
  sourceCommit = $SourceCommit.ToLowerInvariant()
  sdkRequired = $true
  nvidiaRuntimeIncluded = $false
  files = @($entries)
} | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $bundle 'BUILD-MANIFEST.json') -Encoding utf8
Compress-Archive -LiteralPath $bundle -DestinationPath $zip -CompressionLevel Optimal
$hash = (Get-FileHash -LiteralPath $zip -Algorithm SHA256).Hash.ToLowerInvariant()
"$hash  $(Split-Path $zip -Leaf)" | Set-Content -LiteralPath (Join-Path $OutputDirectory "SHA256SUMS-v$version.txt") -Encoding ascii
Write-Output "Packaged $zip"
Write-Output "SHA256 $hash"
