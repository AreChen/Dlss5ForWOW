# Assemble the v1.0.0 public package with the user-supplied RTX 20/30 V8 runtime.
param(
  [Parameter(Mandatory=$true)][string]$BaseBundle,
  [Parameter(Mandatory=$true)][string]$NeuralRuntime,
  [Parameter(Mandatory=$true)][string]$OutputDirectory,
  [Parameter(Mandatory=$true)][ValidatePattern('^[0-9a-fA-F]{40}$')][string]$PackagingCommit
)
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$expectedV8 = 'b5046907fb80e90926c6aa275b48dc7ffb81cfa05d46380ddc66c72692d777ba'
if ((Get-FileHash -LiteralPath $NeuralRuntime -Algorithm SHA256).Hash.ToLowerInvariant() -ne $expectedV8) {
  throw 'The supplied neural runtime is not the requested RTX 20/30 V8 file.'
}
$baseManifest = Get-Content -LiteralPath (Join-Path $BaseBundle 'BUILD-MANIFEST.json') -Raw | ConvertFrom-Json
if ($baseManifest.version -ne '1.0.0' -or $baseManifest.nvidiaRuntimeIncluded -ne $false -or
    $baseManifest.sourceCommit -ne '1c369ca2177b582a3389c5883a03ef5c39565746') {
  throw 'The base package is not the original runtime-free v1.0.0 build.'
}
foreach ($entry in $baseManifest.files) {
  $path = Join-Path $BaseBundle $entry.name
  if ((Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant() -ne $entry.sha256) {
    throw "A base package file does not match its manifest: $($entry.name)"
  }
}
$baseFiles = @(Get-ChildItem -LiteralPath $BaseBundle -File -Recurse)
if ($baseFiles.Count -ne @($baseManifest.files).Count + 1) {
  throw 'The base package has unexpected files; create a clean runtime-free base.'
}
$stage = Join-Path $OutputDirectory 'stage-v1.0.0-RTX20-30-with-V8'
$bundle = Join-Path $stage 'Dlss5ForWOW'
$zip = Join-Path $OutputDirectory 'Dlss5ForWOW-v1.0.0-RTX20-30-with-V8.zip'
$sumFile = Join-Path $OutputDirectory 'SHA256SUMS-v1.0.0-RTX20-30-with-V8.txt'
if ((Test-Path -LiteralPath $stage) -or (Test-Path -LiteralPath $zip) -or (Test-Path -LiteralPath $sumFile)) {
  throw 'The staging directory or output file already exists. Choose a fresh output directory.'
}
New-Item -ItemType Directory -Path $stage -Force | Out-Null
Copy-Item -LiteralPath $BaseBundle -Destination $bundle -Recurse
foreach ($name in @('LICENSE', 'THIRD-PARTY-NOTICES.md', 'README.md', 'README.ru.md', 'CHANGELOG.md')) {
  Copy-Item -LiteralPath (Join-Path $root $name) -Destination $bundle -Force
}
$slot = Join-Path $bundle 'runtimes\compatible'
New-Item -ItemType Directory -Path $slot -Force | Out-Null
Copy-Item -LiteralPath $NeuralRuntime -Destination (Join-Path $slot 'nvngx_dlssnr.dll')
Remove-Item -LiteralPath (Join-Path $bundle 'BUILD-MANIFEST.json')
$bundlePath = (Resolve-Path -LiteralPath $bundle).Path
$entries = Get-ChildItem -LiteralPath $bundle -File -Recurse | Sort-Object FullName | ForEach-Object {
  [ordered]@{
    name = $_.FullName.Substring($bundlePath.Length + 1).Replace('\','/')
    bytes = $_.Length
    sha256 = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
  }
}
[ordered]@{
  version = $baseManifest.version
  sourceCommit = $baseManifest.sourceCommit
  packagingCommit = $PackagingCommit.ToLowerInvariant()
  sdkRequired = $true
  nvidiaRuntimeIncluded = $true
  neuralRuntimeOriginalName = 'nvngx_dlssnr_309_plain_xnp255_fp16all_rtx2030_V8.dll'
  neuralRuntimeSha256 = $expectedV8
  files = @($entries)
} | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $bundle 'BUILD-MANIFEST.json') -Encoding utf8
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::CreateFromDirectory($stage, $zip, [System.IO.Compression.CompressionLevel]::Optimal, $false)
$hash = (Get-FileHash -LiteralPath $zip -Algorithm SHA256).Hash.ToLowerInvariant()
"$hash  $(Split-Path $zip -Leaf)" | Set-Content -LiteralPath $sumFile -Encoding ascii
Write-Output "Packaged $zip"
Write-Output "SHA256 $hash"
